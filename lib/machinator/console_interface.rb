module Machinator
  class ConsoleInterface    

VERSION_TEXT = 'Machinator v0.1'
HELP = <<TEXT

== Machinator
  Keep big brother distracted by obfuscating your code, file and folder names.

== Usage
  machinator [options]

== Options
  -h,   --help               Displays help message
  -v,   --version            Displays the version

TEXT
    
    def initialize(argv)
      @argv = argv
      @options = OpenStruct.new
      @options.verbose = false
      
      parsed_options?
    end
    
    def options
      @options
    end

    def help
      log(HELP) ; exit!(0)
    end
    
    def parsed_options?
      opts = OptionParser.new
      
      opts.on('-v', '--version')   { log(VERSION_TEXT) ; exit!(0) }    
      opts.on('-h', '--help')      { help }
      
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