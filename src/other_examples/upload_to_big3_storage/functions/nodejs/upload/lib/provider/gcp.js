const fs = require('fs')
const axios = require('axios')
const { Storage } = require('@google-cloud/storage')
const { SecretManagerServiceClient } = require('@google-cloud/secret-manager')
const AWS = require('aws-sdk')
const { ClientAssertionCredential } = require('@azure/identity')
const aws = require('./aws')
const azure = require('./azure')

const uniqueStringGcp = process.env.UNIQUE_STRING_GCP
const uniqueStringAzure = process.env.UNIQUE_STRING_AZURE
const durationSeconds = 3600
let projectId
let storage
let secretManager
let sts
let s3
let azureIdentity

const initializeProjectId = async () => {
  if (!projectId) {
    const res = await axios.get('http://metadata.google.internal/computeMetadata/v1/project/project-id', {
      headers: {
        'Metadata-Flavor': 'Google'
      }
    })

    projectId = res.data
  }
}

const initializeStorageClient = () => {
  if (!storage) {
    storage = new Storage()
  }
}

const initializeSecretManager = () => {
  if (!secretManager) {
    secretManager = new SecretManagerServiceClient()
  }
}

const initializeStsClient = () => {
  if (!sts) {
    sts = new AWS.STS()
  }
}

module.exports.getMethod = (...args) => {
  const [req] = args
  return req.method
}

module.exports.getHeaders = (...args) => {
  const [req] = args
  return req.headers
}

module.exports.getBody = (...args) => {
  const [req] = args
  return req.body
}

module.exports.respond = (statusCode, responseBody, ...args) => {
  const [, res] = args
  res.set('Access-Control-Allow-Headers', 'Content-Type')
  res.set('Access-Control-Allow-Origin', '*')
  res.set('Access-Control-Allow-Methods', 'OPTIONS,POST')
  res.status(statusCode).send(JSON.stringify(responseBody))
}

const getSecret = async key => {
  await initializeProjectId()
  initializeSecretManager()

  const [secret] = await secretManager.accessSecretVersion({
    name: `projects/${projectId}/secrets/${key}/versions/latest`
  })

  return secret.payload.data.toString()
}

const uploadFileToGcs = async (filename, content, client) => {
  const bucketName = `upload-to-big-3-${uniqueStringGcp}`
  const localFileName = `/tmp/${filename}`
  fs.writeFileSync(localFileName, content)

  await client.bucket(bucketName).upload(localFileName, {
    gzip: true,
    metadata: {
      cacheControl: 'public, max-age=31536000'
    }
  })
}

const getGcpIdentityToken = async audience => {
  const res = await axios.get('http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity', {
    headers: {
      'Metadata-Flavor': 'Google'
    },
    params: {
      audience
    }
  })

  return res.data
}

const initializeS3Client = async awsRoleArn => {
  if (s3) {
    return
  }

  const gcpIdentityToken = await getGcpIdentityToken('sts.amazonaws.com')

  return new Promise((resolve, reject) => {
    initializeStsClient()

    sts.assumeRoleWithWebIdentity({
      RoleArn: awsRoleArn,
      RoleSessionName: 'upload-to-big-3-google',
      DurationSeconds: durationSeconds,
      WebIdentityToken: gcpIdentityToken
    }, async (err, data) => {
      if (err) {
        reject(err)
      } else {
        s3 = new AWS.S3({
          credentials: new AWS.Credentials({
            accessKeyId: data.Credentials.AccessKeyId,
            secretAccessKey: data.Credentials.SecretAccessKey,
            sessionToken: data.Credentials.SessionToken
          })
        })

        setTimeout(() => {
          s3 = undefined
        }, durationSeconds * 1000)

        resolve()
      }
    })
  })
}

const initializeAzureIdentity = azureConfig => {
  if (azureIdentity) {
    return
  }

  azureIdentity = new ClientAssertionCredential(
    azureConfig.tenant_id,
    azureConfig.client_id,
    async () => await getGcpIdentityToken(`api://upload-to-big-3-${uniqueStringAzure}`)
  )
}

module.exports.uploadFile = async (filename, content) => {
  initializeStorageClient()

  const [awsRoleArn, azureConfig] = await Promise.all([
    getSecret('aws-role-arn'),
    getSecret('azure-config')
  ])

  const storagePlatformsUploadedTo = ['Google Cloud Storage']
  const promises = [uploadFileToGcs(filename, content, storage)]

  /*
  if (awsRoleArn !== 'null') {
    await initializeS3Client(awsRoleArn)

    storagePlatformsUploadedTo.push('AWS S3')

    promises.push(
      aws.uploadFileToS3(filename, content, s3)
    )
  }

  if (azureConfig !== 'null') {
    initializeAzureIdentity(JSON.parse(azureConfig))

    storagePlatformsUploadedTo.push('Azure Storage')

    promises.push(
      azure.uploadFileToAzureStorage(filename, content, undefined, azureIdentity)
    )
  }
  */

  await Promise.all(promises)
  return storagePlatformsUploadedTo
}

module.exports.uploadFileToGcs = uploadFileToGcs
