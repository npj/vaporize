module Vaporize
  module Utils
    
    def self.shift(path)
      File.join(path.split(File::SEPARATOR).reject(&:empty?).drop(1))
    end
    
    def self.relpath(parent, child)
      return child if parent.empty?
      relpath(shift(parent), shift(child))
    end
  end
end