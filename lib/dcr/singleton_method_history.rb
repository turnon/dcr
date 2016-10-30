require 'dcr/history'

module Dcr
  class SingletonMethodHistory < History
    def self.ivar
      :@_dcr_sm
    end

    attr_reader :object

    def commit method_name, &decorator
      org_method = object.method method_name

      new_method = lambda do |*args|
	decorator.call org_method, *args
      end

      object.define_singleton_method method_name, &new_method

      file, line, _ =  caller[0].split(':')
      track[method_name].unshift [org_method, file, line.to_i]
    end
  end
end
