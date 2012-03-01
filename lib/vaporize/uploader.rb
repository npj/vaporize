# annoyingly, AWS::S3 tampers with this value and sets it to
# 1MB. Make it smaller so we can log progress better.
module Net
  class HTTPGenericRequest
    def chunk_size
      Net::HTTPGenericRequest::BUFSIZE
    end
  end
end

module Vaporize
  class Uploader
    class ProgressFile < File    
      
      def initialize(log, *args)
        super(*args)
        if log
          @progress = ProgressBar.new(self.class.basename(path), lstat.size, log)
        end
      end
        
      def read(*args)
        @progress.set(tell) if @progress
        super(*args)
      end
    end
    
    def initialize(config)
      @config = config
      @db     = config.database
      
      @config.connect_s3!
    end
    
    def upload(path)
      
      return unless File.exists?(path)
      
      record     = @db.find(@config.relpath(path))
      updated_at = File.mtime(path).utc
      
      if record && updated_at <= record.updated_at
        @config.logger.puts("SKIP: #{path.inspect}")
      else
        @db.update(store(path), :bucket => @config.s3_bucket, :content_type => '', :updated_at => updated_at)
      end
    rescue AWS::S3::S3Exception
      return
    end
    
    protected
    
      def store(path)
        @config.relpath(path).tap do |key|
          AWS::S3::S3Object.store(key, ProgressFile.open(@config.logger, path), @config.s3_bucket)
          @config.logger.puts("STORE: #{path.inspect} at #{key.inspect} in bucket #{@config.s3_bucket.inspect}")
        end
      end
  end
end