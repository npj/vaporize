module Vaporize
  class Uploader
    def initialize(config)
      @config = config
      @db     = Database.new(config.datafile)
      
      AWS::S3::Base.establish_connection!({
        :access_key_id     => config.s3_key,
        :secret_access_key => config.s3_secret
      })
    end
    
    def upload(path)
      
      return unless File.exists?(path)
      
      record     = @db.find(@config.relpath(path))
      updated_at = File.mtime(path)
      
      unless record && updated_at <= record.updated_at
        @db.update(do_upload(path), :bucket => @config.s3_bucket, :updated_at => updated_at)
      end
    rescue AWS::S3::S3Exception
      return
    end
    
    protected
    
      def do_upload(path)
        @config.relpath(path).tap do |key|
          AWS::S3::S3Object.store(key, File.open(path), @config.s3_bucket)
          @config.logger.puts("STORED #{path.inspect} at #{key.inspect} in bucket #{@config.s3_bucket.inspect}")
        end
      end
  end
end