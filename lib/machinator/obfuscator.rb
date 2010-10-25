module Machinator
  class Room101 < StandardError ; end
  class Obfuscator  
    require 'yaml'
    
    NAMES, WORDS = "names", "words"

    def initialize
      @source, @schema = nil, nil
    end
    
    def neverspeak(source=nil, schema=nil)
      if source.nil? || schema.nil? ||
          !((source.is_a?(String) && source != "") || source.is_a?(File))
        # look for a .machinator file
        raise Room101, "no valid resource specified" 
      end

      @schema = schema
      @source = source
 
      if @source.is_a?(File) || File.exist?(@source)
        if !File.directory?(@source)
          obfuscate_file
          obfuscate_file_name
        else
          obfuscate_dir
        end
      else
        @source = String.new(@source)
        obfuscate_string
        return @source
      end
    end
    
    protected

    def obfuscate_string(source=@source)
      if @schema[WORDS].is_a?(Hash)
        @schema[WORDS].each { |key, value|
          source.gsub!(Regexp.new(key), value)
        }      
      end
    end

    def obfuscate_file(source=@source)
      raise Room101, "invalid file to obfuscate" if !File.exists?(@source)
      file_buffer = ""
      IO.foreach source do |line|
        file_buffer += line
      end
      obfuscate_string(file_buffer)
      File.open(source, "w") do |aFile|
        aFile.syswrite(file_buffer)
      end
    end
   
    def obfuscate_file_name(source=@source)
      if @schema[NAMES].is_a?(Hash)
        @schema[NAMES].each { |key, value|
          regex = Regexp.new(key)
          if regex =~ source          
            FileUtils.mv(source, source.gsub(regex, value))
            break
          end
        }         
      end
    end

    def obfuscate_dir(source=@source)
      recurse(source) do |full_path|
        if !File.directory?(full_path)
          obfuscate_file(full_path)
        end
        obfuscate_file_name(full_path)
      end
    end
    
    def recurse(dir, limit=20, &block)
      raise Room101, "recursive limit (20) reached" if limit <= 0
      dir_path = dir.is_a?(File) ? dir.path : dir
      Dir.foreach(dir_path) do |dir_item|
        full_path = File.join(dir_path, dir_item)
        if dir_item !~ /^\.\.?$/
          if File.directory?(full_path) 
            recurse(full_path, limit - 1, &block)
          end
          yield(full_path) 
        end
      end
      yield(dir_path)
    end 

  end
end
