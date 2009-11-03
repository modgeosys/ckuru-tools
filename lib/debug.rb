require 'singleton'

module CkuruTools
  class Debug
    include ::Singleton
    attr_accessor :level

    def debug(level,msg,newline=true)
      raise "first argument to #{current_method} must be a number or support the #to_i method" unless
        level.respond_to?(:to_i)
      self.level = 0 if self.level.nil?
      if level <= self.level
#        print "#{Time.new}(#{calling_method}): #{msg}" + (newline ? "\n" : nil)
#        debugger
        print "#{Time.new.ckuru_time_string}(#{calling_method2}): #{msg}" + (newline ? "\n" : nil)
      end
    end
    
    def self.set_level(level)
      CkuruTools::Debug.instance.level = level
      ckebug 0, "setting debug level to #{level}"
    end
  end
end

CkuruTools::Debug.instance.level = ENV['CKURU_DEBUG_LEVEL'] ? ENV['CKURU_DEBUG_LEVEL'].to_i : 0
