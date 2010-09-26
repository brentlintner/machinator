lib = File.join(File.dirname(__FILE__), %w(.. lib))
$:.unshift(lib) if File.exists?(lib) unless $:.member?(lib)

require 'rubygems'
require 'fileutils'
require 'test/unit'
require 'mocha'
require "#{lib}/machinator/obfuscator"

module Machinator
  class ObfuscatorTest < Test::Unit::TestCase
  
    def setup
      @obfuscator = Obfuscator.new
    end
    
    def teardown
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
      assert_not_equal str.object_id, @obfuscator.neverspeak(str).object_id      
    end
    
    def test_neverspeak_should_obfuscate_a_string
      result = @obfuscator.neverspeak("the ministry of war fights eastasia and loves eurasia.", {        
        /fights\seastasia/ => "loves eastasia",          
        /ministry\sof\swar/ => "ministry of love",          
        /loves\seurasia/ => "fights eurasia"          
      })
      
      assert_equal result, "the ministry of love loves eastasia and fights eurasia."
    end
    
    
    def test_neverspeak_file_changes_file
      file_path = "test.txt"
      
      File.open(file_path, "w") do |aFile|
        aFile.syswrite("telescreen")
      end
      
      @obfuscator.neverspeak_file(file_path, {
        /telescreen/ => "watchscreen"  
      })
      
      file_buffer = ""
      IO.foreach file_path do |line|
        file_buffer += line
      end
      
      assert_equal "watchscreen", file_buffer, "expected obfuscated file"
      
      File.delete(file_path)
    end
    
  end
end
