module Machinator
  class Room101 < RuntimeError ; end
  require 'yaml'
  
  class Obfuscator  
    def initialize ; end
    
    def neverspeak(item=nil, schema=nil)
      if item.nil? || !(item.is_a?(String) || item.is_a?(File)) || schema.nil?
        # look for a .machinator file
        raise Room101, "no valid resource specified" 
      end

      if item.is_a?(File) || File.exist?(item)
        if !File.directory?(item)
          obfuscate_file(item, schema["words"]) if schema["words"]
        else
          # obfuscate for every file in directory
          obfuscate_file_name(item, schema["names"])
        end
      else
        new_item = String.new(item)
        mask(schema["words"], new_item) if schema["words"]
      end

      new_item
    end
    
    protected

    def mask(words, str)
      words.each { |key, value|
        str.gsub!(Regexp.new(key), value)
      }      
    end

    def obfuscate_file(file_path, words=nil)
      raise Room101, "invalid file to obfuscate" if !File.exists?(file_path)
      
      if words
        file_buffer = ""
        IO.foreach file_path do |line|
          file_buffer += line
        end

        mask(words, file_buffer)

        File.open(file_path, "w") do |aFile|
          aFile.syswrite(file_buffer)
        end
      end
    end
    
    def obfuscate_file_name
      
    end

  end
end
