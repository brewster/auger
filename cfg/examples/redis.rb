project "Redis" do
  hosts "localhost"

  telnet 6379 do
    timeout "3"
    binmode false

    # issues and info command followed by quit,
    #   otherwise, we'll hang on an open port.
    cmd "info\n\nquit\n\n" do
      test "version" do |r|
        r.match /redis_version:(.+)/
      end
      test "role" do |r|
        r.match /role:(.+)/
      end
      test "uptime_in_days" do |r|
        r.match /uptime_in_days:(.+)/
      end
      test "used memory" do |r|
        r.match /used_memory_human:(.+)/
      end
      test "blocked clients" do |r|
        r.match /blocked_clients:(.+)/
      end
      test "connected slaves" do |r|
        r.match /connected_slaves:(.+)/
      end
    end
  end
end

