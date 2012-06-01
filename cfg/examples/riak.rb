project "Riak" do
  server "localhost"

  riak_stats = %w[
    riak_kv_vnodes_running
    vnode_gets
    vnode_puts
    cpu_nprocs
  ]
  
  http 8098 do
    get "/stats" do

      riak_stats.each do |t|
        test "#{t}" do |r|
          r.body.match /"#{t}":(\d+)/
        end
      end

      test "CPU Avg 1/5/15" do |r|
        r.body.match(/"cpu_avg1":(\d+),"cpu_avg5":(\d+),"cpu_avg15":(\d+)/).captures.join("/")
      end
    end
  end

  riak_ports = {
    epmd_port:    4369,
    handoff_port: 8099,
    pb_port:      8087,
  }

  riak_ports.each do |name, num|
    socket num do
      open? do 
        test "#{name} open?" do |r|
          r
        end
      end
    end
  end
end

