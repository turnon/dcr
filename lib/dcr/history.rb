module Dcr
  class History

    class << self
      def of obj
        obj.instance_variable_set(ivar, new(obj)) unless obj.instance_variable_defined? ivar
	obj.instance_variable_get ivar
      end
    end

    attr_reader :track

    def initialize obj
      @object = obj
      @track = Hash.new{ |hash, key| hash[key] = [] }
    end

    def list method_name
      track[method_name].
	reverse_each.
	map do |method, file, line|
	  [file, line]
        end
    end

    def add_to_track method, name=nil
      file, line, _ =  caller_not_from_dcr.split(':')
      track[name || method.name] << [method, file, line.to_i]
    end

    def caller_not_from_dcr
      caller.find do |file|
	file !~ /dcr\/lib/
      end
    end

    def pop_last_track method_name
      warn_if_no_org_methods method_name
      track[method_name].pop[0]
    end

    def pop_all_track method_name
      warn_if_no_org_methods method_name
      oldest_method = track[method_name].shift[0]
      track[method_name].clear
      oldest_method
    end

    def warn_if_no_org_methods method_name
      methods = track[method_name]
      raise NoMethodError,
	"no more history for method: #{method_name}" if methods.empty?
    end

  end
end
