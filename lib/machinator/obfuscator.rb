module Machinator
  class Room101 < RuntimeError ; end
  require 'yaml'
  
  class Obfuscator  
    def initialize ; end
    
    def neverspeak(item=nil, schema=nil)
      if item.nil? || !(item.is_a?(String) || item.is_a?(File)) || schema.nil?
        raise Room101, "no valid resource specified" 
      end

      if item.is_a?(File) || File.exist?(item)
        obfuscate_file(item, schema)
      else
        new_item = String.new(item)
        mask(schema["words"], new_item)
      end

      new_item
    end
    
    protected

    def mask(words, str)
      words.each { |key, value|
        str.gsub!(Regexp.new(key), value)
      }      
    end

    def obfuscate_file(file_path, schema)
      raise Room101, "invalid file to obfuscate" if !File.exists?(file_path)

      file_buffer = ""
      IO.foreach file_path do |line|
        file_buffer += line
      end

      File.open(file_path, "w") do |aFile|
        mask(schema["words"], file_buffer)
        aFile.syswrite(file_buffer)
      end
    end
    
    #def obfuscate_path ; end

  end
end
