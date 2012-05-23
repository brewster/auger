project "Webserver Nginx" do
  fqdns "www.wickedcoolurl.com"
  hosts "frontend-r[01-04]"

  http 80 do
    get "/status" do
      header "Location: www.wickedcoolurl.com"

      test "Sign-in moved" do |response|
        response.body.match /the site is up/
      end
    end
  end

  https 443 do
    insecure true

    get "/index.html" do
      test "Index" do |r|
        response.body.match /HEAD/
      end
    end
  end

  ## example telnet request
  telnet 80 do
    timeout "3"
    binmode false
    
    cmd "HEAD / HTTP/1.1\n\n" do
      test "Telnet Port 80" do |r|
        r.match /Server: (nginx\/[\d\.]+)/
      end
    end
  end
end

