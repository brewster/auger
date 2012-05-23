require 'json'

project "Megalookup" do
  hosts "prod-lookup-r[01-02]"
  
  https 443 do
    insecure true

    get "/status" do
      test "Status 200" do |r|
        r.code == '200'
      end

      # name should correspond to the hash key, value to the hash key.
      # if you want to add tests that pick up key/value pairs that are
      #   nested somewhere other than under :lookups,
      #   you're on your own!
      # Keep in mind that right each test is re-parsing the output.
      t = {
        FacebookEmailLookup:        "last_successful_response" ,
        FacebookWebsiteLookup:      "last_successful_response" ,
        FoursquarePhoneLookup:      "last_successful_response" ,
        FoursquareFacebookIdLookup: "last_successful_response" ,
        FoursquareEmailLookup:      "last_successful_response" ,
        TwitterWebsiteLookup:       "last_successful_response" ,
        GooglePlusLookup:           "last_successful_response" ,
        GoogleSocialLookup:         "last_successful_response" ,
        TwitterScreenNameLookup:    "last_successful_response" ,
      }

      t.each do |name, test|
        test "#{name} - #{test}" do |r|
          h = JSON.parse(r.body)
          "#{h['lookups']["#{name}"]["#{test}"]}"
        end
      end
    end
  end
end
