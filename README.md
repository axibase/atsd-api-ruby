# Axibase Time-Series Database Client for Ruby

The ATSD Client for Ruby enables Ruby developers 
to easily read and write statistics and metadata 
from Axibase Time-Series Database.

API documentation: https://github.com/axibase/atsd-docs/blob/master/api/README.md

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'atsd'
```

Then execute:

    $ bundle

Alternatively, you can install atsd gem manually:

    $ gem install atsd
    
## Implemented Methods

### Data API
- Series
    - Query
    - Insert
    - CSV Insert
- Properties
    - Query
    - Insert
    - Batch
- Alerts 
    - Query
    - Update
    - History Query
    
### Meta API
- Metrics 
    - List
    - Get
    - Create or replace
    - Update
    - Delete
    - Entities and tags
- Entities
    - List
    - Get
    - Create or replace
    - Update
    - Delete
- Entity Group 
    - List
    - Get
    - Create or replace
    - Update
    - Delete
    - Get entities
    - Add entities
    - Set entities
    - Delete entities

## Usage

To start using the gem you need to create an `ATSD` class instance:

```ruby
require 'atsd'
include ATSD
atsd = ATSD.new :url => "#{API_ENDPOINT}/api/v1", 
                :basic_auth => "#{LOGIN}:#{PASSWORD}", 
                :logger => true
```

### Configuration

#### Authorization
In order to use the API you need to specify `:basic_auth` option in one
of the following ways:

- `"login:password"`
- `{ :login => 'login', :password => 'password' }`

#### SSL 
Connecting to ATSD via SSL requires extra configuration if your ATSD instance runs on a self-signed SSL certificate. 
See [Faraday Wiki](https://github.com/lostisland/faraday/wiki/Setting-up-SSL-certificates) on how to setup SSL. 
As a workaround you can specify `ssl: { verify: false }` option in the client.


#### Logging

- To use a custom logger specify it in the `:logger` option. 
- To use the default STDOUT logger set `:logger` option to `true`. 

### Services
Once you instantiated the ATSD class, you can use different services. 
Each service represents a particular object type in Axibase Time Series Database.
The following services are currently implemented: 

- series_service, 
- properties_service, 
- alerts_service, 
- metrics_service,
- entities_service,
- entity_groups_service.

#### Query builders
Query objects created by services provide convenient methods to build complex queries.
They support method chaining and automatically translate snake_styled properties 
to CamelCase used in the API. For example, `end_time` property in ruby code becomes `endTime` in json request.

#### Series Service

Basic query:

```ruby
require 'time'
series_service = atsd.series_service
# => #<ATSD::SeriesService:0x007f82a4446c08
query = series_service.query('sensor-1', 'temperature', Time.parse("2015-11-17T12:00:00Z"), Time.parse("2015-11-17T19:00:00Z"))
# => {:entity=>"sensor-1", :metric=>"temperature", :start_time=>1447750800000, :end_time=>1447776000000}

query.class
# => ATSD::SeriesQuery

query.execute
# => [{:entity=>"sensor-1",
#    :metric=>"temperature",
#    :tags=>{},
#    :type=>"HISTORY",
#    :aggregate=>{"type"=>"DETAIL"},
#    :data=>
#     [{"t"=>1428301869000, "v"=>24.0},
#      {"t"=>1428301884000, "v"=>23.0},
#      {"t"=>1428301899000, "v"=>23.5},
# ...

query.result
# same result

s = query.result.first
s.entity
# => "sensor-1"
```

Aggregated query:

```ruby
query.aggregate(types:[SeriesQuery::AggregateType::AVG], period:{count:1, unit:SeriesQuery::Period::HOUR})
# => {:entity=>"sensor-1",
#  :metric=>"temperature",
#  :end_time=>1428303004000,
#  :aggregate=>{:types=>["AVG"], :period=>{:count=>1, :unit=>"HOUR"}}}

query.execute
# => [{:entity=>"sensor-1",
#   :metric=>"temperature",
#   :tags=>{},
#   :type=>"HISTORY",
#   :aggregate=>{"type"=>"AVG", "period"=>{"count"=>1, "unit"=>"HOUR"}},
#   :data=>[{"t"=>1428300000000, "v"=>23.57}]}]
```

Query with Versions:

```ruby
query = atsd.series_service.query("sensor-2", "pressure", Time.parse("2015-11-17T12:00:00Z"), Time.parse("2015-11-17T19:00:00Z"), {:versioned => true})
query.execute
template = "%23s,   %13s,   %23s,   %17s,   %17s\n"
output = sprintf(template, "sample_time", "sample_value", "version_time", "version_source", "version_status")
query.result.each do |data|
    samples = data.data.sort_by{|sample| sample["version"]["t"]}
    samples.each {|sample| output << sprintf(template, Time.at(sample["t"]/1000).strftime("%Y-%m-%dT%H:%M:%SZ"), sample["v"], Time.at(sample["version"]["t"]/1000).strftime("%Y-%m-%dT%H:%M:%SZ"), sample["version"]["source"], sample["version"]["status"])  }
end
puts output
            sample_time,    sample_value,              version_time,      version_source,      version_status
   2015-11-17T17:00:00Z,             7.0,      2015-11-18T19:19:57Z,           gateway-1,              normal
   2015-11-17T18:00:00Z,            17.0,      2015-11-18T19:19:57Z,           gateway-1,               error
   2015-11-17T17:00:00Z,             7.0,      2015-11-18T19:22:05Z,           gateway-1,              normal
   2015-11-17T18:00:00Z,            17.0,      2015-11-18T19:22:05Z,           gateway-1,               error
   2015-11-17T17:00:00Z,             7.0,      2015-11-18T19:23:28Z,           gateway-1,              normal
   2015-11-17T18:00:00Z,            17.0,      2015-11-18T19:23:28Z,           gateway-1,               error
   2015-11-17T17:00:00Z,             7.0,      2015-11-18T19:36:18Z,           gateway-1,              normal
   2015-11-17T18:00:00Z,            17.0,      2015-11-18T19:36:18Z,           gateway-1,               error
   2015-11-17T17:00:00Z,             7.0,      2015-11-18T19:37:02Z,           gateway-1,              normal
   2015-11-17T18:00:00Z,            17.0,      2015-11-18T19:37:02Z,           gateway-1,               error
   2015-11-17T17:00:00Z,             7.0,      2015-11-18T20:41:10Z,           gateway-1,              normal
   2015-11-17T18:00:00Z,            17.0,      2015-11-18T20:41:10Z,           gateway-1,               error
   2015-11-17T17:00:00Z,             7.0,      2015-11-18T20:45:57Z,           gateway-1,              normal
   2015-11-17T18:00:00Z,            17.0,      2015-11-18T20:45:57Z,           gateway-1,               error
   2015-11-17T17:00:00Z,             7.0,      2015-11-19T11:25:40Z,           gateway-1,              normal
   2015-11-17T18:00:00Z,            17.0,      2015-11-19T11:25:40Z,           gateway-1,               error
   2015-11-17T17:00:00Z,             7.0,      2015-11-19T11:29:36Z,           gateway-1,              normal
   2015-11-17T18:00:00Z,            17.0,      2015-11-19T11:29:36Z,           gateway-1,               error
   2015-11-17T17:00:00Z,             7.0,      2015-11-19T11:32:35Z,           gateway-1,              normal
   2015-11-17T18:00:00Z,            17.0,      2015-11-19T11:32:35Z,           gateway-1,               error
```

Inserting series:

```ruby
s = Series.new
s.entity = 'sensor-1'
s.metric = 'temperature'
s.data = [ {t: Time.now.to_i*1000, v: 22} ]
atsd.series_service.insert(s)
```

Inserting series using Sample class:

```ruby
s = Series.new
s.entity = 'sensor-1'
s.metric = 'pressure'
sample = Sample.new :time => Time.parse("2015-11-17T17:00:00Z"), :value => 7, :version => {:status => "normal", :source => "gateway-1"}
s.data = [ sample ]
series_service.insert(s)
```

Inserting Series with Versions:

```ruby
sample_1 = Sample.new :time => Time.parse("2015-11-17T17:00:00Z"), :value => 7, :version => {:status => "normal", :source => "gateway-1"}
sample_2 = Sample.new :time => Time.parse("2015-11-17T18:00:00Z"), :value => 17, :version => {:status => "error", :source => "gateway-1"}
series = Series.new :entity => "sensor-1", :metric => "pressure", :data => [sample_1, sample_2]
atsd.series_service.insert(series)
```

**CSV Insert**

data.csv contents:
```plain
time, pressure, temperature
1447228800000, 39,    29.23
1447315200000, 32,    29.24
1447401600000, 40,    29.23
1447488000000, 37,    29.25
1447574400000, 39,    29.26
1447660800000, 37,    29.21
1447747200000, 38,    29.20
1447833600000, 36,    29.23
1447920000000, 37,    29.25
1448006400000, 38,    29.25
```

Inserting CSV data from file:
```ruby
series_service.csv_insert('sensor-1', File.read('/path/to/data.csv'), { :user => 'beta' })
```

#### Properties Service

```ruby
properties_service = atsd.properties_service
# => #<ATSD::PropertiesService:0x007f82a456e6f8

property = Property.new
property.entity = 'sensor-1'
property.type = 'sensor_type'
property.tags = {"location":"NUR","site":"building-1"}
property.keys = {"id": "ch-15"}
properties_service.insert(property)

properties_service.query('sensor-1', 'sensor_type').execute
# => [{:type=>"sensor_type",
#  :entity=>"sensor-1",
#  :tags=>{"location"=>"NUR", "site"=>"building-1"},
#  :timestamp=>1428304255068,
#  :keys=>{"id"=>"ch-15"}}]

properties_service.delete(property)
properties_service.query('sensor-1', 'sensor_type').execute
# => []
```

#### Alerts Service

```ruby
alerts_service = atsd.alerts_service
# => #<ATSD::AlertsService:0x007faf7c0efdc0

alerts_service.query.execute
# => [{:value=>447660.0,
#     :id=>4,
#     :text_value=>"447660",
#     :tags=>{},
#     :metric=>"meminfo.active",
#     :entity=>"sensor-1",
#     :severity=>3,
#     :rule=>"My rule!",
#     :repeat_count=>5,
#     :open_time=>1428330612667,
#     :open_value=>445144.0,
#     :acknowledged=>false,
#     :last_event_time=>1428330687440},
#    {:value=>447660.0,
#     :id=>6,
#     :text_value=>"447660",
#     :tags=>{},
#     :metric=>"meminfo.active",
#     :entity=>"sensor-1",
#     :severity=>3,
# ...
```
#### Metrics Service

```ruby
metrics_service = atsd.metrics_service
# => #<ATSD::MetricsService:0x007fbb548d9548

metrics_service.list
# => [{:name=>"activemq_metrics_count",
#     :enabled=>true,
#     :data_type=>"FLOAT",
#     :counter=>false,
#     :persistent=>true,
#     :time_precision=>"MILLISECONDS",
#     :retention_interval=>0,
#     :invalid_action=>"NONE",
#     :last_insert_time=>1428328861848},
#     :versioned=>true
#    {:name=>"activemq_properties_count",
#     :enabled=>true,
#     :data_type=>"FLOAT",
#     :counter=>false,
#     :persistent=>true,
# ...

metrics_service.entity_and_tags('df.disk_size')
# => [{:entity=>"server-1", :tags=>{"file_system"=>"/dev/sda1", "mount_point"=>"/"}, :last_insert_time=>1428328928000},
#  {:entity=>"server-1", :tags=>{"file_system"=>"none", "mount_point"=>"/sys/fs/cgroup"}, :last_insert_time=>1428328928000},
#  {:entity=>"server-1", :tags=>{"file_system"=>"none", "mount_point"=>"/run/lock"}, :last_insert_time=>1428328928000},
#  {:entity=>"server-1", :tags=>{"file_system"=>"none", "mount_point"=>"/run/shm"}, :last_insert_time=>1428328928000},
#  {:entity=>"server-2", :tags=>{"file_system"=>"none", "mount_point"=>"/run/user"}, :last_insert_time=>1428328928000},
#  {:entity=>"server-2", :tags=>{"file_system"=>"udev", "mount_point"=>"/dev"}, :last_insert_time=>1428328928000},
#  {:entity=>"server-2", :tags=>{"file_system"=>"tmpfs", "mount_point"=>"/run"}, :last_insert_time=>1428328928000}]

metric = Metric.new
# => {}
metric.name = "energy_usage"
# => "energy_usaget"
metric.versioned = true
# => true
metrics_service.create_or_replace(metric)
metrics_service.get("energy_usage")
# => {:name=>"energy_usage", :enabled=>true, :data_type=>"FLOAT", :counter=>false, :persistent=>true, :tags=>{}, :time_precision=>"MILLISECONDS", :retention_interval=>0, :invalid_action=>"NONE", :versioned=>true}

```

#### Entities Service

```ruby
entities_service = atsd.entities_service
# => #<ATSD::EntitiesService:0x007f82a45b40b8

entities_service.list(:limit => 10)
# => [{:name=>"atsd", :enabled=>true, :last_insert_time=>1428304482631},
#  {:name=>"mine", :enabled=>true},
#  {:name=>"test_entity", :enabled=>true, :last_insert_time=>1428304489000},
#  {:name=>"sensor-1", :enabled=>true, :last_insert_time=>1428304489000}]

entities_service.get('sensor-1')
# => {:name=>"sensor-1", :enabled=>true, :last_insert_time=>1428304499000, :tags=>{}}

entities_service.metrics('server-1')
# => [{:name=>"df.disk_size",
#   :enabled=>true,
#   :data_type=>"FLOAT",
#   :counter=>false,
#   :persistent=>true,
#   :time_precision=>"MILLISECONDS",
#   :retention_interval=>0,
#   :invalid_action=>"NONE",
#   :last_insert_time=>1428304499000},
#  {:name=>"df.disk_used",
#   :enabled=>true,
# ...

entities_service.delete(entities_service.get('server-1')) # or entities_service.delete('server-1')
entities_service.list
# => [{:name=>"atsd", :enabled=>true, :last_insert_time=>1428304482631},
#  {:name=>"test_entity", :enabled=>true, :last_insert_time=>1000000000},
#  {:name=>"sensor-1", :enabled=>true, :last_insert_time=>1428304489000}]
```
#### Entity Groups Service 

```ruby
entity_groups_service = atsd.entity_groups_service
# => #<ATSD::EntityGroupsService:0x007fb1b2a0d7f8

entity_groups_service.create_or_replace('group1')
entity_groups_service.list
# => [{:name=>"group1"}]

entity_groups_service.add_entities('group1', [{name:'entity1'},{name:'entity2'}])
entity_groups_service.entities(entity_groups_service.get('group1'))
# => [{:name=>"entity1", :enabled=>true}, {:name=>"entity2", :enabled=>true}]

entity_groups_service.delete_all_entities('group1')
entity_groups_service.entities('group1')
# => []
```

### Errors
If the request wasn't completed successfully then an `ATSD::APIError` exception is raised. You can get a message and HTTP status code using the `message` and `status`
fields.

### Low-level API Client
Gem also provides an `ATSD::Client` class. It is a simple API wrapper 
which uses [Faraday](https://github.com/lostisland/faraday) to handle HTTP-related routines. 
All services are built on top of it. 

You can access `Faraday::Connection` object using the `connection` field of the client if necessary.

## Development

After checking out the repository, run `bin/setup` to install dependencies. 
Then run `bin/console` for an interactive prompt that will allow you to experiment with the client.

To install this gem onto your local machine, run `bundle exec rake install`. 
