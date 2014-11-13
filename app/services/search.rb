class Search

  def locate_businesses
    categories = ['active']
      # ,'arts','auto','beautysvc','education','eventservices','financialservices','food','health','homeservices','hotelstravel','localflavor','localservices','massmedia','nightlife','pets','professional','publicservicesgovt','realestate','religiousorgs','restaurants','shopping']

    states = { CA: { "Los_Angeles" => [ 'Beverly_Hills']}}
      # , 'Burbank', 'Culver_City', 'Downtown', 'Encino', 'Glendale', 'Hollywood', 'Koreatown', 'North_Hollywood', 'Pasadena', 'Redondo_Beach', 'Santa_Monica', 'Sherman_Oaks', 'Torrance', 'West_Hollywood', 'West_Los_Angeles' ] } }
    #todo: each state/city can be it's own sidekiq worker
    categories.each do |category|  
      states.each do |state, cities|
        cities.each do |city, neighborhoods|
          neighborhoods.each do |neighborhood|
            a = "http://www.yelp.com/search?l=p%3A#{state}%3A#{city}%3A%3A#{neighborhood}#find_desc&find_loc&cflt=#{category}&l"
            puts " ***********************
            *********************
            #{a}
            *********************
            *********************"

            initial_page_request = RestClient.get("http://www.yelp.com/search?l=p%3A#{state}%3A#{city}%3A%3A#{neighborhood}#find_desc&find_loc&cflt=#{category}&l", "User-Agent" => "chrome")
            puts "#{initial_page_request}"
            # find main("\w*") and string parse for unique ID:
            html_page = Nokogiri::HTML(initial_page_request)
            scripts = html_page.css('script').map(&:text)
            parent_request_id = scripts.map do |script|
              script.match(/main\(\"\w*\"\)/).to_s 
            end.reject!(&:empty?).first.scan(/\(([^\)]+)\)/).last.first.scan(/\w*/)[1]  
            # above lines match for 'main("text")' pattern in scripts, 
            # gets rid of empty string entries from resulting array, 
            # scans for content within main(), and then selects content
            puts "#{parent_request_id}"

            url = "http://www.yelp.com/search/snippet?find_desc&find_loc&cflt=#{category}&parent_request_id=#{parent_request_id}&request_origin=hash&bookmark=true"
            puts "#{url}"
            response = RestClient.get(url, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36")
            cookies = response.cookies
            puts "cookies from search #{cookies}"
            headers = response.headers
            cookies = '["__cfduid=d0305076ee1a1331a4ab0746e5c0f5c9e1415878918; expires=Fri, 13-Nov-15 11:41:58 GMT; path=/; domain=.yelp.com; HttpOnly", "yuv=gVCPMO_U6kzMfxX6NPgAQREJ5YVLDajM9FlmVOFcFq7S6AwQAPApaXSwwGuVHCRLYP2G2DBfE1UjqtR_bbNpe0cHn-jOulXA; Domain=.yelp.com; Max-Age=630720000; Path=/; expires=Wed, 08-Nov-2034 11:41:58 GMT", "bse=0d3ea41033599f676374a0a897ef2da6; Domain=.yelp.com; Path=/; HttpOnly", "hl=en_US; Domain=.yelp.com; Max-Age=630720000; Path=/; expires=Wed, 08-Nov-2034 11:41:58 GMT", "recentlocations=; Domain=.yelp.com; Path=/", "location=%7B%22city%22%3A+%22Los+Angeles%22%2C+%22zip%22%3A+%22%22%2C+%22country%22%3A+%22US%22%2C+%22address2%22%3A+%22%22%2C+%22address3%22%3A+%22%22%2C+%22state%22%3A+%22CA%22%2C+%22address1%22%3A+%22%22%2C+%22unformatted%22%3A+%22Los+Angeles%2C+CA%22%7D; Domain=.yelp.com; Max-Age=630720000; Path=/; expires=Wed, 08-Nov-2034 11:41:58 GMT"]'
            

            # def format_city_for_cookie
            # end

            ParseBusinessesWorker.perform_async(url, cookies)
          end
        end
      end
    end

  end
end