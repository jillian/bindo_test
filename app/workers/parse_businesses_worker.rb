class ParseBusinessesWorker

  def perform(url)
    begin
      search_results = RestClient.get(url, user_agent: "")

      if !search_results.nil?
        results = JSON.parse(search_results)

        html_results = Nokogiri::HTML(results["search_results"])
        next_url = results["seo_pagination"]["relNextUrl"]
        if !next_url.empty?
          ParseBusinessesWorker.new.perform(next_url) 
        end

        results = []
        html_results.css('ul.search-results div.search-result').each do |element|
          result = {} # Business.new
          name = element.css('.media-story .biz-name').text
          result[:name] = name 

          data_key = result.xpath("@*[starts-with(name(), 'data-key')]")
          result[:data_key] = data_key

          address = element.css('.secondary-attributes address:first').text
          result[:address] = address

          img = element.css('.media-avatar img:first')
          if !img.nil?
            result[:img] = img.attr('src')
          end


          # if i do subcategories:
          # subcategories = [] # in rails, "business has_many: :categories" ...make a category model 
          # element.css('.media-story .price-category .category-str-list a').each do |category|
          #   categories << category.text
          # end

          zipcode = address.split(' ')[-1]
            if zipcode.is_a?(Integer)
              # safe to save as zip code
              result[:zipcode] = zipcode
            end
          end

          data_key = element.css('.search-result natural-search-result biz-listing-large')
          puts data_key
        # additional_data = search_results.search_map.markers -> parse using "data-key" values 
        # can choose to save individually or as a group

        puts "businesses #{results}"
        # Business.create(results)

      end
    rescue RestClient::ResourceNotFound => ex
      puts ex
    rescue Exception => e
      puts e
    end
  end

end