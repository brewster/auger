project "Riak Profiles" do
  hosts "prod-riakp-r[01-08]"
  
  http 8098 do
    get "/stats" do
      test "Riak KV Vnodes Running" do |r|
        r.body.match /"riak_kv_vnodes_running":(\d+)/
      end
      test "Vnode Gets" do |r|
        r.body.match /"vnode_gets":(\d+)/
      end
      test "Vnode Puts" do |r|
        r.body.match /"vnode_puts":(\d+)/
      end
      test "CPU Nprocs" do |r|
        r.body.match /"cpu_nprocs":(\d+)/
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
