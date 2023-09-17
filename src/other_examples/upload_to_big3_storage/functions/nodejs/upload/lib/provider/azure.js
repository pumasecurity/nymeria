const axios = require('axios')
const { ManagedIdentityCredential } = require('@azure/identity')
const { BlobServiceClient, AnonymousCredential } = require('@azure/storage-blob')
const AWS = require('aws-sdk')
const aws = require('./aws')
const google = require('./google')
const GoogleCloudStorage = require('@google-cloud/storage').Storage
const { ExternalAccountClient } = require('google-auth-library')

const uniqueIdentifier = process.env.APPSETTING_UNIQUE_IDENTIFIER || process.env.UNIQUE_IDENTIFIER
const googleConfig = process.env.APPSETTING_GOOGLE_CLOUD_FEDERATION_CONFIGURATION || process.env.GOOGLE_CLOUD_FEDERATION_CONFIGURATION
const allowedJwtAudience = process.env.APPSETTING_ALLOWED_JWT_AUDIENCE || process.env.ALLOWED_JWT_AUDIENCE
const managedIdentityCredential = new ManagedIdentityCredential()
let blobServiceClient
const containerClients = {}
const blockBlobClients = {}
const msiEndpoint = process.env.MSI_ENDPOINT
const msiSecret = process.env.MSI_SECRET
const durationSeconds = 3600
let sts
let s3
let gcs

const initializeBlobServiceClient = (sas, credential) => {
  if (!blobServiceClient) {
    if (!credential) {
      credential = (sas) ? new AnonymousCredential() : managedIdentityCredential
    }

    const storageUrl = `https://uploadtobig3${uniqueIdentifier}.blob.core.windows.net${sas || ''}`
    blobServiceClient = new BlobServiceClient(storageUrl, credential)
  }
}

const getContainerClient = (containerName, sas, credential) => {
  if (!containerName) {
    throw new Error('Must provide a container name.')
  }

  initializeBlobServiceClient(sas, credential)

  if (!(containerName in containerClients)) {
    containerClients[containerName] = blobServiceClient.getContainerClient(containerName)
  }

  return containerClients[containerName]
}

const getBlockBlobClient = (containerName, blobName, sas, credential) => {
  if (!containerName || !blobName) {
    throw new Error('Must provide a blob and container name.')
  }

  const containerClient = getContainerClient(containerName, sas, credential)

  if (!(blobName in blockBlobClients)) {
    blockBlobClients[blobName] = containerClient.getBlockBlobClient(blobName)
  }

  return blockBlobClients[blobName]
}

const initializeStsClient = () => {
  if (!sts) {
    sts = new AWS.STS()
  }
}

module.exports.getMethod = (...args) => {
  const [, req] = args
  return req.method
}

module.exports.getHeaders = (...args) => {
  const [, req] = args
  return req.headers
}

module.exports.getBody = (...args) => {
  const [, req] = args
  return req.body
}

module.exports.respond = (statusCode, responseBody, ...args) => {
  const [context] = args

  context.res = {
    status: statusCode,
    body: JSON.stringify(responseBody),
    headers: {
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'OPTIONS,POST'
    }
  }
}

const uploadFileToAzureStorage = async (filename, content, sas, credential) => {
  const blockBlobClient = getBlockBlobClient('upload-to-big3', filename, sas, credential)
  return await blockBlobClient.upload(content, content.length)
}

const getAzureIdentityToken = async () => {
  const res = await axios.get(msiEndpoint, {
    headers: {
      Secret: msiSecret
    },
    params: {
      'api-version': '2017-09-01',
      resource: allowedJwtAudience
    }
  })

  return res.data.access_token
}

const initializeS3Client = async awsRoleArn => {
  if (s3) {
    return
  }

  const azureIdentityToken = await getAzureIdentityToken()

  return new Promise((resolve, reject) => {
    initializeStsClient()

    sts.assumeRoleWithWebIdentity({
      RoleArn: awsRoleArn,
      RoleSessionName: 'upload-to-big-3-azure',
      DurationSeconds: durationSeconds,
      WebIdentityToken: azureIdentityToken
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

const initializeGcsClient = async googleConfig => {
  if (gcs) {
    return
  }

  googleConfig.credential_source = {
    url: `${msiEndpoint}?api-version=2017-09-01&resource=${allowedJwtAudience}`,
    headers: {
      Secret: msiSecret
    },
    format: {
      type: 'json',
      subject_token_field_name: 'access_token'
    }
  }

  const authClient = ExternalAccountClient.fromJSON(googleConfig)
  authClient.scopes = ['https://www.googleapis.com/auth/cloud-platform']

  gcs = new GoogleCloudStorage({ authClient })

  setTimeout(() => {
    gcs = undefined
  }, durationSeconds * 1000)
}

module.exports.uploadFile = async (filename, content) => {
  const storagePlatformsUploadedTo = ['Azure Storage']
  const promises = [uploadFileToAzureStorage(filename, content)]

  /*
  if (awsRoleArn !== 'null') {
    await initializeS3Client(awsRoleArn)

    storagePlatformsUploadedTo.push('AWS S3')

    promises.push(
      aws.uploadFileToS3(filename, content, s3)
    )
  }
  */

  if (googleConfig !== 'null') {
    await initializeGcsClient(
      JSON.parse(googleConfig)
    )

    storagePlatformsUploadedTo.push('Google Cloud Storage')

    promises.push(
      google.uploadFileToGcs(filename, content, gcs)
    )
  }

  await Promise.all(promises)
  return storagePlatformsUploadedTo
}

module.exports.uploadFileToAzureStorage = uploadFileToAzureStorage
