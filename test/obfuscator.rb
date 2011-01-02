require 'rubygems'
require 'fileutils'
require 'test/unit'
require File.expand_path("../../lib/machinator/obfuscator", __FILE__)

module Machinator
  OCEANIA = "the_absolute"
  THOUGHT = "the_absolute/thought"
  POLICE = "the_absolute/police"
  CONFIG = "the_absolute/.machinator"

  class ObfuscatorTest < Test::Unit::TestCase

    # to mock or not to mock...
    def setup
      @winston = Obfuscator.new
      FileUtils.mkdir(OCEANIA)
    end
    
    def teardown
      FileUtils.remove_dir(OCEANIA, true)
    end
    
    def test_should_die_when_given_nothing
      caught = false
      
      begin
        @winston.neverspeak
      rescue ArgumentError => e
        caught = true
      end
      
      assert_equal caught, true, "expected ArgumentError"
    end

    def test_should_die_when_given_no_schema_or_existing_config_file
      caught = false

      File.open(THOUGHT, "w") do |file|
        file.syswrite("we are the dead")
      end

      begin
        @winston.neverspeak(THOUGHT)
      rescue Room101 => e
        caught = true
      end

      assert_equal caught, true, "expected Room101"
    end

    def test_should_return_empty_string_when_given_one
      assert_equal @winston.neverspeak("", {}), "", "expected empty string"
    end
    
    def test_returns_new_string_object
      str = "some test string"
      assert_not_equal str.object_id, @winston.neverspeak(str, {"words" => {}}).object_id      
    end
    
    def test_obfuscates_a_string
      result = @winston.neverspeak("the ministry of war fights eastasia and loves eurasia.", {
        "words" => { 
          /fights\seastasia/ => "loves eastasia",          
          /ministry\sof\swar/ => "ministry of peace",          
          /loves\seurasia/ => "fights eurasia"
        }
      })
      
      assert_equal result, "the ministry of peace loves eastasia and fights eurasia."
    end
    
    def test_obfuscates_file
      File.open(THOUGHT, "w") do |file|
        file.syswrite("telescreen")
      end
      
      @winston.neverspeak(THOUGHT, {
        "words" => {
          /telescreen/ => "watchscreen"
        }
      })
      
      assert_equal "watchscreen", File.new(THOUGHT).readline, "expected obfuscated file"
    end
    
    def test_obfuscates_file_name
      FileUtils.touch(THOUGHT)

      @winston.neverspeak(OCEANIA, {
        "names" => {
          /#{THOUGHT}$/ => POLICE
        }
      })
      
      assert File.exist?(POLICE) && !File.exist?(THOUGHT), "expected obfuscated file name"
    end

    def test_obfuscates_file_content_without_any_names
      File.open(POLICE, "w") do |file|
        file.syswrite("they will never find us")
      end

      @winston.neverspeak(OCEANIA, {
        "words" => {
          /will\snever\sfind/ => "watch"
        }
      })
      
      assert_equal "they watch us", File.new(POLICE).readline, "expected obfuscated file content"
    end

    def test_obfuscates_file_name_and_content
      File.open(THOUGHT, "w") do |file|
        file.syswrite("love conquers all")
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

    def test_obfuscates_directory_name_string
      FileUtils.mkdir(THOUGHT)

      @winston.neverspeak(THOUGHT, {
        "names" => {
          /#{THOUGHT}$/ => POLICE
        }
      })
      
      assert File.exist?(POLICE) && File.directory?(POLICE) && !File.exist?(THOUGHT), "expected obfuscated file name"
    end

    def test_obfuscates_directory_name_file_obj
      FileUtils.mkdir(THOUGHT)

      @winston.neverspeak(File.open(THOUGHT), {
        "names" => {
          /#{THOUGHT}$/ => POLICE
        }
      })
      
      assert File.exist?(POLICE) && File.directory?(POLICE) && !File.exist?(THOUGHT), "expected obfuscated file name"
    end

    def test_reads_in_local_schema_file
      File.open(CONFIG, "w") do |file|
        file.syswrite(YAML::dump({
          "words" => {
            "is\shope" => "is no hope" 
          },
          "names" => {
            /#{THOUGHT}$/ => POLICE
          }
        }))
      end

      File.open(THOUGHT, "w") do |file|
        file.syswrite("there is hope in the proles")
      end

      @winston.neverspeak(OCEANIA)

      assert File.exist?(POLICE) && !File.exist?(THOUGHT), "expected obfuscated file name"
      assert_equal "there is no hope in the proles", File.new(POLICE).readline, "expected obfuscated file"
    end

    def test_can_filter_file_via_block
      File.open(THOUGHT, "w") do |file|
        file.syswrite("take me")
      end
      
      @winston.neverspeak(THOUGHT, {
        "words" => {
          /take\sme/ => "take her"
        }
      }) { |path| 
        path !~ /#{THOUGHT}$/
      }

      assert_equal "take me", File.new(THOUGHT).readline, "expected non-obfuscated file"
    end

    def test_can_filter_file_name_via_block
      FileUtils.touch(THOUGHT)

      @winston.neverspeak(OCEANIA, {
        "names" => {
          /#{THOUGHT}$/ => POLICE
        }
      }) { |path| 
        path !~ /#{THOUGHT}$/
      }

      assert File.exist?(THOUGHT) && !File.exist?(POLICE), "expected non-obfuscated file name"
    end

    def test_can_filter_directory_files_via_block
      File.open(THOUGHT, "w") do |file|
        file.syswrite("is a privilege")
      end

      File.open(POLICE, "w") do |file|
        file.syswrite("are nowhere")
      end

      @winston.neverspeak(OCEANIA, {
        "words" => {
          /nowhere/ => "everywhere",
          /privilege/ => "right"
        },
        "names" => {
          /#{THOUGHT}$/ => "#{POLICE}"
        }
      }) { |path|
        path =~ /#{POLICE}$/ 
      }

      assert File.exist?(POLICE) && File.exist?(THOUGHT), "expected non-obfuscated file names"
      assert_equal "is a privilege", File.new(THOUGHT).readline, "expected non-obfuscated file"
      assert_equal "are everywhere", File.new(POLICE).readline, "expected obfuscated file"
    end

    # TODO:
    # test for multi level dirs
    # running multiple obfuscations
    # bottom up approach verification
    # add verbose logging
  end
end
