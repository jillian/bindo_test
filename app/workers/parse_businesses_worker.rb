require 'nokogiri'
require 'json'

class ParseBusinessesWorker
  include Sidekiq::Worker

  def perform(url, cookies, city, category)
    begin
      puts "before rest client"
      search_results = RestClient.get(url, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36", :cookies => cookies)    
      puts "search result cookie value #{search_results.cookies}" 
      puts "cookie class: #{cookies.class}"
      puts "search results headers: #{search_results.headers}"
  
      if !search_results.nil?
        puts "before json"
        results = JSON.parse(search_results)
        doc = Nokogiri::HTML(results["search_results"])
        next_url = results["seo_pagination"]["relNextUrl"]
        # if !next_url.empty?
        #   ParseBusinessesWorker.perform(next_url) 
        # end

        location_keys = []
        doc.css('ul.search-results div.search-result').each do |element|
            
          img_node = element.css('.media-avatar img:first')
          image = img_node.xpath("@*[starts-with(name(), 'src')]").text

          name = element.css('.media-story .biz-name').text
          # puts "#{name}"
          
          data_key = result.xpath("@*[starts-with(name(), 'data-key')]")
            puts "data-key = #{data_key}"



          address = element.css('.secondary-attributes address:first').text
          # puts "#{address}"
          zipcode = 99999999
          # zc = address.text.split(' ')[-1]
          #   if zc.is_a?(Integer)
          #     # safe to save as zip code
          #     zipcode = zc
            # end
          business = Business.create({
            name: name,
            address: address,
            # zipcode: zc,
            image: image,
            category: Category.find_by(name: category)
          })
          location_keys[data_key] = business.id 

          # subcategories = [] # in rails, "business has_many: :categories" ...make a category model 
          # element.css('.media-story .price-category .category-str-list a').each do |category|
          #   categories << category.text
          # end
            
        end
          
          map_results = results["search_map"]["markers"]
          map_results.each do |loc|
            if locations.keys.includes?(loc[0])
              # data_key == loc[0]
              business = Business.find(locations[loc[0]])
              business.location = Location.new(loc[1]['location'])
              #add how to protect against business ids that aren't found
              #.find returns 'record not found' if no id
              business.save
            end
          end

        # category = results["search_adsense"]["query"]
        # puts "#{category}"

      end
    rescue RestClient::ResourceNotFound => ex
      puts "after first rescue"
    rescue Exception => e
      puts "after exception"
    end
  end

end

            # data_key = result.xpath("@*[starts-with(name(), 'data-key')]")
            # data_key: = data_key


# name = element.css('.media-story .biz-name').text
#             result[:name] = name 

#             # data_key = result.xpath("@*[starts-with(name(), 'data-key')]")
#             # data_key: = data_key

#             address = element.css('.secondary-attributes address:first').text
#             result[:address] = address

#             img = element.css('.media-avatar img:first')
#             if !img.nil?
#               result[:img] = img.attr('src')
#             end


#             # if i do subcategories:
#             # subcategories = [] # in rails, "business has_many: :categories" ...make a category model 
#             # element.css('.media-story .price-category .category-str-list a').each do |category|
#             #   categories << category.text
#             # end

#             zipcode = address.split(' ')[-1]
#               if zipcode.is_a?(Integer)
#                 # safe to save as zip code
#                 result[:zipcode] = zipcode
#               end