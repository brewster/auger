project "Webserver Nginx" do
  servers "www.wickedcoolurl.com", :fqdn, :port => 80
  servers "frontend-r[01-04]", :app, :port => 6666
  servers "data-r[01-04]", :data

  http do
    roles :fqdn, :app

    get "/status" do
      header "Location: www.wickedcoolurl.com"

      test "Site is up?" do |r|
        r.body.match /the site is up/
      end
    end
  end

  https do
    roles :fqdn

    get "/index.html" do
      test "Index" do |r|
        r.body.match /HEAD/
      end
    end
  end
  https do
    roles :app
    insecure true

    get "/index.html" do
      test "Index" do |r|
        r.body.match /HEAD/
      end
    end
  end

  telnet do
    roles :fqdn, :app
    timeout "3"
    binmode false
    
    cmd "HEAD / HTTP/1.1\n\n" do
      test "Telnet Port 80" do |r|
        r.match /Server: (nginx\/[\d\.]+)/
      end
    end
  end

  socket 9999 do
    roles :data

    open? { test "Port 9999 is open?" }
  end
end

