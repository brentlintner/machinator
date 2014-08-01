module Machinator
  class Room101 < StandardError ; end
  class Obfuscator
    require 'yaml'

    def initialize
      @block, @source, @schema = nil
    end

    def neverspeak(source, schema=nil, &block)
      @schema = schema
      @source = source
      @block = block

      if @schema.nil?
        config = File.join(File.directory?(@source) ? @source : File.dirname(@source), ".machinator")
        if !File.exists?(config)
          raise Room101, "no schema specified and no .machinator file was found."
        end
        @schema = YAML::load(File.open(config))
      end

      if @source.is_a?(File) || File.exist?(@source)
        if !File.directory?(@source)
          if !@block || @block.call(source)
            obfuscate_file
            obfuscate_file_name
          end
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
      @schema["words"].each { |key, value|
        source.gsub!(Regexp.new(key), value)
      } if @schema["words"].is_a?(Hash)
    end

    def obfuscate_file(source=@source)
      raise Room101, "could not find file to obfuscate (#{source})" if !File.exists?(@source)
      file_buffer = ""
      IO.foreach(source) { |line| file_buffer << line }
      obfuscate_string(file_buffer)
      File.open(source, "w") { |file| file.syswrite(file_buffer) }
    end

    def obfuscate_file_name(source=@source)
      @schema["names"].each { |key, value|
        if (regex = Regexp.new(key)) =~ source
          FileUtils.mv(source, source.gsub(regex, value)) ; break
        end
      } if @schema["names"].is_a?(Hash)
    end

    def obfuscate_dir(source=@source)
      recurse(source) { |full_path|
        if !@block || @block.call(full_path)
          obfuscate_file(full_path) if !File.directory?(full_path)
          obfuscate_file_name(full_path)
        end
      }
    end

    def recurse(dir, limit=20, &block)
      raise Room101, "recursive limit (20) reached" if limit <= 0
      actual_path = dir.is_a?(File) ? dir.path : dir
      Dir.foreach(actual_path) { |item|
        full_path = File.join(actual_path, item)
        if item !~ /^\.\.?$/
          if File.directory?(full_path)
            recurse(full_path, limit - 1, &block)
          end
          yield(full_path)
        end
      }
      yield(actual_path)
    end
  end
end
