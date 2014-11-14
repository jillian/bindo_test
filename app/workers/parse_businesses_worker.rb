require 'nokogiri'
require 'json'

RestClient.log =
  Object.new.tap do |proxy|
    def proxy.<<(message)
      Rails.logger.info message
    end
  end


class ParseBusinessesWorker
  include Sidekiq::Worker

  def perform(url, cookies, city, category)
    begin
      puts "before rest client"
      search_results = RestClient.get(url, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36", :cookies => cookies)    
      # puts "search result cookie value #{search_results.cookies}" 
      # puts "cookie class: #{cookies.class}"
      # puts "search results headers: #{search_results.headers}"
  
      if !search_results.nil?
        results = JSON.parse(search_results)
        doc = Nokogiri::HTML(results["search_results"])
        next_url = results["seo_pagination"]["relNextUrl"]
        puts "next url: #{next_url}"
        # if !next_url.empty?
        #   ParseBusinessesWorker.perform(next_url) 
        # end

        location_keys = []
        # puts "location keys: #{location_keys}"
        doc.css('ul.search-results div.search-result').each do |element|
          
          name = element.css('.media-story .biz-name').text
          # puts "name: #{name}"

          img_node = element.css('.media-avatar img:first')
          image = img_node.xpath("@*[starts-with(name(), 'src')]").text

          puts "image: #{image}"

          data_key = element.xpath("@*[starts-with(name(), 'data-key')]")
          # puts "data-key = #{data_key}"

          address = element.css('.secondary-attributes address:first').text
          # puts "address: #{address}"
          zipcode = 99999999

          # puts "#{zipcode}"
          zc = address.split(' ')[-1].to_i
          puts "zip = #{zc}"
          puts "zip class = #{zc.class}"
          #   if zc.to_i.is_a?(Integer)
          #     # safe to save as zip code
          #     zipcode = zc
          puts "hellooooo"
          puts "hello???"
          Rails.logger.info "before business.create"
  
          # puts "{name: #{name},
          #   data-key = #{data_key},
          #   address: #{address}}"
          # puts "DSADADA"
          # binding.pry

          Rails.logger.info "before business.create"
          puts "??????????"
          business = Business.create({
            name: name,
            address: address,
            zipcode: zc,
            image: image,
            category: Category.find_by(name: category)
          })
          location_keys[data_key] = business.id 
          Rails.logger.info "after business.create"

          # subcategories = [] # in rails, "business has_many: :categories" ...make a category model 
          # element.css('.media-story .price-category .category-str-list a').each do |category|
          #   categories << category.text
          # end
            
        end
          
        map_results = results["search_map"]["markers"]
        puts "******lat/long*******"
        puts "map results class = #{map_results.class}"
        puts "map results - #{map_results}"
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
      end


    rescue RestClient::ResourceNotFound => ex
      puts "after first rescue"
    rescue Exception => e
      puts "after exception"
    end
  end

end