project "Imagine" do
  fqdns "imagine.brewster.com"
  hosts "prod-dims-r[01-10]"
  
  https 8100 do
    insecure true

    get "/" do
      test "Version" do |r|
        r.body.match /"version":"(\d+.\d+.\d+)"/
      end
    end

    get "/_status" do
      test "Status 200" do |r|
        r.code == '200'
      end
      test "Status Page" do |r|
        r.body.match /(ok)/
      end
    end
  end
end

