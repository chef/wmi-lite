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

describe WmiLite::Wmi do

  let(:wbem_locator) { double 'WIN32OLE', :ConnectServer => wbem_connection }
  let(:wmi_query_instance1) { double 'Wmi::Instance', :wmi_ole_object => native_query_instance1, :[] => native_properties1 }
  let(:wmi_query_instance2) { double 'Wmi::Instance', :wmi_ole_object => native_query_instance2, :[] => native_properties2 }
  let(:wmi_query_result1)  { [ wmi_query_instance1 ].to_enum }
  let(:wmi_query_result2)  { [ wmi_query_instance1, wmi_query_instance2 ].to_enum }
  let(:native_query_result1)  { [ native_query_instance1 ].to_enum }
  let(:native_query_result2)  { [ native_query_instance1, native_query_instance2 ].to_enum }
  let(:wmi_query_result_empty)  { [].to_enum }
  let(:native_properties1) { wmi_properties1.map { | property, value |  double 'WIN32OLE', :name => property } }
  let(:native_properties2) { wmi_properties2.map { | property, value |  double 'WIN32OLE', :name => property } }
  let(:native_query_instance1) { double 'WIN32OLE', :properties_ => native_properties1, :invoke => 'value1' }
  let(:native_query_instance2) { double 'WIN32OLE', :properties_ => native_properties2, :invoke => 'value2' }
  let(:wbem_connection) { double 'WIN32OLE', :ExecQuery => native_query_result }

  def validate_query_result(actual, expected)
    expect(actual.count).to eql(expected.count)

    index = 0

    expected.each do | expected_value |
      actual_value = actual[index]
      expected_value.wmi_ole_object.invoke == actual_value.wmi_ole_object.invoke
      expected_value.wmi_ole_object.properties_.each do | expected_property |

        expect(actual_value[expected_property.name]).not_to eql(nil)

        names = actual_value.wmi_ole_object.properties_.map { | property | property.name }

        expect(names.include?(expected_property.name)).to eql(true)

      end
      index += 1
    end
  end

  before(:each) do
    stub_const('WIN32OLE', Class.new)
    WIN32OLE.stub(:new).with("WbemScripting.SWbemLocator").and_return(wbem_locator)
    stub_const('WIN32OLERuntimeError', Class.new(Exception))
  end

  let(:wmi) { WmiLite::Wmi.new }
  let(:wmi_query_result) { wmi_query_result_empty }
  let(:native_query_result) { [].to_enum }

  it "should not fail with empty query results" do
    results = wmi.query('')
    result_count = 0
    results.each { | result | result_count += 1 }

    expect( result_count ).to eq(0)
  end

  shared_examples_for "the first_of method" do

    let(:wmi_properties1) { { 'cores' => 4, 'name' => 'mycomputer1', 'diskspace' => 400, 'os' => 'windows' } }
    let(:wmi_properties2) { { 'cores' => 2, 'name' => 'mycomputer2', 'bios' => 'ami', 'os' => 'windows' } }
    let(:native_query_result) { [].to_enum }

    it "should not fail with empty query results" do
      results = wmi.first_of('vm')
      expect( results ).to eq(nil)
    end

    context "when returning one instance in the query" do
      let(:wmi_query_result) { wmi_query_result1 }
      let(:native_query_result) { native_query_result1 }

      it "should get one instance" do
        results = wmi.first_of('vm')
        expected_result = WmiLite::Wmi::Instance.new(native_query_result.first)
        validate_query_result([results], [expected_result])
      end
    end

    context "when returning more than one instance in the query" do
      let(:wmi_query_result) { wmi_query_result2 }
      let(:native_query_result) { native_query_result2 }

      it "should get one instance" do
        results = wmi.first_of('vm')
        expected_result = WmiLite::Wmi::Instance.new(native_query_result.first)
        validate_query_result([results], [expected_result])
      end
    end

  end

  shared_examples_for "the instances_of method" do

    let(:wmi_properties1) { { 'cores' => 4, 'name' => 'mycomputer1', 'diskspace' => 400, 'os' => 'windows' } }
    let(:wmi_properties2) { { 'cores' => 2, 'name' => 'mycomputer2', 'bios' => 'ami', 'os' => 'windows' } }
    let(:native_query_result) { [].to_enum }

    it "should not fail with empty query results" do
      results = wmi.instances_of('vm')
      expect( results ).to eq([])
    end

    context "when returning one instance in the query" do
      let(:wmi_query_result) { wmi_query_result1 }
      let(:native_query_result) { native_query_result1 }

      it "should get one instance" do
        results = wmi.instances_of('vm')
        index = 0
        expected_result = results.map do | result |
          WmiLite::Wmi::Instance.new(result.wmi_ole_object)
        end
        validate_query_result(results, expected_result)
      end
    end

    context "when returning one instance in the query" do
      let(:wmi_query_result) { wmi_query_result2 }
      let(:native_query_result) { native_query_result2 }

      it "should get one instance" do
        results = wmi.instances_of('vm')
        index = 0
        expected_result = results.map do | result |
          WmiLite::Wmi::Instance.new(result.wmi_ole_object)
        end
        validate_query_result(results, expected_result)
      end
    end

  end

  shared_examples_for 'an invalid query' do
    let(:unparseable_error) { 'unparseableerror' }
    it 'should raise an exception' do
      wbem_connection.should_receive(:ExecQuery).and_raise(WIN32OLERuntimeError)
      wmi_service = WmiLite::Wmi.new
      expect { wmi_service.send(query_method, wmi_query) }.to raise_error(WmiLite::WmiException)
    end

    it 'should raise an exception that ends with the original exception message' do
      wbem_connection.should_receive(:ExecQuery).and_raise(WIN32OLERuntimeError.new(unparseable_error))
      wmi_service = WmiLite::Wmi.new
      error_message = nil
      begin
        wmi_service.send(query_method, wmi_query)
      rescue WmiLite::WmiException => e
        error_message = e.message
      end

      # Exception messages look a like a customized error string followed by
      # the original, less friendly message. A change here affects only
      # aestethics of human diagnostics, this may be changed with no effect
      # on libraries or applications.
      expect(error_message).not_to eql(nil)
      expect(e.message.start_with?(unparseable_error)).to eql(false)
      expect(e.message.end_with?(unparseable_error)).to eql(true)
    end
  end

  shared_examples_for 'an invalid namespace' do
    let(:unparseable_error) { 'unparseableerror' }
    it 'should raise an exception' do
      wbem_locator.should_receive(:ConnectServer).and_raise(WIN32OLERuntimeError)
      wmi_service = WmiLite::Wmi.new('notavalidnamespace')
      expect { wmi_service.send(query_method, wmi_query) }.to raise_error(WmiLite::WmiException)
    end

    it 'should raise an exception that starts with the original exception message' do
      wbem_locator.should_receive(:ConnectServer).and_raise(WIN32OLERuntimeError.new(unparseable_error))
      wmi_service = WmiLite::Wmi.new
      error_message = nil
      begin
        wmi_service.send(query_method, wmi_query)
      rescue WmiLite::WmiException => e
        error_message = e.message
      end

      # See previous comment on this validation of human readability -- a change
      # to the format / content of these messages will not break applications.
      expect(error_message).not_to eql(nil)
      expect(error_message.start_with?(unparseable_error)).to eql(false)
      expect(error_message.end_with?(unparseable_error)).to eql(true)
    end
  end

  shared_examples_for "the query method" do

    let(:wmi_properties1) { { 'cores' => 4, 'name' => 'mycomputer1', 'diskspace' => 400, 'os' => 'windows' } }
    let(:wmi_properties2) { { 'cores' => 2, 'name' => 'mycomputer2', 'bios' => 'ami', 'os' => 'windows' } }
    let(:native_query_result) { [].to_enum }

    it "should not fail with empty query results" do
      results = wmi.query('vm')
      expect( results ).to eq([])
    end

    context "when returning one instance in the query" do
      let(:wmi_query_result) { wmi_query_result1 }
      let(:native_query_result) { native_query_result1 }

      it "should get one instance" do
        results = wmi.query('vm')
        index = 0
        expected_result = results.map do | result |
          WmiLite::Wmi::Instance.new(result.wmi_ole_object)
        end
        validate_query_result(results, expected_result)
      end
    end

    context "when returning one instance in the query" do
      let(:wmi_query_result) { wmi_query_result2 }
      let(:native_query_result) { native_query_result2 }

      it "should get one instance" do
        results = wmi.query('vm')
        index = 0
        expected_result = results.map do | result |
          WmiLite::Wmi::Instance.new(result.wmi_ole_object)
        end
        validate_query_result(results, expected_result)
      end
    end

  end

  context "when constructing a Ruby class instance" do
    it "should not connect to WMI in the constructor" do
      WmiLite::Wmi.any_instance.should_not_receive(:connect_to_namespace)
      wmi_service_nil_namespace = WmiLite::Wmi.new
      wmi_service_explicit_namespace = WmiLite::Wmi.new('root/cimv2')
    end
  end

  context "when calling query methods" do
    it "should only connect to WMI on the first query execution" do
      WIN32OLE.should_receive(:new).with("WbemScripting.SWbemLocator").exactly(1).times.and_return(wbem_locator)
      wmi_service = WmiLite::Wmi.new

      # Make a lot of queries to be sure the connection is only created once
      wmi_service.query('select * from Win32_Process')
      wmi_service.query('select * from Win32_Process')
      wmi_service.instances_of('Win32_Processor')
      wmi_service.instances_of('Win32_Processor')
      wmi_service.first_of('Win32_Group')
      wmi_service.first_of('Win32_Group')
    end
  end

  context 'when making invalid queries' do
    let(:namespace) { nil }

    let(:wmi_query) { 'invalidclass' }
    let(:query_method) { :first_of }

    it_behaves_like 'an invalid query'
    it_behaves_like 'an invalid namespace'

    let(:query_method) { :instances_of }
    it_behaves_like 'an invalid query'
    it_behaves_like 'an invalid namespace'

    let(:query_method) { :query }
    let(:wmi_query) { 'nosql_4_life' }
    it_behaves_like 'an invalid query'
    it_behaves_like 'an invalid namespace'
  end

  it_should_behave_like "the first_of method"

  it_should_behave_like "the instances_of method"

  it_should_behave_like "the query method"

end
