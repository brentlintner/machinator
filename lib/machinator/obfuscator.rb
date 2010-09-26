module Machinator
  class Room101 < RuntimeError ; end
  require 'yaml'
  
  class Obfuscator  
    def initialize
    end
    
    def neverspeak(item=nil, schema={})
      raise Room101, "no resource specified" if item.nil?
      
      new_item = String.new(item)
      
      schema.each { |key, value|
        new_item.gsub!(Regexp.new(key), value)
      }
      
      return new_item
    end
    
    def neverspeak_file(file_path, schema=nil)
      raise Room101, "invalid file to obfuscate" if !File.exists?(file_path)

      file_buffer = ""
      
      IO.foreach file_path do |line|
        file_buffer += line
      end
      
      File.open(file_path, "w") do |aFile|
        aFile.syswrite neverspeak(file_buffer, schema)
      end
      
      return file_buffer
    end

  end
end