require 'json'

project "Megalookup" do
  hosts "prod-lookup-r[01-02]"
  
  https 443 do
    insecure true

    get "/status" do

      ## this runs after request returns, but before tests
      ## use it to munge response body from json string into a hash
      before_tests do |r|
        if r['Content-Type'].respond_to?(:match) and r['Content-Type'].match /application\/json/
          begin 
            r.body = JSON.parse(r.body)
          rescue JSON::ParserError
            puts "error parsing JSON in response body"
          end
        end
      end

      test "Status 200" do |r|
        r.code == '200'
      end

      lookups = %w[
        FacebookEmailLookup
        FacebookWebsiteLookup
        FoursquarePhoneLookup
        FoursquareFacebookIdLookup
        FoursquareEmailLookup
        TwitterWebsiteLookup
        GooglePlusLookup
        GoogleSocialLookup
        TwitterScreenNameLookup
      ]

      lookups.each do |lookup|
        test "#{lookup} last successful response" do |r|
          if r.body.is_a? Hash
            r.body['lookups'][lookup]['last_successful_response']
          else
            false
          end
        end
      end

    end

  end

end

