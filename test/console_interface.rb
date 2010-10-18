lib = File.join(File.dirname(__FILE__), %w(.. lib))
$:.unshift(lib) if File.exists?(lib) unless $:.member?(lib)

require 'rubygems'
require 'fileutils'
require 'test/unit'
require 'mocha'
require "#{lib}/machinator/obfuscator"
require "#{lib}/machinator/console_interface"

module Machinator
  class ConsoleInterfaceTest < Test::Unit::TestCase

    def setup
      @interface = ConsoleInterface.new
    end
    
    def teardown
    end

    def test_responds_to_help
      ConsoleInterface.any_instance.expects(:peace_out).with(is_a(String)).once
      @interface.interpret(["-h"])
    end

    def test_responds_to_version
      ConsoleInterface.any_instance.expects(:peace_out).with(is_a(String)).once
      @interface.interpret(["-v"])
    end
  end
end 
