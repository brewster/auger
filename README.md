# Auger

The Auger library implements a ruby DSL for describing tests to be run
against remote applications on multiple servers. The gem includes
'aug', a multi-threaded command-line client.

The primary goal of Auger is test-driven operations: unit testing for
application admins. The library can also be used as a framework for
implmenting automated tests.

* these are the sorts of questions auger can answer:

  * is port :80 on my application webservers open? does /index.html
    contain a response tag that we know should be served from a given
    backend data source?

  * is redis running? is it configured as a master? a slave?

  * is elasticsearch responding on all my hosts it should be? what's
    the cluster state? do I have the number of data nodes responding
    that we're supposed to have?

* clearly a lot of this information includes things you should be
  graphing. What auger wants to do it give you a really quick overview
  of current status: green == good, red == ruh roh!

## Plugins

Specific protocols are implemented using plugins, which are designed
to be easy to write wrappers on existing gems. Auger currently includes
the following plugins:

* http - http and https requests using `net/http`
* telnet - send arbitrary commands to a port using `net/telnet`
* socket - test whether a port is open
* cassandra - CQL requests using `cassandra-cql` gem

## Installation

* gem install auger

### If you want to run the latest source:

* ```git clone git@github.com/blah/auger``` TODO => fix github url

* ```cd auger; rake install```

## Command-line client usage

* sample configs included in cfg/examples/ can be moved into cfg/ and
  then run via ```aug redis```, etc

* alternatively, you can place your configs anywhere you'd like and
  set the env_var: ```AUGER_CFG=/path/to/your/configs/prod:/path/to/your/configs/stage```

  * now call your tests via ```aug name_of_my_config```

  * configs should be named some_name.rb

* ```aug -l``` will print available tests
* ```aug -h``` will print usage details

## Writing tests

Tests are written as ruby code describing a test configuration. Files 
containing tests should be placed in the path described by the `AUGER_CFG`
environment variable.

### Example 1 - testing a webserver response

    project "Front-end Web Servers" do
      server "web-fe-[01-02]"
      
      http 8000 do
        get '/' do
          test 'status code is 200' do |response|
            response.code == '200'
          end
        end
      end

    end

The `project` command takes a project description, and a block containing multiple
tests to be run together for that project.

`server` lists hosts that should be tested. It may be called multiple times, and
also parses host range expressions using the HostRange gem.

`http` is an example of a connection, it takes an argument with the port to
connect, and a block containing multiple requests to make.

`get` is a request, in this case an HTTP GET to the provided url, and takes a block
with multiple tests to run on the response. Plugins can return any object from
a request, in the case of `http` the response is an HTTP::Reponse object.

`test` describes a test to run on the provided response; it takes a description,
and the response is passed to a block. The result of executing the block is
presented as the result of this test (in this case true or false).

Save the config to a file `fe_web` and run with the `aug` command:

    $ aug ./fe_web
    [web-fe-01]
      status code is 200  ✓
    [web-fe-02]
      status code is 200  ✓

### Example 2 - adding more tests

Let's extend our example to be more interesting.

    project "Front-end Web Servers" do
      server 'web-fe-[01-02]', :web
      server 'www.mydomain.com', :vip, :port => 80
      
      socket 8000 do
        roles :web
        open? do
          test "port 8000 is open?"
        end
      end

      http 8000 do
        roles :web, :vip

        get '/' do
          test 'status code is 200' do |response|
            response.code == '200'
          end

          test 'document title' do |response|
            response.body.match /<title>([\w\s]+)<\/title>/
          end
        end

        get '/image.png' do
          header 'user-agent: Auger Test'

          test 'image.png has correct content-type' do |respose|
            response['Content-Type'] == 'image/png'
          end
        end
      end

    end

Servers can have roles attached to them, in this case `:web` and
`:vip`. By default a connection will be run for all servers, but the
`roles` command allows connections to be limited to the given roles.

Servers can also have a hash of options, which will override
the matching connection options for just that server. In this case
we want to connect to port 80 on the vip rather than 8000.

The `header` command demonstrates setting options for a request,
in this case setting an http request header.

The `socket` command creates a connection to the given port, and
`open?` returns true if the port is open. We just apply this to 
the real web servers and not the vip.

The document title test demonstrates how to extract and return a regex
match.  Tests can return almost any object (including Exceptions), and
auger will try to display the result using the `.to_s` method. Ruby's
MatchData object, however, gets special treatment. If the MatchData
has captures (captured using parentheses in the regex) they will be
displayed, as in this case. If no captures, the MatchData will be
treated as a boolean. The `aug` cmdline client displays booleans with
a checkmark or an 'x'.

### Example 3 - testing ElasticSearch

    require 'json'

    project "Elasticsearch" do
      servers 'prod-es-[01-04]'

      http 9200 do
        get "/_cluster/health" do

        # this runs after request returns, but before tests
        # use it to munge response body from json string into a hash
        before_tests do |r|
          r.body = JSON.parse(r.body)
        end

        test "Status 200" do |r|
          r.code == '200'
        end

        # Now we'll define an array called stats, which contains all the keys we
        # want to retrieve values from in our /_cluster/health output.  In this
        # case, we'll just return the body of the response, as it's relatively
        # small. You can of course parse this however you'd like for this or
        # other cases.
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
            r.body[stat]
          end
        end

        # I've discovered that a typical fail case with elasticsearch is 
        #   that on occassion, nodes will come up and not join the cluster
        # This is an easy way to see if the number of nodes that the host 
        #   actually sees (actual_data_nodes) matches what we're
        #   expecting (expected_data_nodes).
        # TODO: dynamically update expected_data_nodes based on defined hosts:
        test "Expected vs Actual Nodes" do |r|
          r.body['number_of_data_nodes'] == 8
        end

      end

    end
  end
end

## Writing plugins

Let's look at a simplified http plugin.

    require "net/http"

    module Auger

      class Project
        def http(port = 80, &block)
          @connections << Http.load(port, &block)
        end
      end

      class Http < Auger::Connection
        def open(host, options)
          http = Net::HTTP.new(host, options[:port])
          http.start
          http
        end

        def close(http)
          http.finish
        end

        def get(url, &block)
          @requests << Auger::HttpRequest.load(url, &block)
        end
      end

      class HttpRequest < Auger::Request
        def run(http)
          get = Net::HTTP::Get.new(@arg)
          http.request(get)
        end
      end

    end

First, we add the `http` method to the Project class. This simply causes
the 'http' command to add a connection of class Http to the project's
list of connections.

Next, we define the Http connection class by sub-classing `Auger::Connection`.
A connection class needs to define `open` and `close` methods, which will
create and destroy a connection object (in this case a Net::HTTP object).
`open` takes a hostname and the connection @options hash, and returns an
instance of the relevant request object.


## Command Line Auto-completion for aug tool

BASH completion:

    function _augcomp () {
      augcfgs=$(aug -l|xargs) local word=${COMP_WORDS[COMP_CWORD]}
      COMPREPLY=($(compgen -W "$augcfgs" -- "${word}"))
    }
    complete -F _augcomp aug


ZSH completion:

    _augprojects () { _files; compadd $(aug -l) }
    compdef _augprojects aug

## Pull Requests

* yes please

* new plugins and genereal bug fixes, updates, etc are all welcome

* generally, we'd prefer you do the following to submit a pull:

  * fork

  * create a local topic branch

  * make your changes and push

  * submit your pull request
