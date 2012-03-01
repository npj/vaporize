module Vaporize
  class Syncer
    def initialize(config)
      @config = config
      @db     = @config.database
      
      @config.connect_s3!
    end
    
    def sync
      
      @db.reset
      
      marker = nil
      begin
        objects = AWS::S3::Bucket.objects(@config.s3_bucket, :marker => marker)
        objects.each do |object|
          store(object)
          marker = object.key
        end
      end until(objects.empty?)
    end
    
    def store(object)
      
      params = { 
        :bucket       => @config.s3_bucket, 
        :content_type => object.about['content-type'],
        :updated_at   => Time.parse(object.about['last-modified']).utc
      }
      
      @db.update(object.key, params)
      
      @config.logger.puts "SYNC: " + ([ object.key ] + params.values).inspect
    end
  end
end