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

module WmiLite
  class WmiException < Exception
    def initialize(exception, namespace, query, class_name)
      error_message = exception.message
      error_code = nil

      # Parse the error to get the error status code
      error_code_match = error_message.match(/[^\:]+\:\s*([0-9A-Fa-f]{1,8}).*/)
      error_code = error_code_match.captures.first if error_code_match
      error_code = '' if error_code.nil?

      # Use the status code to generate a more friendly message
      case error_code
      when /80041010/i
        if class_name
          error_message = "The specified class \'#{class_name}\' is not valid in the namespace \'#{namespace}\'.\n#{exception.message}."
        else
          error_message = "The specified query \'#{query}\' referenced a class that is not valid in the namespace \'#{namespace}\'\n#{exception.message}."
        end
      when /8004100E/i
        error_message = "The specified namespace \'#{namespace}\' is not valid.\n#{exception.message}"
      when /80041017/i
        error_message = "The specified query \'#{query}\' is not valid.\n#{exception.message}"
      end

      super(error_message)
    end
  end
end
    
