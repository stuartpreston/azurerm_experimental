resource_name :azure_resource_group_deployment
property :location, String, required: true
property :subscription_id, String, required: true
property :azure_environment, String, default: 'AzureCloud'
property :name, String, name_property: true
property :resource_group, String
property :template, String
property :parameters, Hash
property :mode, String, default: 'Incremental'

include Azure::Common
include Azure::Resources::Profiles::Latest::Mgmt::Models

action :deploy do
  resource_management_client = resource_management_client_for(new_resource.subscription_id, new_resource.azure_environment)
  deployment_properties = DeploymentProperties.new
  deployment_properties.template = if ::File.file?(new_resource.template)
                                     JSON.parse(::File.read(new_resource.template))
                                   else
                                     JSON.parse(new_resource.template)
                                   end
  deployment_properties.parameters = new_resource.parameters.map { |key, value| { key.to_sym => { 'value' => value } } }.reduce(:merge!) unless new_resource.parameters.nil?

  deployment_properties.mode = new_resource.mode

  deployment = Deployment.new
  deployment.properties = deployment_properties

  converge_by("Create or Update Deployment: #{new_resource.name}") do
    this_deployment = resource_management_client.deployments.create_or_update(new_resource.resource_group, new_resource.name, deployment)
    log "Azure deployment result: #{this_deployment.properties.outputs.to_json}" do
      not_if this_deployment.properties.outputs.nil?
    end
  end
end
