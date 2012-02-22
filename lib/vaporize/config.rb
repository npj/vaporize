require 'singleton'

module Vaporize
  class Config
    
    attr_accessor :verbose
    attr_reader :dir, :interval, :daemonize, :datafile, :s3_key, :s3_secret, :s3_bucket
    
    def initialize(args = { })
      @dir       = self.class.validate_directory(args['directory'])
      @interval  = self.class.validate_interval(args['interval'] || 1)
      @daemonize = self.class.validate_daemonize(args['daemonize'] || "no")
      @datafile  = File.join(@dir.path, (args['datafile'] || "vaporize.db"))
      @s3_key    = self.class.validate_s3_key(args['s3_key'])
      @s3_secret = self.class.validate_s3_secret(args['s3_secret'])
      @s3_bucket = self.class.validate_s3_bucket(args['s3_bucket'])
    end
    
    def logger
      if verbose
        $stdout
      else
        Object.new.tap { |obj| class << obj; def puts(*args); end; end }
      end
    end
    
    def datafile?(path)
      relpath(path) == relpath(@datafile)
    end
    
    def relpath(path)
      Vaporize::Utils.relpath(@dir.path, path)
    end
    
    private
    
      def self.validate_directory(dir)
        if dir.start_with?(File::SEPARATOR)
          return Dir.open(dir)
        else
          return Dir.open(File.expand_path(dir))
        end
      end
    
      def self.validate_interval(interval)
        interval.to_i.tap { |i| raise "interval must be greter than zero" unless i > 0 }
      end
      
      def self.validate_daemonize(daemonize)
        daemonize == "yes"
      end
      
      def self.validate_datadir(path)
        unless File.directory?(path)
          raise "datadir: not a directory"
        end
        
        return path
      end
      
      def self.validate_s3_key(key)
        raise("s3_key not given") unless key
        return key
      end
      
      def self.validate_s3_secret(secret)
        raise("s3_secret not given") unless secret
        return secret
      end
      
      def self.validate_s3_bucket(bucket)
        raise("s3_bucket not given") unless bucket
        return bucket
      end
  end
end