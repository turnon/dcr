module Dcr
  class History

    class << self
      def of obj
        ko.instance_variable_set(ivar, new(obj)) unless ko.instance_variable_defined? ivar
	ko.instance_variable_get ivar
      end
    end

    attr_reader :track

    def initialize obj
      @object = obj
      @track = Hash.new{ |hash, key| hash[key] = [] }
    end

    def list method_name
      track[method_name].map do |method, file, line|
	[file, line]
      end
    end

    def add_to_track method
      file, line, _ =  caller[1].split(':')
      track[method.name].unshift [method, file, line.to_i]
    end

  end
end
