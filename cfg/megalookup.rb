project "Megalookup" do
  hosts "prod-lookup-r[01-02]"
  
  https 443 do
    insecure true

    get "/status" do
      test "Status 200" do |r|
        r.code == '200'
      end
    end
  end

end
