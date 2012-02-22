require 'trollop'
require 'aws/s3'
require 'sqlite3'
require 'vaporize/utils'
require 'vaporize/config'
require 'vaporize/database'
require 'vaporize/poller'
require 'vaporize/uploader'

$poller = nil

def stop
  puts "stopping..."
  $poller.running = false
end

Signal.trap("INT") do
  stop
end

Signal.trap("TERM") do
  stop
end

module Vaporize
  def self.run
    
    options = Trollop::options do
      opt :config,  "Path to config file", :type => :string
      opt :verbose, "See verbose output"
    end
        
    unless options[:config] && File.exists?(file = File.expand_path(options[:config]))
      Trollop::die :config, "must point to a configuration file" 
    end
    
    config = Config.new(YAML.load(File.read(file)))
    
    config.verbose = options[:verbose]
      
    uploader = Uploader.new(config)
      
    $poller = Poller.new(config) do |path|
      uploader.upload(path)
    end
    
    $poller.poll
  end
end