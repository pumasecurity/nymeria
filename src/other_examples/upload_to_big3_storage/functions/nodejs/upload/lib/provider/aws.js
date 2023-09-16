const AWS = require('aws-sdk')
const azure = require('./azure')
const gcp = require('./gcp')
const GoogleCloudStorage = require('@google-cloud/storage').Storage
const { ExternalAccountClient } = require('google-auth-library')

const uniqueIdentifier = process.env.UNIQUE_IDENTIFIER
const durationSeconds = 3600
let s3
let secretsManager
let gcs

const initializeS3Client = () => {
  if (!s3) {
    s3 = new AWS.S3()
  }
}

const initializeSecretsManagerClient = async () => {
  if (!secretsManager) {
    secretsManager = new AWS.SecretsManager({ region: process.env.AWS_REGION })
  }
}

module.exports.getMethod = (...args) => {
  const [event] = args
  return event.requestContext.http.method
}

module.exports.getHeaders = (...args) => {
  const [event] = args
  return event.headers
}

module.exports.getBody = (...args) => {
  const [event] = args
  return JSON.parse(event.body)
}

module.exports.respond = (statusCode, responseBody) => {
  return {
    statusCode,
    body: JSON.stringify(responseBody),
    headers: {
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'OPTIONS,POST'
    }
  }
}

const getSecret = async name => {
  await initializeSecretsManagerClient()

  return new Promise((resolve, reject) => {
    secretsManager.getSecretValue({
      SecretId: `${uniqueStringAws}${name}`
    }, (err, data) => {
      if (err) {
        reject(err)
      } else {
        resolve(data.SecretString)
      }
    })
  })
}

const uploadFileToS3 = async (filename, content, client) => new Promise((resolve, reject) => {
  const bucketName = `upload-to-big3-${uniqueIdentifier}`

  client.putObject({
    Body: content,
    Bucket: bucketName,
    Key: filename
  }, (err) => {
    if (err) {
      reject(err)
    } else {
      resolve()
    }
  })
})

const initializeGcsClient = async gcpConfig => {
  if (gcs) {
    return
  }

  gcpConfig.credential_source = {
    environment_id: 'aws1',
    regional_cred_verification_url: 'https://sts.{region}.amazonaws.com?Action=GetCallerIdentity&Version=2011-06-15'
  }

  const authClient = ExternalAccountClient.fromJSON(gcpConfig)
  authClient.scopes = ['https://www.googleapis.com/auth/cloud-platform']

  gcs = new GoogleCloudStorage({ authClient })

  setTimeout(() => {
    gcs = undefined
  }, durationSeconds * 1000)
}

module.exports.uploadFile = async (filename, content) => {
  initializeS3Client()

  /*
  const [sas, gcpConfig] = await Promise.all([
    getSecret('/azure/sas'),
    getSecret('/gcp/config')
  ])
  */

  const storagePlatformsUploadedTo = ['AWS S3']
  const promises = [uploadFileToS3(filename, content, s3)]

  /*
  if (gcpConfig !== 'null') {
    await initializeGcsClient(JSON.parse(gcpConfig))

    storagePlatformsUploadedTo.push('Google Cloud Storage')

    promises.push(
      gcp.uploadFileToGcs(filename, content, gcs)
    )
  }
  */

  await Promise.all(promises)
  return storagePlatformsUploadedTo
}

module.exports.uploadFileToS3 = uploadFileToS3
