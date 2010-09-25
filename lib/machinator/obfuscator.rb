module Machinator
  class Obfuscator
    require 'yaml'
    class SpecialException < RuntimeError ; end
    
    def self.some_method(resource=nil)
      YAML::load(resource)
    end

  end
end