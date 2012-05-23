project "Socktalk" do
  fqdns "socktalk.brewster.com"
  hosts "prod-sockio-r[01-02]"
  
  https 8888 do
    insecure true

    get "/_status" do
      test "Status ok" do |r|
        r.body.match /(ok)/
      end
      test "Status 200" do |r|
        r.code == '200'
      end
    end
  end

  socktalk_ports = {
    gossip_port:    8888,
    external_port:  9999,
  }

  socktalk_ports.each do |name, num|
    socket num do
      open? do 
        test "#{name} open?" do |r|
          r
        end
      end
    end
  end
end

