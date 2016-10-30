require 'dcr/version'
require 'dcr/instance_method_history'
require 'dcr/singleton_method_history'

module Dcr

  class << self

    def instance klass, org_method_name=nil, &decorator
      org_method_name = parse_method_name(decorator) unless org_method_name
      hist = InstanceMethodHistory.of klass
      hist.commit org_method_name, &decorator
    end

    def singleton object, org_method_name=nil, &decorator
      org_method_name = parse_method_name(decorator) unless org_method_name
      hist = SingletonMethodHistory.of object
      hist.commit org_method_name, &decorator
    end

    def parse_method_name a_lambda=nil, &block
      a_lambda = block_given? ? block : a_lambda
      a_lambda.parameters[0][1]
    end

    def list_instance klass, method_name
      hist = InstanceMethodHistory.of klass
      hist.list method_name
    end

    def list_singleton object, method_name
      hist = SingletonMethodHistory.of object
      hist.list method_name
    end

    def rollback_instance klass, method_name
      hist = InstanceMethodHistory.of klass
      hist.rollback method_name
    end

    def rollback_all_instance klass, method_name
      hist = InstanceMethodHistory.of klass
      hist.rollback_all method_name
    end

    def rollback_singleton object, method_name
      hist = SingletonMethodHistory.of object
      hist.rollback method_name
    end

    def rollback_all_singleton object, method_name
      hist = SingletonMethodHistory.of object
      hist.rollback_all method_name
    end

  end
end
