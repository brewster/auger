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
        test "#{lookup} - last_successful_response" do |r|
          if r.body.is_a? Hash
            r.body['lookups'][lookup]['last_successful_response']
          else
            false
          end
        end
        test "#{lookup} - rate_limited_requests" do |r|
          if r.body.is_a? Hash
            r.body['lookups'][lookup]['rate_limited_requests']
          else
            false
          end
        end
        test "#{lookup} - input_queue_count" do |r|
          if r.body.is_a? Hash
            r.body['lookups'][lookup]['input_queue_count']
          else
            false
          end
        end
        test "#{lookup} - cache hit rate %" do |r|
          if r.body.is_a? Hash
            hit = r.body['lookups'][lookup]['cache_hits']
            miss = r.body['lookups'][lookup]['cache_misses']
            hitrate = (hit.to_f / (hit.to_f + miss.to_f)) * 100
            Integer(hitrate * 100) / Float(100)
          else
            false
          end
        end
      end
    end
  end
end

