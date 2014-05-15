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
    expected_result = actual.count == expected.count

    index = 0
    if expected_result
      expected.each do | expected_value |
        actual_value = actual[index]
        expected_value.wmi_ole_object.invoke == actual_value.wmi_ole_object.invoke
        expected_value.wmi_ole_object.properties_.each do | expected_property |
          if actual_value[expected_property.name].nil?
            expected_result = false
          end
          if !! actual_value.wmi_ole_object.properties_.find { | actual_property | actual_property == expected_property.name }
            expected_result = false
          end
          if ! expected_result
            break
          end
        end
        index += 1
      end
    end

    expected_result
  end

  before(:each) do
    WIN32OLE.stub(:new).with("WbemScripting.SWbemLocator").and_return(wbem_locator)
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
        is_expected = validate_query_result([results], [expected_result])
        expect(is_expected).to eq(true)
      end
    end

    context "when returning more than one instance in the query" do
      let(:wmi_query_result) { wmi_query_result2 }
      let(:native_query_result) { native_query_result2 }

      it "should get one instance" do
        results = wmi.first_of('vm')
        expected_result = WmiLite::Wmi::Instance.new(native_query_result.first)
        is_expected = validate_query_result([results], [expected_result])
        expect(is_expected).to eq(true)
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
        is_expected = validate_query_result(results, expected_result)
        expect(is_expected).to eq(true)
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
        is_expected = validate_query_result(results, expected_result)
        expect(is_expected).to eq(true)
      end
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
        is_expected = validate_query_result(results, expected_result)
        expect(is_expected).to eq(true)
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
        is_expected = validate_query_result(results, expected_result)
        expect(is_expected).to eq(true)
      end
    end

  end


  it_should_behave_like "the first_of method"

  it_should_behave_like "the instances_of method"

  it_should_behave_like "the query method"

end
