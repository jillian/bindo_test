# # require 'nokogiri'
# # require 'mechanize'
# # require 'json'
# # require 'open-uri'

# # namespace :yelp do
# #   desc "scraping!"
# #     task scrape: :environment do
# #       require "#{Rails.root}/app/services/search"
# #       require "#{Rails.root}/app/workers/parse_businesses_worker"
# #       system "bundle exec sidekiq -C 'Path To Config File' -P 'Path For PID File' -d -L 'Path To Log File'"
# #       categories = ['active']
# #         # ,'arts','auto','beautysvc','education','eventservices','financialservices','food','health','homeservices','hotelstravel','localflavor','localservices','massmedia','nightlife','pets','professional','publicservicesgovt','realestate','religiousorgs','restaurants','shopping']

# #       states = { CA: { "Los_Angeles" => [ 'Beverly_Hills']}}
# #         # , 'Burbank', 'Culver_City', 'Downtown', 'Encino', 'Glendale', 'Hollywood', 'Koreatown', 'North_Hollywood', 'Pasadena', 'Redondo_Beach', 'Santa_Monica', 'Sherman_Oaks', 'Torrance', 'West_Hollywood', 'West_Los_Angeles' ] } }
# #       #todo: each state/city can be it's own sidekiq worker
# #       categories.each do |category|  
# #         states.each do |state, cities|
# #           cities.each do |city, neighborhoods|
# #             neighborhoods.each do |neighborhood|

# #               initial_page_request = "http://www.yelp.com/search?l=p%3A#{state}%3A#{city}%3A%3A#{neighborhood}#find_desc&find_loc&cflt=#{category}&l", "User-Agent" => "chrome"
# #               html_page = Nokogiri::HTML(open(initial_page_request))

              
# #               # find main("\w*") and string parse for unique ID:
# #               scripts = html_page.css('script').map(&:text)
# #               parent_request_id = scripts.map do |script|
# #                 script.match(/main\(\"\w*\"\)/).to_s 
# #               end.reject!(&:empty?).first.scan(/\(([^\)]+)\)/).last.first.scan(/\w*/)[1]  
# #               # above lines match for 'main("text")' pattern in scripts, 
# #               # gets rid of empty string entries from resulting array, 
# #               # scans for content within main(), and then selects content
# #               puts "parent request id #{parent_request_id}"

# #               agent = Mechanize.new
# #               url = "http://www.yelp.com/search/snippet?find_desc&find_loc&cflt=#{category}&parent_request_id=#{parent_request_id}&request_origin=hash&bookmark=true"
# #               puts "#{url}"
# #               cookie_formatted_city = city.gsub("_", "+")
# #               puts "cookie_formatted_city #{cookie_formatted_city}"
# #               cookie = Mechanize::Cookie.new("domain"=>".yelp.com", "name" => "jill", "Max-Age"=>"630720000", "location"=> "%7B%22city%22%3A+%22#{cookie_formatted_city}%22%2C+%22zip%22%3A+%22%22%2C+%22country%22%3A+%22US%22%2C+%22address2%22%3A+%22%22%2C+%22address3%22%3A+%22%22%2C+%22state%22%3A+%22CA%22%2C+%22address1%22%3A+%22%22%2C+%22unformatted%22%3A+%22#{cookie_formatted_city}%2C+CA%22%7D")
# #               puts "cookie = ==== #{cookie}"
# #               agent.cookie_jar << cookie
# #               puts "cookie jar --- #{agent.cookie_jar}"
# # binding.pry
# #               response = agent.get(url, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36")
            

# #               # ParseBusinessesWorker.perform_async(url, cookies, cookie_formatted_city, category)

# #       search_results = agent.get(url, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36", :cookies => cookies)    
# #       # puts "search result cookie value #{search_results.cookies}" 
# #       # puts "cookie class: #{cookies.class}"
# #       # puts "search results headers: #{search_results.headers}"
  
# #       if !search_results.nil?
# #         results = JSON.parse(search_results)
# #         doc = Nokogiri::HTML(results["search_results"])
# #         next_url = results["seo_pagination"]["relNextUrl"]
# #         puts "next url: #{next_url}"
# #         # if !next_url.empty?
# #         #   ParseBusinessesWorker.perform(next_url) 
# #         # end

# #         location_keys = []
# #         # puts "location keys: #{location_keys}"
# #         doc.css('ul.search-results div.search-result').each do |element|
          
# #           name = element.css('.media-story .biz-name').text
# #           # puts "name: #{name}"

# #           img_node = element.css('.media-avatar img:first')
# #           image = img_node.xpath("@*[starts-with(name(), 'src')]").text

# #           data_key = element.xpath("@*[starts-with(name(), 'data-key')]").text.to_i

# #           address = element.css('.secondary-attributes address:first').children.first.text.strip

# #           zipcode = address.split(' ')[-1].to_i

# #           #   if zc.to_i.is_a?(Integer)
# #           #     # safe to save as zip code
# #           #     zipcode = zc
# #           city_name = city.gsub("_", " ")
# #           state = address.split(' ')[-2]
# #           business = Business.create({
# #             name: name,
# #             address: address,
# #             zipcode: zipcode,
# #             city: city_name,
# #             state: state,
# #             image: image,
# #             category: Category.find_by(name: category)
# #           })

#           puts "#{business.inspect}"
#           location_keys[data_key] = business.id 
#           puts "after business.create"

#           # subcategories = [] # in rails, "business has_many: :categories" ...make a category model 
#           # element.css('.media-story .price-category .category-str-list a').each do |category|
#           #   categories << category.text
#           # end        
          
#           map_results = results["search_map"]["markers"]
#           map_results.each do |key, loc|
#             puts "Each Map: #{loc}"
#             if key.to_i == data_key.to_i
#               business.location = Location.new(loc['location'])
#               business.save
#             end
#           end
#           puts "#{business.inspect}"
#         end
#       end

 
#             end
#           end
#         end
#       end

#     end
#   end
