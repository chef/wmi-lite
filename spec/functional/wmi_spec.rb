#
# Author:: Adam Edwards (<adamed@getchef.com>)
#
# Copyright:: 2014, Chef Software, Inc.
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

require 'spec_helper'

describe WmiLite::Wmi, :windows_only do
  let(:wmi) { WmiLite::Wmi.new(namespace) }

  def validate_wmi_results(results, class_name)
    result_collection = cardinality_transform.call(results)
    result_collection.each do | result |
      # make sure the class name of the instance is what we asked for
      expect(result['creationclassname'].downcase).to eql(class_name.downcase)
    end
  end

  shared_examples_for 'a valid WMI query result' do
    it 'should successfully return multiple results' do
      query_parameter = wmi_query.nil? ? wmi_class : wmi_query
      results = wmi.send(query_method, query_parameter)
      validate_wmi_results(results, wmi_class)
    end

    describe 'when the namespace is invalid' do
      it_behaves_like 'an invalid namespace'
    end
  end

  shared_examples_for 'an invalid query' do
    it 'should raise an exception' do
      expect { wmi.send(query_method, wmi_query) }.to raise_error(WmiLite::WmiException)
    end
  end

  shared_examples_for 'an invalid namespace' do
    it 'should raise an exception if an invalid namespace is specified' do
      invalid_wmi = WmiLite::Wmi.new('root/notvalid')
      expect { invalid_wmi.send(query_method, wmi_query) }.to raise_error(WmiLite::WmiException)
    end
  end

  shared_examples_for 'a valid WMI query' do
    let(:wmi_class) { 'Win32_LogicalDisk' }
    it_behaves_like 'a valid WMI query result'

    let(:wmi_class) { 'Win32_ComputerSystem' }
    it_behaves_like 'a valid WMI query result'

    let(:wmi_class) { 'Win32_Process' }
    it_behaves_like 'a valid WMI query result'

    context 'that return 0 results' do
      let(:wmi_class) { 'Win32_TapeDrive' }
      it_behaves_like 'a valid WMI query result'
    end
  end

  context 'when making valid queries' do
    let(:namespace) { nil }
    let(:wmi_query) { nil }
    let(:cardinality_transform) { lambda{|x| x} }
    context 'using first_of' do
      let(:cardinality_transform) { lambda{|x| x.nil? ? [] : [x] } }
      let(:query_method) { :first_of } 
      it_behaves_like 'a valid WMI query'
    end

    context 'using instances_of' do
      let(:query_method) { :instances_of } 
      it_behaves_like 'a valid WMI query'
    end

    context 'using query' do
      let(:wmi_query) { "select * from #{wmi_class}" }
      let(:query_method) { :query } 
      it_behaves_like 'a valid WMI query'
    end
  end

  context 'when making invalid queries' do
    let(:namespace) { nil }

    let(:wmi_query) { 'invalidclass' }
    let(:query_method) { :first_of }
    it_behaves_like 'an invalid query'

    let(:query_method) { :instances_of }
    it_behaves_like 'an invalid query'

    let(:query_method) { :query }
    let(:wmi_query) { 'nosql_4_life' }
    it_behaves_like 'an invalid query'
  end

  let(:namespace) { nil }
  describe 'when querying Win32_Environment' do
    it 'should have the same environment variables as the Ruby ENV environment hash' do
      results = wmi.instances_of('Win32_Environment')

      variables = {}

      # Skip some environment variables because we can't compare them against what's in ENV.
      # Path, pathext, psmodulepath are special, they ares "merged" between the user and system value.
      # PROCESSOR_ARCHITECTURE is actually the real processor arch of the system, so #{ENV['processor_architecture']} will
      # report X86, while WMI will (correctly) report X64.
      # And username is oddly the username of the WMI service, i.e. 'SYSTEM'.
      ignore = {'path' => true, 'pathext' => true, 'processor_architecture' => true, 'psmodulepath' => true, 'username' => true}
      results.each do | result |
        if ! variables.has_key?(result['name']) || result['username'] != '<SYSTEM>'
          variables[result['name']] = result['variablevalue']
        end
      end

      verified_count = 0
      variables.each_pair do | name, value |
        if ignore[name.downcase] != true

          # Turn %SYSTEMROOT% into c:\windows
          # so we can compare with what's in ENV
          evaluated_value = `echo #{value}`.strip 

          expect(evaluated_value).to eql(`echo #{ENV[name]}`.strip)
          verified_count += 1
        end
      end
      
      # There are at least 3 variables we could verify in a default
      # Windows configuration, make sure we saw some
      expect(verified_count).to be >= 3
    end
  end

  let(:namespace) { nil }
  it 'should ignore case when retrieving WMI properties' do
    result = wmi.first_of('Win32_ComputerSystem')
    caption_mixed = result['Caption']
    caption_lower = result['caption']

    expect(caption_mixed.nil?).to eql(false) 
    expect(caption_lower.nil?).to eql(false)

    expect(caption_mixed.length).to be > 0
    expect(caption_lower.length).to be > 0
    expect(caption_mixed).to eql(caption_lower)
  end
end
