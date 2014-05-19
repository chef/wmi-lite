Wmi-Lite
========

`wmi-lite` is a lightweight Ruby gem utility library for accessing basic
[Windows Management Instrumentation (WMI)](http://msdn.microsoft.com/en-us/library/aa394582(v=vs.85).aspx)
functionality on Windows. It has no dependencies outside of the Ruby interpreter
and libraries and of course the Windows operating system.

Installation
------------

To install it, run:

    gem install wmi-lite

Usage
-----
To use `wmi-lite` in your Ruby source code, just `require` it:

```ruby
require 'wmi-lite'
```

You can then instantiate an object through `WmiLite::Wmi.new` that will allow you to query a WMI namespace by calling methods on
that object.

* The default namespace if no argument is specified to `new` is `root\cimv2`. To override, pass the desired WMI
  namespace string as an argument to the constructor.
* To execute queries against the object's namespace, use the `instances_of`, `first_of`, and `query` methods.
* The `instances_of` method will return all instances of a given class in the namespace as an array of instances.
* The `query` method returns the results of an arbitrary WMI Query Language (WQL) query as an array of instances.
* The `first_of` method will return the first of all instances of a given class in the namespace.
* Each instance is represented by a Ruby `Hash` for which each property value of the instance is indexed by
  the string name of the property as documented in the [WMI Schema](http://technet.microsoft.com/en-us/library/cc180287.aspx) or
  as registered in the local system's WMI repository.
* The string name specified to the aformentioned `Hash` is case insensitive.

#### Examples
Use of the `instances_of`, `query`, and `first_of` methods of the `WmiLite::Wmi` object is demonstrated below.

##### Count cores in the system

```ruby
cores = 0
wmi = WmiLite::Wmi.new
processors = wmi.instances_of('Win32_Processor')
processors.each do | processor |
  cores += processor['numberofcores']
end
puts "\nThis system has #{cores} core(s).\n"
```

##### Determine if the system is domain-joined

```ruby
wmi = WmiLite::Wmi.new
computer_system = wmi.first_of('Win32_ComputerSystem')
is_in_domain = computer_system['partofdomain']
puts "\nThis system is #{is_in_domain ? '' : 'not '}domain joined.\n"
```

##### List Group Policy Objects (GPOs) applied to the system

```ruby
wmi = WmiLite::Wmi.new('root\rsop\computer')
gpos = wmi.instances_of('RSOP_GPO')
puts "\n#{'GPO Id'.ljust(40)}\tName"
puts "#{'------'.ljust(40)}\t----\n"
gpos.each do | gpo |
  gpo_id = gpo['guidname']
  gpo_display_name = gpo['name']
  puts "#{gpo_id.ljust(40)}\t#{gpo_display_name}"
end
puts 'No GPOs' if gpos.count == 0
puts
```

##### List ruby-related processes
```ruby
puts "Ruby processes:\n"
wmi = WmiLite::Wmi.new
processes = wmi.query('select * from Win32_Process where Name LIKE \'%ruby%\'')
puts "\n#{'Process Id'.ljust(10)} Name"
puts "#{'----------'.ljust(10)} ----\n"
processes.each do | process |
  pid = process['processid']
  name = process['name']
  puts "#{pid.to_s.ljust(10)} #{name}"
end
puts
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

