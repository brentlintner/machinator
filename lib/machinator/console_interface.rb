module Machinator
  class ConsoleInterface    

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
    end
    
    def options
      @options
    end

    def help
      log(HELP) ; exit!(0)
    end
    
    def parsed_options?
      opts = OptionParser.new
      
      opts.on('-v', '--version')   { self.log("0.1") ; exit!(0) }    
      opts.on('-h', '--help')      { help }
      
      opts.on('-o', '--obfuscate PATH') do |path|
        Obfuscator.new(path)
      end

      begin
        opts.parse!(@argv)
      rescue Exception => e
        self.handle_exception(e) ; exit!(0)
      end
    
      self.process_options
      
      true
    end
    
    def process_options ; end

    def handle_exception(e)      
      msg = e.message = e.exception.to_s + " :: " + msg if e.message.to_s != e.exception.to_s
      self.log "\nShit Pooped --> #{e.class.to_s}\nMESSAGE --> #{msg}"
      self.log "\nStack\n#{e.backtrace.join("\n")}\n"
    end
    
  end
end