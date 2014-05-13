Wmi-Lite
========

Wmi-Lite is a lightweight Ruby gem utility library for accessing basic WMI functionality on Windows. It has no dependencies
other than version 1.9 or greater of the Ruby interpreter and libraries and of course the Windows operating system.

Installation
------------

To install it, run:

    gem install wmi-lite

Usage
-----
To use wmi-lite in your Ruby source code, just `require` it:

```ruby
require 'wmi-lite'
```

#### Examples
```ruby
cores = 0
wmi = WmiRepository.new
processors = wmi.instances_of('Win32_Processor')
processors.each do | processor |
  cores += processor['numberofcores']
end
```

License & Authors
-----------------

Author:: Adam Edwards (<adamed@getchef.com>)
Copyright:: Copyright (c) 2014 Chef Software, Inc.
License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

