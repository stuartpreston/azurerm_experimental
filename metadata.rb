name 'azurerm_experimental'
maintainer 'Stuart Preston'
maintainer_email 'stuart@chef.io'
license 'Apache-2.0'
description 'AzureRM-experimental'
long_description 'Installs/Configures the AzureRM experimental cookbook'
version '0.11.0'
chef_version '>= 12.8' if respond_to?(:chef_version)
issues_url 'https://github.com/stuartpreston/azurerm_experimental/issues'
source_url 'https://github.com/stuartpreston/azurerm_experimental'

supports 'windows'

gem 'azure_mgmt_resources', '~>0.15.1'
gem 'inifile'
