const provider = require('./lib/provider')

module.exports = async (...args) => {
  const requiredApiKey = process.env.API_KEY
  const method = provider.getMethod(...args)
  const headers = provider.getHeaders(...args)

  if (method === 'OPTIONS') {
    return provider.respond(200, undefined, ...args)
  } else if (method !== 'POST') {
    return provider.respond(405, undefined, ...args)
  }

  let statusCode = 200
  let responseBody

  if (headers['x-api-key'] !== requiredApiKey) {
    statusCode = 403

    responseBody = {
      err: 'Forbidden'
    }
  } else {
    try {
      const { content, filename } = provider.getBody(...args)
  
      const storagePlatformsUploadedTo = await provider.uploadFile(filename, content)
  
      responseBody = {
        message: `File uploaded successfully to the following providers: ${storagePlatformsUploadedTo.join(', ')}`
      }
    } catch (err) {
      statusCode = 400
  
      responseBody = {
        err: err instanceof Error ? err.toString() : err
      }
    }
  }

  return provider.respond(statusCode, responseBody, ...args)
}

// Export the function as the package and as a function named "handler" on the package.
module.exports.handler = module.exports
