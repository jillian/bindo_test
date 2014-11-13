require 'nokogiri'
require 'json'

class ParseBusinessesWorker
  include Sidekiq::Worker

  def perform(url, cookies)
    begin
      # cookie = "__cfduid=de0464e8fd854240d89d6be6bfbecac5c1415877284; expires=Fri, 13-Nov-15 11:14:44 GMT; path=/; domain=.yelp.com; HttpOnly", "yuv=5WUXTGsWqOrXephicqxXqlSt6AwoPfKIvv74gQ9PJW8uF_N3JwKJ2FaGyEJGZw9izuE-G7XsgqkFYN5wVyYU05NTOBK-rSoh; Domain=.yelp.com; Max-Age=630720000; Path=/; expires=Wed, 08-Nov-2034 11:14:44 GMT", "bse=69ad7d9fcc35ae35f41970ca5e6f5494; Domain=.yelp.com; Path=/; HttpOnly", "hl=en_US; Domain=.yelp.com; Max-Age=630720000; Path=/; expires=Wed, 08-Nov-2034 11:14:44 GMT", "recentlocations=; Domain=.yelp.com; Path=/", "location=%7B%22city%22%3A+%22Los+Angeles%22%2C+%22zip%22%3A+%22%22%2C+%22country%22%3A+%22US%22%2C+%22address2%22%3A+%22%22%2C+%22address3%22%3A+%22%22%2C+%22state%22%3A+%22CA%22%2C+%22address1%22%3A+%22%22%2C+%22unformatted%22%3A+%22Los+Angeles%2C+CA%22%7D; Domain=.yelp.com; Max-Age=630720000; Path=/; expires=Wed, 08-Nov-2034 11:14:44 GMT"
      # puts "cookie - "
      puts "url #{url}" 
      puts ""
      puts ""
      puts "cookies #{cookies}"
      puts ""
      puts ""
      search_results = RestClient.get(url, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36", :set_cookie => cookies)
      puts ""
      puts ""
      puts "cookie value #{headers[:set_cookie]}"
      puts ""
      puts ""
      headers = search_results.headers 
      headers.keys.each do |key|
        puts "#{key}"
      end
      headers.values.each do |value|
        puts "#{value}"
      end
    
      if !search_results.nil?
        results = JSON.parse(search_results)
        doc = Nokogiri::HTML(results["search_results"])
        next_url = results["seo_pagination"]["relNextUrl"]
        # if !next_url.empty?
        #   ParseBusinessesWorker.perform(next_url) 
        # end

        doc.css('ul.search-results div.search-result').each do |element|
          begin
            
            img_node = element.css('.media-avatar img:first')
            image = img_node.xpath("@*[starts-with(name(), 'src')]").text

            name = element.css('.media-story .biz-name').text
            # puts "#{name}"
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
              image: image 
            })
            
          rescue Exception => e
            puts "#{e}"
          end
        end
        

        # Business.create(results)
        # map_results = results["search_map"]["markers"]

        # locations = map_results.each do |loc|
        #   location = loc[1]['location']
        #   puts "#{location}"
        #   l = loc.to_i
        #   puts "#{l}"
        # end

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