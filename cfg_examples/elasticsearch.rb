require 'json'

project "Elasticsearch - Production" do
  server "localhost"
  
  http 9200 do
    timeout 3

    get "/" do
      before_tests do |r|
        r.body = JSON.parse(r.body)
        r
      end

      test "version" do |r|
        status = r.body["version"]["number"]
      end

      test "snapshot build?" do |r|
        build = r.body["version"]["snapshot_build"]
        Result build.to_s, build == false
      end

    end

    get "/_settings" do
      before_tests do |r|
        r.body = JSON.parse(r.body)
        r
      end

      test "translog flush disabled?" do |r|
        color = r.body["brew_production-0"]["settings"]["index.translog.disable_flush"]
        status = case color
          when 'false' then :ok
          when 'true'  then :warn
          else              :ok
        end
        Result color, Status(status)
      end
    end

    get "/_cluster/settings" do
      before_tests do |r|
        r.body = JSON.parse(r.body)
        r
      end

      test "replica allocation disabled?" do |r|
        color = r.body["transient"]["cluster.routing.allocation.disable_replica_allocation"]
        status = case color
          when 'false' then :ok
          when 'true'  then :warn
          else              :ok
        end
        Result color, Status(status)
      end
      test "shard allocation disabled?" do |r|
        color = r.body["transient"]["cluster.routing.allocation.disable_allocation"]
        status = case color
          when 'false' then :ok
          when 'true'  then :warn
          else              :ok
        end
        Result color, Status(status)
      end

    end

    get "/_cluster/health" do
      ## this runs after request returns, but before tests
      ## use it to munge response body from json string into a hash
      before_tests do |r|
        r.body = JSON.parse(r.body)
        r
      end

      test "HTTP Status" do |r|
        Result r.code, r.code == '200'
      end
      
      test "cluster status" do |r|
        color = r.body["status"]
        status = case color
          when 'green'  then :ok
          when 'yellow' then :warn
          else               :error
        end
        Result color, Status(status)
      end

      stats = %w[
        cluster_name
        number_of_nodes
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

      test "number of data nodes" do |r|
        nodes = r.body['number_of_data_nodes']
        Result nodes, nodes == 4
      end

    end

    get "/_nodes/_local/stats?all" do
      before_tests do |r|
        JSON.parse(r.body)
      end

      test "open file descriptors" do |r|
        r['nodes'].first[1]['process']['open_file_descriptors']
      end

      test "heap used" do |r|
        used, committed = r["nodes"].first[1]['jvm']['mem'].values_at('heap_used','heap_committed')
        "#{used} (of #{committed})"
      end

    end

  end

end
