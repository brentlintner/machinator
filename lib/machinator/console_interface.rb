module Machinator
  class ConsoleInterface    
    require 'ostruct'
    require 'optparse'

    VERSION_TEXT = '0.1'
    HELP = <<TEXT

== Machinator
  obfuscate file content and directory structures

== Usage
  machinator [options]

== Options
  -h,   --help               Displays help message
  -v,   --version            Displays the version

TEXT
    
    def initialize
      @options = OpenStruct.new      
    end
   
    def interpret(argv)
      @argv = argv
      parsed_options?
    end

    def peace_out(msg)
      puts(msg) ; exit!(0)
    end

    def parsed_options?
      @options.verbose = false
      
      opts = OptionParser.new
            
      opts.on('-v', '--version')   { peace_out(VERSION_TEXT) }    
      opts.on('-h', '--help')      { peace_out(HELP) }
      opts.on('-o', '--obfuscate [path]') { |path| }

      begin
        opts.parse!(@argv)
      rescue Exception => e
        handle_exception(e) ; exit!(0)
      end
      
      true
    end
    
    def handle_exception(e)            
      puts("\nshit pooped!\n\n")
      puts "#{e.class.to_s} ==> #{e.message}\n\n"
      puts e.backtrace.join("\n")
    end
  end
end
