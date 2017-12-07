resource_name :azure_resource_group
property :location, String, required: true
property :subscription_id, String, required: true
property :azure_environment, String, default: 'AzureCloud'
property :name, String, name_property: true
property :tags, Hash, default: {}

include Azure::Common
include Azure::Resources::Profiles::Latest::Mgmt::Models

action :create do
  resource_management_client = resource_management_client_for(new_resource.subscription_id, new_resource.azure_environment)
  resource_group = ResourceGroup.new
  resource_group.location = new_resource.location
  resource_group.tags = new_resource.tags
  converge_by("Create or Update Resource Group: #{new_resource.name}") do
    resource_management_client.resource_groups.create_or_update(new_resource.name, resource_group)
  end
end

action :delete do
  resource_management_client = resource_management_client_for(new_resource.subscription_id, new_resource.azure_environment)
  if resource_management_client.resource_groups.check_existence(name)
    converge_by("Delete Resource Group: #{name}") do
      resource_management_client.resource_groups.delete(name)
    end
  end
end
