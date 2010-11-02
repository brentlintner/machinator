require 'rubygems'
require 'fileutils'
require 'test/unit'
require File.expand_path("../../lib/machinator/obfuscator", __FILE__)

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
      msg = "no valid resource specified"
      
      begin
        @winston.neverspeak
      rescue Room101 => e
        caught = true
        caught_msg = e.message
      end
      
      assert_equal caught, true, "expected Room101"
      assert_equal msg, caught_msg, "expected '#{msg}' message"
    end

    def test_neverspeak_should_die_when_given_no_schema_or_existing_config_file
      caught = false
      msg = "no valid resource specified"

      file = File.open(THOUGHT, "w") do |aFile|
        aFile.syswrite("we are the dead")
      end

      begin
        @winston.neverspeak(file)
      rescue Room101 => e
        caught = true
        caught_msg = e.message
      end

      assert_equal caught, true, "expected Room101"
      assert_equal msg, caught_msg, "expected '#{msg}' message"
    end

    def test_neverspeak_should_die_when_given_empty_string
      caught = false
      msg = "no valid resource specified"
      begin
        @winston.neverspeak("", {})
      rescue Room101 => e
        caught = true
        caught_msg = e.message
      end
      assert_equal caught, true, "expected Room101"
      assert_equal msg, caught_msg, "expected '#{msg}' message"
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
      File.open(THOUGHT, "w") do |aFile|
        aFile.syswrite("telescreen")
      end
      
      @winston.neverspeak(THOUGHT, {
        "words" => {
          /telescreen/ => "watchscreen"
        }
      })
      
      assert_equal "watchscreen", File.new(THOUGHT).readline, "expected obfuscated file"
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

    def test_neverspeak_obfuscates_file_content_without_any_names
      File.open(POLICE, "w") do |aFile|
        aFile.syswrite("they will never find us")
      end

      @winston.neverspeak(OCEANIA, {
        "words" => {
          /will\snever\sfind/ => "watch"
        }
      })
      
      assert_equal "they watch us", File.new(POLICE).readline, "expected obfuscated file content"
    end

    def test_neverspeak_obfuscates_file_name_and_content
      File.open(THOUGHT, "w") do |aFile|
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

    def test_neverspeak_obfuscates_directory_name_string
      FileUtils.mkdir(THOUGHT)

      @winston.neverspeak(THOUGHT, {
        "names" => {
          /#{THOUGHT}$/ => POLICE
        }
      })
      
      assert File.exist?(POLICE) && File.directory?(POLICE) && !File.exist?(THOUGHT), "expected obfuscated file name"
    end

    def test_neverspeak_obfuscates_directory_name_file_obj
      FileUtils.mkdir(THOUGHT)

      @winston.neverspeak(File.open(THOUGHT), {
        "names" => {
          /#{THOUGHT}$/ => POLICE
        }
      })
      
      assert File.exist?(POLICE) && File.directory?(POLICE) && !File.exist?(THOUGHT), "expected obfuscated file name"
    end

    # TODO:
    # test for multi level dirs, running multiple obfuscations, bottom up approach verification
  end
end
