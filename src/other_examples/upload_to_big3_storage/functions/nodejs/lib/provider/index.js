const aws = require('./aws')
const azure = require('./azure')
const gcp = require('./gcp')
const providers = { aws, azure, gcp }

const getProviderName = () => {
  if (process.env.AWS_LAMBDA_FUNCTION_VERSION) {
    return 'aws'
  } else if (process.env.APPSETTING_AzureWebJobsStorage) {
    return 'azure'
  } else if (process.env.GCF_BLOCK_RUNTIME_nodejs6 || process.env.GAE_RUNTIME) {
    return 'gcp'
  } else {
    throw new Error(`Provider not detected. Environment variables: ${JSON.stringify(process.env)}`)
  }
}

const providerName = getProviderName()
const provider = providers[providerName]
provider.getProviderName = getProviderName

module.exports = provider
