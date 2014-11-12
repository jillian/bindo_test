class Search

  def locate_businesses
    categories = ['active']
      # ,'arts','auto','beautysvc','education','eventservices','financialservices','food','health','homeservices','hotelstravel','localflavor','localservices','massmedia','nightlife','pets','professional','publicservicesgovt','realestate','religiousorgs','restaurants','shopping']

    states = { CA: { "Los_Angeles" => [ 'Beverly_Hills' ] } }
    #todo: each state/city can be it's own worker (sidekiq)
    categories.each do |category|  
      states.each do |state, cities|
        cities.each do |city, neighborhoods|
          neighborhoods.each do |neighborhood|


            initial_page_request = RestClient.get("http://www.yelp.com/search?l=p%3A#{state}%3A#{city}%3A%3A#{neighborhood}#find_desc&find_loc&cflt=#{category}&l", "User-Agent" => "chrome")
           
            # find main("\w*") and string parse for unique ID:
            html_page = Nokogiri::HTML(initial_page_request)
            scripts = html_page.css('script').map(&:text)
            parent_request_id = scripts.map do |script|
              script.match(/main\(\"\w*\"\)/).to_s 
            end.reject!(&:empty?).first.scan(/\(([^\)]+)\)/).last.first.scan(/\w*/)[1]  
            # above lines match for 'main("text")' pattern in scripts, 
            # gets rid of empty string entries from resulting array, 
            # scans for content within main(), and then selects it
            url = "http://www.yelp.com/search/snippet?find_desc&find_loc&cflt=#{category}&parent_request_id=#{parent_request_id}&request_origin=hash&bookmark=true"


            response = RestClient.get(url, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36")
            cookies = response.cookies
            cookies['location'] = "%7B%22city%22%3A+%22Los+Angeles%22%2C+%22zip%22%3A+%22%22%2C+%22country%22%3A+%22US%22%2C+%22address2%22%3A+%22%22%2C+%22address3%22%3A+%22%22%2C+%22state%22%3A+%22CA%22%2C+%22address1%22%3A+%22%22%2C+%22unformatted%22%3A+%22Los+Angeles%2C+CA%22%7D"

            ParseBusinessesWorker.new.perform(url, cookies)

          end
        end
      end
    end

  end
end