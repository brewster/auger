project "Redis" do
  server "localhost"

  telnet 6379 do
    timeout "3"
    binmode false

    tests = %w[
      role
      redis_version
      uptime_in_days
      used_memory_human
      blocked_clients
      connected_slaves
      connected_clients
    ]


    # issue an info command followed by quit,
    #   otherwise, we'll hang on an open port.
   
    cmd "info\n\nquit\n\n" do
      tests.each do |t|
        test "#{t}" do |r|
          r.match /#{t}:(.+)/
        end
      end
    end
  end
end
