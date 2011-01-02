require 'rubygems'
require 'fileutils'
require 'test/unit'
require 'mocha'
require File.expand_path("../../lib/machinator/obfuscator", __FILE__)
require File.expand_path("../../lib/machinator/console_interface", __FILE__)

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

    # TODO
    # add options for command line obfuscation
  end
end 
