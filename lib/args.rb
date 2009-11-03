require 'rubygems'
require 'ckuru-tools'
require 'getoptlong'

class String
  def stripdashes
    gsub(/-/,'')
  end
  def stripplusses
    gsub(/\+/,'')
  end

  def String.code_append(old,new)
    old += ";" if old and old.length > 0
    old += new
  end
end

module CkuruTools 
  class ArgParsed < HashInitializerClass
    attr_accessor :spec, :type, :long, :short, :required
  end

  class ArgsProcessor < HashInitializerClass
    attr_accessor :args
    attr_accessor :noparse

    #
    # A simple, terse, and concise wrapper around GetoptLong command line parsing.
    #
    # Lets start with an example:
    #
    # args = CkuruTools::ArgsProcessor.new(:args => ["-flag","value","Required_value+"])
    #
    # response = args.parse
    #
    # Now if the script where to be called with 
    #
    # myscript -f -v VALUE --Required_value required
    # 
    # response => {:flag => true, :value => "VALUE", :Required_value => "required"}
    #
    # Defaults:
    # -h : always generates help (do not use this flag)
    # -d : Interface into CkuruTools::Debug  (increments debugging level); (do not override this flag) 
    #
    #
    def initialize(h)
      super h
    end
    
    def parse
      argsparse, argshash = [], {}

      argsparse.push(["--debug","-d",GetoptLong::NO_ARGUMENT],
                     ["--help","-h",GetoptLong::NO_ARGUMENT])
      
      args.each do |arg|
        if matchdata =  arg.match(/-(([a-zA-Z0-9])[a-zA-Z0-9]+)/)
          short = "-#{matchdata[2]}"
          long = "-#{arg}"
          argsparse.push([long,short,GetoptLong::NO_ARGUMENT])
          argshash[long] = ArgParsed.new(:spec => arg, 
                                         :type => :flag, 
                                         :long => long, 
                                         :short => short,
                                         :required => false)
        elsif matchdata = arg.match(/(([a-zA-Z0-9])[a-zA-Z0-9]+)/)
          short = "-#{matchdata[2]}"
          long = "--#{arg.stripplusses}"

          argsparse.push([long,short,GetoptLong::REQUIRED_ARGUMENT])
          argshash[long] = ArgParsed.new(:spec => arg, 
                                         :type => :value, 
                                         :long => long, 
                                         :short => short,
                                         :required => arg.match(/\+/) ? true : false)
        else
          raise "unrecognized arg spec #{arg}"
        end
      end

      ret = {}
      opts = GetoptLong.new *argsparse
      opts.each do |opt, arg|
        if opt == '--debug'
          CkuruTools::Debug.instance.level = CkuruTools::Debug.instance.level + 1
          ckebug 1, "incrementing debug level"
        elsif opt == '--help'
          puts "Options are:"
          argshash.keys.each do |a|
            puts "\t#{argshash[a].long},#{argshash[a].short}" + (argshash[a].required ? " (required)" : '')
          end
          exit 0
        else
          ckebug 1, "parsing #{opt}, #{arg}"
          case argshash[opt].type
          when :flag
            ret[argshash[opt].long.stripdashes.to_sym] = true
          when :value
            ret[argshash[opt].long.stripdashes.to_sym] = arg
          end
        end
      end
      missing_required = []
      argshash.keys.each do |a|
        if argshash[a].required
          missing_required.push a unless ret.has_key? a.stripdashes.to_sym
        end
      end
      ckebug 1, ret.inspect
      if missing_required.length > 0
        missing_required.each do |m|
          ckebug 0, "#{argshash[m].long}(#{argshash[m].short}) is required"
        end
        raise "missing required values"
      end
      ret
    end
  end
end
    
    
