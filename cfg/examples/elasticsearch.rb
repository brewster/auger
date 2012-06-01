require 'json'

project "Elasticsearch" do
  server "localhost"
 
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

      # simple as it gets... did we get 200 back?
      test "Status 200" do |r|
        r.code == '200'
      end

      # an array of stats we want to collect
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

      # loop through each stat
      # if the body is a hash, return the value
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

