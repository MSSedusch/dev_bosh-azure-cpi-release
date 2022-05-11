#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('/workspaces/dev_bosh-azure-cpi-release/bosh-azure-cpi-release/src/bosh_azure_cpi/lib', __dir__)

require 'bosh_azure_cpi'
require 'irb'
require 'irb/completion'
require 'ostruct'
require 'optparse'
require 'securerandom'


config_file = nil

opts_parser = OptionParser.new do |opts|
  opts.on('-c', '--config FILE') { |file| config_file = file }
end

opts_parser.parse!

unless config_file
  puts opts_parser
  exit(1)
end

@config = Psych.load_file(config_file)

module ConsoleHelpers
  def cpi
    @cpi ||= Bosh::AzureCloud::Cloud.new(@config, 1)
  end

  def registry
    cpi.registry
  end
end

cloud_config = OpenStruct.new(logger: Bosh::AzureCloud::CPILogger.get_logger(STDOUT))

Bosh::Clouds::Config.configure(cloud_config)

include ConsoleHelpers

@logger = Bosh::Clouds::Config.logger
@azure_client            = Bosh::AzureCloud::AzureClient.new(cpi.config.azure, @logger)

agent_id = "2a0f4861-291b-449d-9517-e003e2f72f71"

# puts "Run test with 2 ASGs"
# agent_id = SecureRandom.uuid
# stemcell_id = "bosh-stemcell-8d149245-82d5-4c93-9d00-66e9e54bee88"
# resource_pool = JSON('{"instance_type":"Standard_D2s_v3"}')
# networks = JSON('
#   {
#     "private": {
#       "cloud_properties": {
#         "application_security_groups":[
#           "asg1",
#           "asg2"
#         ],
#         "subnet_name": "bosh",
#         "virtual_network_name": "bosh-vnet"
#       },
#       "default": [
#         "dns",
#         "gateway"
#       ],
#       "dns": [
#         "168.63.129.16",
#         "8.8.8.8"
#       ],
#       "gateway": "10.0.0.1",
#       "netmask": "255.255.255.0",
#       "type": "dynamic"
#     }
#   }')
# instance_id = cpi.create_vm(agent_id, stemcell_id, resource_pool, networks)

# puts "Run test with 2 ASGs done - verifying"
# nic = @azure_client.get_network_interface_by_name(cpi.config.azure.resource_group_name, agent_id + "-0")

# if nic[:application_security_groups].count != 2
#   puts "Run test with 2 ASGs done - verifying FAILED!!!. Expected count == 2 but are " + nic[:application_security_groups].count
# end

# asg1Id = "/subscriptions/" + cpi.config.azure.subscription_id + "/resourceGroups/" + cpi.config.azure.resource_group_name + "/providers/Microsoft.Network/applicationSecurityGroups/asg1"
# asg2Id = "/subscriptions/" + cpi.config.azure.subscription_id + "/resourceGroups/" + cpi.config.azure.resource_group_name + "/providers/Microsoft.Network/applicationSecurityGroups/asg2"
# if (nic[:application_security_groups][0][:id] != asg1Id) && (nic[:application_security_groups][0][:id] != asg2Id)
#   puts "Run test with 2 ASGs done - verifying FAILED!!!. Expected IDs do not match!"
# end
# if (nic[:application_security_groups][1][:id] != asg1Id) && (nic[:application_security_groups][1][:id] != asg2Id)
#   puts "Run test with 2 ASGs done - verifying FAILED!!!. Expected IDs do not match!"
# end

# puts "Run test with 2 ASGs done - verifying done"



# puts "Run test with 1 ASGs"
# agent_id = SecureRandom.uuid
# stemcell_id = "bosh-stemcell-8d149245-82d5-4c93-9d00-66e9e54bee88"
# resource_pool = JSON('{"instance_type":"Standard_D2s_v3"}')
# networks = JSON('
#   {
#     "private": {
#       "cloud_properties": {
#         "application_security_groups":[
#           "asg1"
#         ],
#         "subnet_name": "bosh",
#         "virtual_network_name": "bosh-vnet"
#       },
#       "default": [
#         "dns",
#         "gateway"
#       ],
#       "dns": [
#         "168.63.129.16",
#         "8.8.8.8"
#       ],
#       "gateway": "10.0.0.1",
#       "netmask": "255.255.255.0",
#       "type": "dynamic"
#     }
#   }')
# instance_id = cpi.create_vm(agent_id, stemcell_id, resource_pool, networks)

# puts "Run test with 1 ASGs done - verifying"
# nic = @azure_client.get_network_interface_by_name(cpi.config.azure.resource_group_name, agent_id + "-0")

# if nic[:application_security_groups].count != 1
#   puts "Run test with 1 ASGs done - verifying FAILED!!!. Expected count == 1 but are " + nic[:application_security_groups].count
# end

# asg1Id = "/subscriptions/" + cpi.config.azure.subscription_id + "/resourceGroups/" + cpi.config.azure.resource_group_name + "/providers/Microsoft.Network/applicationSecurityGroups/asg1"
# if (nic[:application_security_groups][0][:id] != asg1Id) && (nic[:application_security_groups][0][:id] != asg2Id)
#   puts "Run test with 1 ASGs done - verifying FAILED!!!. Expected IDs do not match!"
# end

# puts "Run test with 1 ASGs done - verifying done"



puts "Run test with 0 ASGs"
agent_id = SecureRandom.uuid
stemcell_id = "bosh-stemcell-8d149245-82d5-4c93-9d00-66e9e54bee88"
resource_pool = JSON('{"instance_type":"Standard_D2s_v3"}')
networks = JSON('
  {
    "private": {
      "cloud_properties": {
        "application_security_groups":[
        ],
        "subnet_name": "bosh",
        "virtual_network_name": "bosh-vnet"
      },
      "default": [
        "dns",
        "gateway"
      ],
      "dns": [
        "168.63.129.16",
        "8.8.8.8"
      ],
      "gateway": "10.0.0.1",
      "netmask": "255.255.255.0",
      "type": "dynamic"
    }
  }')
instance_id = cpi.create_vm(agent_id, stemcell_id, resource_pool, networks)

puts "Run test with 0 ASGs done - verifying"
nic = @azure_client.get_network_interface_by_name(cpi.config.azure.resource_group_name, agent_id + "-0")

if nic[:application_security_groups] != nil && nic[:application_security_groups].count != 0
  puts "Run test with 0 ASGs done - verifying FAILED!!!. Expected count == 0 but are " + nic[:application_security_groups].count
end

puts "Run test with 0 ASGs done - verifying done"