require 'json'

project "Elasticsearch" do
  hosts "localhost"
  
  http 9200 do
    get "/_cluster/health" do

      ## this runs after request returns, but before tests
      ## use it to munge response body from json string into a hash
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
    end
  end
end

