#
# Author:: Adam Edwards (<adamed@getchef.com>)
# Copyright:: Copyright 2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'win32ole' if RUBY_PLATFORM =~ /mswin|mingw32|windows/
require 'wmi-lite/wmi_instance'

module WmiLite
  class Wmi
    def initialize(namespace = nil)
      @namespace = namespace
      @connection = nil
    end

    def query(wql_query)
      results = start_query(wql_query)
      
      result_set = []

      results.each do | result | 
        result_set.push(wmi_result_to_snapshot(result))
      end
      
      result_set
    end

    def instances_of(wmi_class)
      query("select * from #{wmi_class}")
    end

    def first_of(wmi_class)
      query_result = start_query("select * from #{wmi_class}")
      first_result = nil
      query_result.each do | record |
        first_result = record
        break
      end
      first_result.nil? ? nil : wmi_result_to_snapshot(first_result)
    end

    private

    def start_query(wql_query)
      connect_to_namespace
      result = @connection.ExecQuery(wql_query)
      raise_if_failed(result)
      result
    end

    def raise_if_failed(result)
      # Attempting to access the count property of the underlying
      # COM (OLE) object will trigger an exception if the query
      # was unsuccessful.
      result.count
    end

    def connect_to_namespace
      if @connection.nil?
        namespace = @namespace.nil? ? 'root/cimv2' : @namespace
        locator = WIN32OLE.new("WbemScripting.SWbemLocator")
        @connection = locator.ConnectServer('.', namespace)
      end
    end

    def wmi_result_to_snapshot(wmi_object)
      snapshot = Instance.new(wmi_object)
    end
  end
end
