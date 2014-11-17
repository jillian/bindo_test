require 'nokogiri'
require 'json'

class ParseBusinessesWorker
  include Sidekiq::Worker

  def perform(url, city, category)
    begin
      search_results = RestClient.get(url, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36" )

      if !search_results.nil?
        results = JSON.parse(search_results)
        doc = Nokogiri::HTML(results["search_results"])
        next_url = results["seo_pagination"]["relNextUrl"]
        if !next_url.empty?
          ParseBusinessesWorker.perform_async(next_url)
        end

        doc.css('ul.search-results div.search-result').each do |element|
          name = element.css('.media-story .biz-name').text
          img_node = element.css('.media-avatar img:first')
          image = img_node.xpath("@*[starts-with(name(), 'src')]").text
          data_key = element.xpath("@*[starts-with(name(), 'data-key')]").text.to_i
          full_address = element.css('.secondary-attributes address:first').first.children

          street_address = full_address.first.text.strip #address is a nokogiri nodeset with one node.
          zipcode = full_address[2].text.split(' ')[-1].to_i
          if zipcode.to_i.is_a?(Integer)
            zipcode = zipcode
          end
          city_name = city.gsub("%20", " ")
          state = full_address.split(' ')[-2]
          exists = Business.where(name: name, address: address)
          if exists.size <= 0
            business = Business.create({
              name: name,
              address: street_address,
              zipcode: zipcode,
              city: city_name,
              state: state,
              image: image,
              category: Category.new({name: category})
            })
            puts "hellloooooo *********************"

            map_results = results["search_map"]["markers"]
            loc = map_results[data_key.to_s] if map_results.has_key?(data_key.to_s)
            if loc.present?
              business.location = Location.new(loc['location'])
              business.save
            end

          end
        end
      end

    rescue RestClient::ResourceNotFound => ex
      puts "after first rescue #{ex}"
    rescue Exception => e
      puts "after exception #{e}"
    end
  end

end