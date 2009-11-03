# $Id$

# Equivalent to a header guard in C/C++
# Used to prevent the class/module from being loaded more than once
unless defined? CkuruTools

  module CkuruTools

    # :stopdoc:
    VERSION = '1.0.0'
    LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
    PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
    # :startdoc:

    # Returns the version string for the library.
    #
    def self.version
      VERSION
    end

    # Returns the library path for the module. If any arguments are given,
    # they will be joined to the end of the libray path using
    # <tt>File.join</tt>.
    #
    def self.libpath( *args )
      args.empty? ? LIBPATH : ::File.join(LIBPATH, *args)
    end

    # Returns the lpath for the module. If any arguments are given,
    # they will be joined to the end of the path using
    # <tt>File.join</tt>.
    #
    def self.path( *args )
      args.empty? ? PATH : ::File.join(PATH, *args)
    end

    # Utility method used to rquire all files ending in .rb that lie in the
    # directory below this file that has the same name as the filename passed
    # in. Optionally, a specific _directory_ name can be passed in such that
    # the _filename_ does not have to be equivalent to the directory.
    #
    def self.require_all_libs_relative_to( fname, dir = nil )
      dir ||= ::File.basename(fname, '.*')
      search_me = ::File.expand_path(
                                     ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

      Dir.glob(search_me).sort.each {|rb| require rb}
    end

    #
    # extending HashInitializerClass enables you to get Object.new(hash) functionality
    # where each key will dispatch to an object setter method.
    #
    # Usage:
    #
    # class MyClass < HashInitializerClass
    # ..attr_accessor :foo
    # end
    #
    # m = MyClass(:foo => "bar")
    # m.foo
    # => "bar"
    #
    #
    
    class HashInitializerClass
      def initialize(h)
        h.keys.each do |k|
          self.send("#{k.to_sym}=",h[k])
        end
        ckebug(2,"(#{self.class}) #{self.inspect})")
      end
    end

  end  # module CkuruTools

  CkuruTools.require_all_libs_relative_to __FILE__
  CkuruTools.require_all_libs_relative_to CkuruTools.libpath

  class Object

    def _require ; each {|r| require r } ; end

    #def to_hash
    #  ret = Hash.new
    #  each do |elem|
    #    ret[elem] = true
    #  end
    #  ret
    #end

    def docmd(cmd,dir=nil)
      ret = docmdi(cmd,dir)
      if ret.exitstatus != 0
        raise "cmd #{cmd} exitstatus #{ret.exitstatus} : #{ret}"
      end
      ret
    end

    def docmdi(cmd,dir=nil)
      if dir
        unless Dir.chdir(dir) 
          ckebug 0, "failed to cd to #{dir}"
          return nil
        end
      end
      ret = msg_exec "running #{cmd}" do
        cmd.gsub!(/\\/,"\\\\\\\\\\\\\\\\")
        cmd.gsub!(/\'/,"\\\\'")
        cmd.gsub!(/\"/,"\\\\\\\\\\\"")
        system("bash -c \"#{cmd}\"")
        if $?.exitstatus != 0 
          print " failed exit code #{$?.exitstatus} "
        end
      end
      $?
    end
        
    ################################################################################

    def docmd_dir(h={})
      ret = nil
      if h[:dir]
        unless Dir.chdir(h[:dir]) 
          ckebug 0, "failed to cd to #{h[:dir]}"
          return nil
        end
      end
      if h[:commands]
        h[:commands].each do |cmd|
          ret = docmd(cmd)
          if ret.exitstatus != 0
            ckebug 0, "giving up"
            return ret
          end
        end
      end
      ret
    end

    def emacs_trace
      begin
        yield
      rescue Exception => e
        puts e
        puts "... exception thrown from ..."
        e.backtrace.each do |trace|
          a = trace.split(/:/)
          puts "#{a[0]}:#{a[1]} #{a[2..a.length].join(':')}"
          if $emacs_trace_debugger
            require 'ruby-debug'
          end
        end
      end
    end

    def ckebug(level,msg)      
      CkuruTools::Debug.instance.debug(level,msg)
    end

    def current_method
      caller[0].match(/`(.*?)'/)[1]
    end

    def calling_method
      caller[1] ? caller[1].match(/`(.*?)'/)[1] : ""
    end

    def calling_method2
      if caller[2]
        if matchdata = caller[2].match(/`(.*?)'/)
          matchdata[1]
        else
          ""
        end
      else
        ""
      end
    end


    def calling_method_sig
      caller[1] ? caller[1] : ""
    end

      

#     def calling_method
#       if caller[2]
#         caller[2].match(/`(.*?)'/)[1]
#       else
#         ""
#       end
      
#     end

  end
end

class Time
  def ckuru_time_string
    strftime("%m/%d/%Y %H:%M:%S")
  end
end

def printmsg(msg,newline=true)
  print "#{Time.new.ckuru_time_string}: #{msg}"
  puts if newline
end


#module MlImportUtils
def msg_exec(msg)
  printmsg("#{msg} ... ",false)
  t1 = Time.new
  ret = yield
  puts "done (#{Time.new - t1})"
  ret
end

def chatty_exec(level,name)
  ret = yield
  ckebug level, "#{name} is #{ret}"
  ret
end


# EOF
