lib = File.join(File.dirname(__FILE__), %w(.. lib))
$:.unshift(lib) if File.exists?(lib) unless $:.member?(lib)

require 'rubygems'
require 'fileutils'
require 'test/unit'
require 'mocha'
require "#{lib}/machinator/obfuscator"

module Machinator
  THOUGHT = "thought"
  POLICE = "police"

  class ObfuscatorTest < Test::Unit::TestCase

    def setup
      @obfuscator = Obfuscator.new
    end
    
    def teardown
      File.delete(POLICE) if File.exists?(POLICE)
      File.delete(THOUGHT) if File.exists?(THOUGHT)
    end
    
    def test_neverspeak_should_die_when_given_nothing
      caught = false
      begin
        @obfuscator.neverspeak
      rescue Room101 => e
        caught = true
      end
      assert_equal caught, true, "expected a TypeError"
    end
    
    def test_neverspeak_returns_new_string_object
      str = "test"
      assert_not_equal str.object_id, @obfuscator.neverspeak(str, {"words" => {}}).object_id      
    end
    
    def test_neverspeak_obfuscates_a_string
      result = @obfuscator.neverspeak("the ministry of war fights eastasia and loves eurasia.", {
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
      
      @obfuscator.neverspeak(file_path, {
        "words" => {
          /telescreen/ => "watchscreen"
        }
      })
      
      assert_equal "watchscreen", File.new(file_path).readline, "expected obfuscated file"
      
      File.delete(file_path)
    end
    
    def test_neverspeak_obfuscates_file_name
      FileUtils.touch(THOUGHT)

      @obfuscator.neverspeak(File.dirname(__FILE__), {
        "names" => {
          /thought$/ => POLICE
        }
      })
      
      assert File.exist?(POLICE) && !File.exist(THOUGHT), "expected obfuscated file name"
    end

  end

end
