lib = File.join(File.dirname(__FILE__), %w(.. lib))
$:.unshift(lib) if File.exists?(lib) unless $:.member?(lib)

require 'rubygems'
require 'fileutils'
require 'test/unit'
require "#{lib}/machinator/obfuscator"

module Machinator
  OCEANIA = "the_absolute"
  THOUGHT = "the_absolute/thought"
  POLICE = "the_absolute/police"

  class ObfuscatorTest < Test::Unit::TestCase

    def setup
      @winston = Obfuscator.new
      FileUtils.mkdir(OCEANIA)
    end
    
    def teardown
      FileUtils.remove_dir(OCEANIA, true)
    end
    
    def test_neverspeak_should_die_when_given_nothing
      caught = false
      begin
        @winston.neverspeak
      rescue Room101 => e
        caught = true
      end
      assert_equal caught, true, "expected a TypeError"
    end
    
    def test_neverspeak_returns_new_string_object
      str = "some test string"
      assert_not_equal str.object_id, @winston.neverspeak(str, {"words" => {}}).object_id      
    end
    
    def test_neverspeak_obfuscates_a_string
      result = @winston.neverspeak("the ministry of war fights eastasia and loves eurasia.", {
        "words" => { 
          /fights\seastasia/ => "loves eastasia",          
          /ministry\sof\swar/ => "ministry of peace",          
          /loves\seurasia/ => "fights eurasia"
        }
      })
      
      assert_equal result, "the ministry of peace loves eastasia and fights eurasia."
    end
    
    def test_neverspeak_obfuscates_file
      file_path = THOUGHT
      
      File.open(file_path, "w") do |aFile|
        aFile.syswrite("telescreen")
      end
      
      @winston.neverspeak(file_path, {
        "words" => {
          /telescreen/ => "watchscreen"
        }
      })
      
      assert_equal "watchscreen", File.new(file_path).readline, "expected obfuscated file"
    end
    
    def test_neverspeak_obfuscates_file_name
      FileUtils.touch(THOUGHT)

      @winston.neverspeak(OCEANIA, {
        "names" => {
          /#{THOUGHT}$/ => POLICE
        }
      })
      
      assert File.exist?(POLICE) && !File.exist?(THOUGHT), "expected obfuscated file name"
    end

    def test_neverspeak_obfuscates_file_name_and_content
      file_path = THOUGHT
      
      File.open(file_path, "w") do |aFile|
        aFile.syswrite("love conquers all")
      end

      @winston.neverspeak(OCEANIA, {
        "words" => {
          /conquers\sall/ => "big brother"
        },
        "names" => {
          /#{THOUGHT}$/ => POLICE
        }
      })
      
      assert File.exist?(POLICE) && !File.exist?(THOUGHT), "expected obfuscated file name"
      assert_equal "love big brother", File.new(POLICE).readline, "expected obfuscated file"
    end

  end
end
