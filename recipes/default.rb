azure_resource_group 'sp-test-rg001' do
  subscription_id '43706c4e-b31d-425e-b5f5-e64e6bf63ac4'
  location 'uksouth'
  action :create
end

azure_resource_group_deployment 'my-deployment' do
  subscription_id '43706c4e-b31d-425e-b5f5-e64e6bf63ac4'
  location 'uksouth'
  resource_group 'sp-test-rg001'
  template "#{Chef::Config[:cookbook_path]}/azurerm_experimental/files/azure_deploy.json"
  # template <<-EOARM
  # {
  #   "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  #   "contentVersion": "1.0.0.0",
  #   "parameters": {},
  #   "variables": {},
  #   "resources": [],
  #   "outputs": {
  #     "result": {
  #       "value": "Hello World",
  #       "type" : "string"
  #     }
  #   }
  # }
  # EOARM
  # parameters myteststring: 'value',
  #            mytest2: 'value2'
end
