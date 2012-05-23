# Auger

## Overview
* auger is DSL with which you can write tests for just about everything you run in your environment
* it's like magic pixie dust for IBM servers...

## Usage
* the binary, aug, should be placed in your PATH, or aliased: ```alias aug="/path/to/auger/bin/aug"```
* sample configs included in examples/ can be moved into cfg/ and then run via ```aug redis```, etc. Edit as required for your env
* alternatively, you can place your configs anywhere you'd like and set the env_var AUGER_CFG=/path/to/your/configs
* then, you can call your tests via ```aug cfg```

## Command Line Options
* ```aug -l``` will print available tests
* ```aug -h``` will print usage details

## Configuration Examples
* please see cfg/examples for some included tests that you can make use of and learn from to write your own
* to run through an example, let's take a look at the included elasticsearch.rb

```ruby
require 'json'

project "Elasticsearch" do
  hosts "localhost"
  http 9200 do
```

>>>> We'll require json for this particular test (as the elasticsearch api outputs in json)
>>>> The project name is defined, then we specify the hosts we're going to test, which 
>>>>>> can be a regex, for example ```hosts elasticsearch-d[01-08]```
>>>> The protocol is http, port 9200... pretty easy so far.
  
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

      test "Status 200" do |r|
        r.code == '200'
      end

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

## Command Line Auto-completion
* BASH completion:

        function _augcomp () {
          augcfgs=$(aug -l|xargs) local word=${COMP_WORDS[COMP_CWORD]}
          COMPREPLY=($(compgen -W "$augcfgs" -- "${word}"))
        }
        complete -F _augcomp aug


* ZSH completion:

        _augprojects () {
          compadd $(aug -l)
        }
        compdef _augprojects aug

