#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'bosh_azure_cpi'
require 'irb'
require 'irb/completion'
require 'ostruct'
require 'optparse'


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

agent_id = "2a0f4861-291b-449d-9517-e003e2f72f71"
stemcell_id = "bosh-stemcell-8d149245-82d5-4c93-9d00-66e9e54bee88"
resource_pool = JSON('{"instance_type":"Standard_D2s_v3", "load_balancer": "lb1"}')
networks = JSON('
  {
    "private": {
      "cloud_properties": {
        "subnet_name": "bosh",
        "virtual_network_name": "boshnet"
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
      "ip": "10.0.0.42",
      "netmask": "255.255.255.0",
      "type": "manual"
    }
  }')
instance_id = cpi.create_vm(agent_id, stemcell_id, resource_pool, networks)