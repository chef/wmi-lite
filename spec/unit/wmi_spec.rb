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

require 'wmi_lite/wmi'

describe WmiLite::Wmi do

  let(:wbem_connection) { double 'WIN32OLE', :ExecQuery => [] }
  let(:wbem_locator) { double 'WIN32OLE', :ConnectServer => wbem_connection }
  
  before do
    WIN32OLE.stub(:new).and_return(wbem_locator)
  end

  let(:wmi) { WmiLite::Wmi.new }
  
  it "should not fail with empty query results" do
    result = wmi.query('') 
    expect( result ).to eq([])
  end
end
