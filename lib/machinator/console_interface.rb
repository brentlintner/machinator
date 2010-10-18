module Machinator
  class ConsoleInterface    

  VERSION_TEXT = 'v0.1'
  HELP = <<TEXT

== Machinator
  Keep big brother distracted by obfuscating your code, file and folder names.

== Usage
  machinator [options]

== Options
  -h,   --help               Displays help message
  -v,   --version            Displays the version

TEXT
    
    def initialize
      @argv = nil
      @options = OpenStruct.new      
    end
   
    def interpret(argv)
      @argv = argv
      parsed_options?
    end

    def options
      @options
    end

    def peace_out(msg)
      log(msg) ; exit!(0)
    end

    def parsed_options?
      @options.verbose = false
      
      opts = OptionParser.new
            
      opts.on('-v', '--version')   { peace_out(VERSION_TEXT) }    
      opts.on('-h', '--help')      { peace_out(HELP) }
      
      opts.on('-o', '--obfuscate [path]') do |path|
      end

      begin
        opts.parse!(@argv)
      rescue Exception => e
        handle_exception(e) ; exit!(0)
      end
    
      process_options
      
      true
    end
    
    def process_options ; end

    def log(msg)
      puts(msg)
    end
    
    def handle_exception(e)            
      log("\nshit pooped!\n\n")
      log "#{e.class.to_s} ==> #{e.message}\n\n"
      log e.backtrace.join("\n")
    end
    
  end
end
