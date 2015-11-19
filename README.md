# Axibase Time-Series Database Client for Ruby

The ATSD Client for Ruby enables Ruby developers 
to easily read and write statistics and metadata 
from Axibase Time-Series Database.

API documentation: https://axibase.com/atsd/api

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'atsd'
```

Then execute:

    $ bundle

Or install manually:

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

To start using the gem you need to create an ATSD instance:

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
of the following forms:

- `"login:password"`
- `{ :login => 'login', :password => 'password' }`

#### SSL 
ATSD requires a little extra configuration for users who want to use SSL/HTTPS. 
See [Faraday Wiki](https://github.com/lostisland/faraday/wiki/Setting-up-SSL-certificates) on how
to setup SSL. As a quickfix you can specify `ssl: { verify: false }` option in the client.

#### Logging

- To use a custom logger specify it in the `:logger` option. 
- To use default STDOUT logger set `:logger` option to `true`. 

#### Faraday Middleware

```ruby
ATSD.new url: end_point, basic_auth: basic_auth do |builder|
  builder.insert_after(FaradayMiddleware::ParseJson, VCR::Middleware::Faraday)
  # ... 
end
```

### Services
Once you instantiated the ATSD class, you can use different services. 
Each service represents a particular entity in Axibase Time Series Database.
There are 6 services: series, properties, alerts, metrics, entities and
entity groups.

See documentation for all available methods.

#### Query builders
Query objects created by some services (e.g. Series) provide convenient methods to build complex queries.
They support method chaining and automatically translate snake_styled properties 
to CamelCase used in the API. For example, `end_time` property in ruby code becomes `endTime` in json request.

#### Series Service

Simple query:

```ruby
series_service = atsd.series_service
# => #<ATSD::SeriesService:0x007f82a4446c08

query = series_service.query('ubuntu', 'meminfo.memfree')
# => {:entity=>"ubuntu", :metric=>"meminfo.memfree"}

query.class
# => ATSD::SeriesQuery

query.end_time(Time.now)
# => {:entity=>"ubuntu", :metric=>"meminfo.memfree", :end_time=>1428303004000}

query.execute
# => [{:entity=>"ubuntu",
#    :metric=>"meminfo.memfree",
#    :tags=>{},
#    :type=>"HISTORY",
#    :aggregate=>{"type"=>"DETAIL"},
#    :data=>
#     [{"t"=>1428301869000, "v"=>78728.0},
#      {"t"=>1428301884000, "v"=>68676.0},
#      {"t"=>1428301899000, "v"=>66716.0},
# ...

query.result
# same result

s = query.result.first
s.entity
# => "ubuntu"
```

Complex query:

```ruby
query.aggregate(types:[SeriesQuery::AggregateType::AVG], interval:{count:1, unit:SeriesQuery::Interval::HOUR})
# => {:entity=>"ubuntu",
#  :metric=>"meminfo.memfree",
#  :end_time=>1428303004000,
#  :aggregate=>{:types=>["AVG"], :interval=>{:count=>1, :unit=>"HOUR"}}}

query.execute
# => [{:entity=>"ubuntu",
#   :metric=>"meminfo.memfree",
#   :tags=>{},
#   :type=>"HISTORY",
#   :aggregate=>{"type"=>"AVG", "interval"=>{"count"=>1, "unit"=>"HOUR"}},
#   :data=>[{"t"=>1428300000000, "v"=>82615.05263157895}]}]
```

Query with Versions:

```ruby
query = atsd.series_service.query("sensor-1", "temperature", Time.new(2015, 11, 17, 12, 0, 0), Time.new(2015, 11, 17, 19, 0, 0), {:versioned => true})
query.execute
template = "%23s,   %13s,   %23s,   %17s,   %17s\n"
output = sprintf(template, "sample_time", "sample_value", "version_time", "version_source", "version_status")
query.result.each {|data| data.data.each {|sample| output << sprintf(template, Time.at(sample["t"]/1000).utc, sample["v"], Time.at(sample["version"]["t"]/1000).utc, sample["version"]["source"], sample["version"]["status"])  }}
puts output
            sample_time,    sample_value,              version_time,      version_source,      version_status
2015-11-17 14:00:00 UTC,             7.0,   2015-11-18 16:19:57 UTC,           gateway-1,              normal
2015-11-17 14:00:00 UTC,             7.0,   2015-11-18 16:22:05 UTC,           gateway-1,              normal
2015-11-17 14:00:00 UTC,             7.0,   2015-11-18 16:23:28 UTC,           gateway-1,              normal
2015-11-17 14:00:00 UTC,             7.0,   2015-11-18 16:36:18 UTC,           gateway-1,              normal
2015-11-17 14:00:00 UTC,             7.0,   2015-11-18 16:37:02 UTC,           gateway-1,              normal
2015-11-17 14:00:00 UTC,             7.0,   2015-11-18 17:41:10 UTC,           gateway-1,              normal
2015-11-17 14:00:00 UTC,             7.0,   2015-11-18 17:45:57 UTC,           gateway-1,              normal
2015-11-17 15:00:00 UTC,            17.0,   2015-11-18 16:19:57 UTC,           gateway-1,               error
2015-11-17 15:00:00 UTC,            17.0,   2015-11-18 16:22:05 UTC,           gateway-1,               error
2015-11-17 15:00:00 UTC,            17.0,   2015-11-18 16:23:28 UTC,           gateway-1,               error
2015-11-17 15:00:00 UTC,            17.0,   2015-11-18 16:36:18 UTC,           gateway-1,               error
2015-11-17 15:00:00 UTC,            17.0,   2015-11-18 16:37:02 UTC,           gateway-1,               error
2015-11-17 15:00:00 UTC,            17.0,   2015-11-18 17:41:10 UTC,           gateway-1,               error
2015-11-17 15:00:00 UTC,            17.0,   2015-11-18 17:45:57 UTC,           gateway-1,               error
```

Data Insertion:

```ruby
s = Series.new
s.entity = 'ubuntu'
s.metric = 'meminfo.memfree'
s.data = [ {t: 100000000, v: 512} ]
series_service.insert(s)
```

Inserting Series with Versions:

```ruby
sample_1 = Sample.new :t => Time.new(2015, 11, 17, 17, 0, 0), :v => 7, :version => {:status => "normal", :source => "gateway-1"}
sample_2 = Sample.new :t => Time.new(2015, 11, 17, 18, 0, 0), :v => 17, :version => {:status => "error", :source => "gateway-1"}
series = Series.new :entity => "sensor-1", :metric => "temperature", :data => [sample_1, sample_2]
atsd.series_service.insert(series)
```

**CSV Insert**

data.csv contents:
```plain
time, mem.info.memfree, meminfo.memused
1414789200000,  0.8,     0.0
1414789230000,  1.6,     1.0
1414789800000,  2.4,    -3.0
1414800000000,  3.2,    23.0
1414861200000,  4.0,     7.0
1415134800000,  0.0,     0.8
1415800800000,  1.0,     1.6
1417244400000, -3.0,     2.4
1433106000000, 23.0,     3.2
1446238800000,  7.0,     4.0
```

Inserting csv data example:
```ruby
series_service.csv_insert('ubuntu', File.read('/path/to/data.csv'), { :user => 'beta' })
```

#### Properties Service

```ruby
properties_service = atsd.properties_service
# => #<ATSD::PropertiesService:0x007f82a456e6f8

property = Property.new
property.entity = 'ubuntu'
property.type = 'system'
property.key = {"server_name":"server","user_name":"system"}
property.tags = {"name.1": "value.1"}
properties_service.insert(property)

properties_service.query('ubuntu', 'system').execute
# => [{:type=>"system",
#  :entity=>"ubuntu",
#  :key=>{"server_name"=>"server", "user_name"=>"system"},
#  :timestamp=>1428304255068,
#  :tags=>{"name.1"=>"value.1"}}]

properties_service.delete(property)
properties_service.query('ubuntu', 'system').execute
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
#     :entity=>"ubuntu",
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
#     :entity=>"ubuntu",
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
# => [{:entity=>"ubuntu", :tags=>{"file_system"=>"/dev/sda1", "mount_point"=>"/"}, :last_insert_time=>1428328928000},
#  {:entity=>"ubuntu",
#   :tags=>{"file_system"=>"none", "mount_point"=>"/sys/fs/cgroup"},
#   :last_insert_time=>1428328928000},
#  {:entity=>"ubuntu", :tags=>{"file_system"=>"none", "mount_point"=>"/run/lock"}, :last_insert_time=>1428328928000},
#  {:entity=>"ubuntu", :tags=>{"file_system"=>"none", "mount_point"=>"/run/shm"}, :last_insert_time=>1428328928000},
#  {:entity=>"ubuntu", :tags=>{"file_system"=>"none", "mount_point"=>"/run/user"}, :last_insert_time=>1428328928000},
#  {:entity=>"ubuntu", :tags=>{"file_system"=>"udev", "mount_point"=>"/dev"}, :last_insert_time=>1428328928000},
#  {:entity=>"ubuntu", :tags=>{"file_system"=>"tmpfs", "mount_point"=>"/run"}, :last_insert_time=>1428328928000}]

metric = Metric.new
# => {}
metric.name = "cpu_count"
# => "cpu_count"
metric.versioned = true
# => true
metrics_service.create_or_replace(metric)
metrics_service.get("cpu_count")
# => {:name=>"cpu_count", :enabled=>true, :data_type=>"FLOAT", :counter=>false, :persistent=>true, :tags=>{}, :time_precision=>"MILLISECONDS", :retention_interval=>0, :invalid_action=>"NONE", :versioned=>true}

```

#### Entities Service

```ruby
entities_service = atsd.entities_service
# => #<ATSD::EntitiesService:0x007f82a45b40b8

entities_service.list
# => [{:name=>"atsd", :enabled=>true, :last_insert_time=>1428304482631},
#  {:name=>"mine", :enabled=>true},
#  {:name=>"test_entity", :enabled=>true, :last_insert_time=>1000000000},
#  {:name=>"ubuntu", :enabled=>true, :last_insert_time=>1428304489000}]

entities_service.get('ubuntu')
# => {:name=>"ubuntu", :enabled=>true, :last_insert_time=>1428304499000, :tags=>{}}

entities_service.metrics('ubuntu')
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

entities_service.delete(entities_service.get('mine')) # or entities_service.delete('mine')
entities_service.list
# => [{:name=>"atsd", :enabled=>true, :last_insert_time=>1428304482631},
#  {:name=>"test_entity", :enabled=>true, :last_insert_time=>1000000000},
#  {:name=>"ubuntu", :enabled=>true, :last_insert_time=>1428304489000}]
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
Client has 1-to-1 mapping for all REST methods specified on https://axibase.com/atsd/api.

You can access `Faraday::Connection` object using the `connection` field of the client if necessary.

## Development

After checking out the repository, run `bin/setup` to install dependencies. 
Then run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

