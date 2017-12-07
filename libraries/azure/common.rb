require 'azure_mgmt_resources'
require 'inifile'

module Azure
  module Common
    include Azure::Resources::Profiles::Latest::Mgmt
    include Azure::Resources::Profiles::Latest::Mgmt::Models

    DEFAULT_CONFIG_PATH = "#{ENV['HOME']}/.azure/credentials".freeze

    #
    # Retrieves a [MsRest::TokenCredentials] object containing settings to use for the given cloud.
    # @param tenant_id [String] The tenant_id of the Azure directory to retrieve settings for
    # @param client_id [String] The client_id of a Service Principal that has access to the specified tenant
    # @param client_secret [String] The client_secret for the Service Principal
    # @azure_environment [String] The cloud environment to use (default: 'AzureCloud')
    #
    # @return [MsRest::TokenCredentials] TokenCredentials object containing settings for subsequent requests
    #
    def token_credentials_for(tenant_id, client_id, client_secret, azure_environment = 'AzureCloud')
      Chef::Log.debug("Retrieving token for Service Principal: #{client_id}, environment: #{azure_environment}")
      settings = settings_for_azure_environment(azure_environment)
      Chef::Log.debug("Settings for Azure Environment: #{azure_environment} #{settings.inspect}")
      token_provider = ::MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, client_secret, settings)
      Chef::Log.debug("Retrieved token: #{token_provider.inspect}")
      ::MsRest::TokenCredentials.new(token_provider)
    end

    #
    # Retrieves a [MsRestAzure::ActiveDirectoryServiceSettings] object representing the settings for the given cloud.
    # @param azure_environment [String] The Azure environment to retrieve settings for.
    #
    # @return [MsRestAzure::ActiveDirectoryServiceSettings] Settings to be used for subsequent requests
    #
    def settings_for_azure_environment(azure_environment)
      case azure_environment.downcase
      when 'azureusgovernment'
        ::MsRestAzure::ActiveDirectoryServiceSettings.get_azure_us_government_settings
      when 'azurechina'
        ::MsRestAzure::ActiveDirectoryServiceSettings.get_azure_china_settings
      when 'azuregermancloud'
        ::MsRestAzure::ActiveDirectoryServiceSettings.get_azure_germany_settings
      else
        ::MsRestAzure::ActiveDirectoryServiceSettings.get_azure_settings
      end
    end

    #
    # Creates a resource management client for the specified user
    # @param tenant_id [String] The tenant_id of the Azure directory to retrieve settings for
    # @param client_id [String] The client_id of a Service Principal that has access to the specified tenant
    # @param client_secret [String] The client_secret for the Service Principal
    # @azure_environment [String] The cloud environment to use
    #
    # @return [Azure::ARM::Resources::ResourceManagementClient] new ResourceManagementClient
    #
    def resource_management_client_for(subscription_id, azure_environment)
      config_file = ENV['AZURE_CONFIG_FILE'] || File.expand_path(DEFAULT_CONFIG_PATH)
      if File.file?(config_file)
        credentials = IniFile.load(File.expand_path(config_file))
      else
        warn "#{config_file} was not found or not accessible. Using environment variables if they are available."
      end
      warn "Credentials for subscription: #{subscription_id} were not found in #{config_file}." if credentials[subscription_id].nil?
      tenant_id = ENV['AZURE_TENANT_ID'] || credentials[subscription_id]['tenant_id']
      client_id = ENV['AZURE_CLIENT_ID'] || credentials[subscription_id]['client_id']
      client_secret = ENV['AZURE_CLIENT_SECRET'] || credentials[subscription_id]['client_secret']
      options = {
        tenant_id: tenant_id,
        client_id: client_id,
        client_secret: client_secret,
        subscription_id: subscription_id,
        credentials: token_credentials_for(tenant_id, client_id, client_secret, azure_environment),
      }
      Client.new(options)
    end
  end
end
