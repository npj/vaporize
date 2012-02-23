module Vaporize
  class Poller
    
    attr_accessor :running
    
    def initialize(config, &block)
      @config  = config
      @block   = block
      @running = true
    end
    
    def poll
      while running
        @config.dir.rewind
        process(@config.dir, &@block)
        sleep(@config.interval)
      end
    end
    
    private
    
      def datafile?(path)
        @config.datafile?(path)
      end
    
      def process(dir, &block)
        dir.entries.each do |entry|
          
          break unless running
          
          next if entry == "." || entry == ".."
          
          path = File.join(dir.path, entry)
          
          next if datafile?(path)
          
          if File.directory?(path)
            process(Dir.open(path), &block)
          else
            block.call(path)
          end
        end
      end
    
  end
end