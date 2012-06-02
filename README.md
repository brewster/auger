# Auger

### Overview
* auger is a DSL with which you can write tests for just about everything you run in your environment
* these are the sort of questions auger can answer:
  * is port :80 on my application webservers open? does /index.html contain a response tag that we know should be served from a given backend data source?
  * is redis running? is it configured as a master? a slave?
  * is elasticsearch responding on all my hosts it should be? what's the cluster state? do I have the number of data nodes responding that we're supposed to have?
* clearly a lot of this information include things you should be graphing. What auger wants to do it give you a really quick overview of current status: green == good, red == ruh roh!

### Currently Supported Plugins
* http/s
* telnet
* socket
* cassandra

### Insallation
* gem install auger

#### If you want to run the latest source:
* ```git clone git@github.com/brewster/auger```
* ```cd auger; rake build; gem install pkg/auger-x.x.x.gem```

### Usage
* sample configs included in cfg/examples/ can be moved into cfg/ and then run via ```aug redis```, etc
* alternatively, you can place your configs anywhere you'd like and set the env_var AUGER_CFG=/path/to/your/configs/prod:/path/to/your/configs/stage
* then, you can call your tests via ```aug name_of_my_config```
* ```aug -l``` will print available tests
* ```aug -h``` will print usage details

### Configuration
* please see cfg/examples for some included tests that you can make use of and learn from to write your own

#### Example 1
 
We'll require json for this particular test (as the elasticsearch api outputs in json)
The project name is defined, then we specify the servers we're going to test, which can be a regex, for example ```servers elasticsearch-d[01-08]```

```ruby
require 'json'

project "Elasticsearch" do
  servers "localhost"
```


We define the request to initiate, in this case to /_cluster/health, which will use http and connect to :9200.
I'll let the comments for before_tests speak for themselves.

```ruby  
  http 9200 do
    get "/_cluster/health" do

      # this runs after request returns, but before tests
      # use it to munge response body from json string into a hash
      before_tests do |r|
        if r['Content-Type'].respond_to?(:match) and r['Content-Type'].match /application\/json/
          begin 
            r.body = JSON.parse(r.body)
          rescue JSON::ParserError
            puts "error parsing JSON in response body"
          end
        end
      end
```


Here's our first test. Can't get much more basic that just checking to see if we get an HTTP status code of '200' back.
If the response is true, you'll see a green check mark. False will return a red X.

```ruby
      test "Status 200" do |r|
        r.code == '200'
      end
```


Now we'll define an array called stats, which contains all the keys we want to retrieve values from in our /_cluster/health output.
In this case, we'll just return the body of the response, as it's relatively small. You can of course parse this however you'd like for 
this or other cases.

```ruby
      stats = %w[
        cluster_name
        status
        timed_out
        number_of_nodes
        number_of_data_nodes
        active_primary_shards
        active_shards
        relocating_shards
        initializing_shards
        unassigned_shards
      ]

      stats.each do |stat|
        test "#{stat}" do |r|
          if r.body.is_a? Hash
            r.body[stat]
          else
            false
          end
        end
      end

      # I've discovered that a typical fail case with elasticsearch is 
      #   that on occassion, nodes will come up and not join the cluster
      # This is an easy way to see if the number of nodes that the host 
      #   actually sees (actual_data_nodes) matches what we're
      #   expecting (expected_data_nodes).
      # TODO: dynamically update expected_data_nodes based on defined hosts:
      test "Expected vs Actual Nodes" do |r|
        if r.body.is_a? Hash
          expected_data_nodes = 8
          actual_data_nodes = r.body['number_of_data_nodes']

          if expected_data_nodes == actual_data_nodes
            true
          else
            false
          end
        else
          false
        end
      end
    end
  end
end
```

#### Example 2
* in addition to the straight forward servers:port association described in the example above, we can also define roles
* roles are used much as in capistrano, and let us do things like the following:

```ruby
project "Imagine" do
  servers "imagine.brewster.com", :fqdn, :port => 443
  servers "prod-dims-r[01-10]", :app, :port => 9999

  https do
    roles :app, :fqdn
    insecure true

    ... test code ...
```

* so here we assign a role of :fqdn to imagine.brewster.com, and :app to the machines that are actually running that app on the backend
* we then override the default port in each case, since our app servers run the service on :9999, while the fqdn makes use of a vip and port translation to run on :443.
* the upshot of this is that you can make use of roles and custom ports to deal with scenarios such as mulitple app servers for a given project running on different ports, or as is the case above, a public url for our app that uses a different port than our app servers.
* you can of course assign given roles only to certain tests as well, e.g.

```ruby
project "ChronoSynclasticInfundibulum" do
  servers "chrono-r0[1-3]", :web
  servers "synclastic-r0[1-3]", :data

  https do
    roles :web
    ... https test code ...
  end


  data_ports = {
    infun:    1234,
    dibulum:  5678,
  }

  data_ports.each do |name, num|
    roles :data

    socket num do
      open? { test "Is #{name} (#{num}) open?" }
    end
  end
end
```

* this will have the effect of only running the http tests against your :web servers, and only checking for the specified open ports on your :data servers

### Pull Requests
* yes please
* new plugins and genereal bug fixes, updates, etc are all welcome


### Command Line Auto-completion for Tests
* BASH completion:

        function _augcomp () {
          augcfgs=$(aug -l|xargs) local word=${COMP_WORDS[COMP_CWORD]}
          COMPREPLY=($(compgen -W "$augcfgs" -- "${word}"))
        }
        complete -F _augcomp aug


* ZSH completion:

        _augprojects () {
          _files; compadd $(aug -l)
        }
        compdef _augprojects aug

