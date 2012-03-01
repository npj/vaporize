require 'trollop'
require 'aws/s3'
require 'sqlite3'
require 'progressbar'
require 'vaporize/utils'
require 'vaporize/config'
require 'vaporize/database'
require 'vaporize/poller'
require 'vaporize/syncer'
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
  
  def self.sync_remote(config)
    Syncer.new(config).sync
  end
  
  def self.run_poller(config)
    uploader = Uploader.new(config)
      
    $poller = Poller.new(config) do |path|
      uploader.upload(path)
    end
    
    $poller.poll
  end
  
  def self.run
    
    options = Trollop::options do
      opt :config,      "Path to config file", :type => :string
      opt :sync_remote, "Clear the database and repopulate with remote data"
      opt :verbose,     "See verbose output"
    end
        
    unless options[:config] && File.exists?(file = File.expand_path(options[:config]))
      Trollop::die :config, "must point to a configuration file" 
    end
    
    config = Config.from_file(file)
    
    config.verbose = options[:verbose]
    
    if options[:sync_remote]
      sync_remote(config)
    else
      run_poller(config)
    end
  end
end