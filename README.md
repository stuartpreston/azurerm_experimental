# azurerm_experimental

Library cookbook to provide a convenient way to create resources via Azure Resource Manager.

_This cookbook is experimental and designed to serve as an example replacement mechanism for functionality previously available in `chef-provisioning-azurerm` which is no longer under active development._

## Requirements

### Platforms

All platforms with a chef-client package on downloads.chef.io

### Chef

Chef 13+

## Configuration

This cookbook is designed to be run on a node.  It utilizes the `~/.azure/credentials` file, or environment variables in the same way the Test Kitchen and other Azure utilities for Chef operate.  [Full details](https://github.com/test-kitchen/kitchen-azurerm#configuration) 

## Usage

Consume this library cookbook in the usual way from a wrapper, in your *metadata.rb*:

```ruby
depends 'azurerm_experimental'
```

## Examples

### Create a resource group in a specified subscription and location, and execute an inline ARM template:

```ruby
azure_resource_group 'sp-test-rg001' do
  subscription_id '43706c4e-b31d-425e-b5f5-e64e6bf63ac4'
  location 'westeurope'
  action :create
end

azure_resource_group_deployment 'my-deployment' do
  subscription_id '43706c4e-b31d-425e-b5f5-e64e6bf63ac4'
  location 'westeurope'
  resource_group 'sp-test-rg001'
  template <<-EOARM
  {
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "resources": [],
    "outputs": {
      "result": {
        "value": "Hello World",
        "type" : "string"
      }
    }
  }
  EOARM
  parameters nil
end
```

### Create a resource group in a specified subscription and location, and execute a ARM template from a file with parameters:

```ruby
azure_resource_group 'sp-test-rg001' do
  subscription_id '43706c4e-b31d-425e-b5f5-e64e6bf63ac4'
  location 'westeurope'
  action :create
end

azure_resource_group_deployment 'my-deployment' do
  subscription_id '43706c4e-b31d-425e-b5f5-e64e6bf63ac4'
  location 'uksouth'
  resource_group 'sp-test-rg001'
  template "#{Chef::Config[:cookbook_path]}/azurerm_experimental/files/azure_deploy.json"
  parameters myteststring: 'value',
             mytest2: 'value2'
end
```


## Maintainers

[Stuart Preston](stuart@chef.io)

## License

```text
Copyright:: 2017, Chef Software

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```