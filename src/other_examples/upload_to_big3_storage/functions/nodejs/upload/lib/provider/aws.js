const AWS = require('aws-sdk')
const google = require('./google')
const GoogleCloudStorage = require('@google-cloud/storage').Storage
const { ExternalAccountClient } = require('google-auth-library')

const uniqueIdentifier = process.env.UNIQUE_IDENTIFIER
const googleConfig = process.env.GOOGLE_CLOUD_FEDERATION_CONFIGURATION
const durationSeconds = 3600
let s3
let gcs

const initializeS3Client = () => {
  if (!s3) {
    s3 = new AWS.S3()
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

const initializeGcsClient = async googleConfig => {
  if (gcs) {
    return
  }

  googleConfig.credential_source = {
    environment_id: 'aws1',
    regional_cred_verification_url: 'https://sts.{region}.amazonaws.com?Action=GetCallerIdentity&Version=2011-06-15'
  }

  const authClient = ExternalAccountClient.fromJSON(googleConfig)
  authClient.scopes = ['https://www.googleapis.com/auth/cloud-platform']

  gcs = new GoogleCloudStorage({ authClient })

  setTimeout(() => {
    gcs = undefined
  }, durationSeconds * 1000)
}

module.exports.uploadFile = async (filename, content) => {
  initializeS3Client()

  const storagePlatformsUploadedTo = ['AWS S3']
  const promises = [uploadFileToS3(filename, content, s3)]

  if (googleConfig !== 'null') {
    await initializeGcsClient(JSON.parse(googleConfig))

    storagePlatformsUploadedTo.push('Google Cloud Storage')

    promises.push(
      google.uploadFileToGcs(filename, content, gcs)
    )
  }

  await Promise.all(promises)
  return storagePlatformsUploadedTo
}

module.exports.uploadFileToS3 = uploadFileToS3
