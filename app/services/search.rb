require 'rest_client'
require 'nokogiri'
require "pry"

class Search

  def scrape_businesses
    categories = ['active','arts','auto','beautysvc','education','eventservices','financialservices','food','health','homeservices','nightlife','pets','hotelstravel','localflavor','localservices','massmedia','professional','publicservicesgovt','realestate','religiousorgs','restaurants','shopping']

    #neighborhoods can be captured from nokogiri. path => '#neighborhoods-list > div > ul > li:nth-child(2) > ul:nth-child(1) > li:nth-child(1) > a'
    #'Adams_Normandie','Arleta','Arlington_Heights','Arts_District','Athens','Atwater_Village','Beverly_Hills','Beverley_Crest','Beverly_Grove','Beverly_Hills','Beverlywood','Boyle_Heights','Brentwood', 'Burbank','Canoga_Park','Carthay','Central_Alameda','Century_City','Chatsworth','Chesterfield_Square',
    states = { CA: { "Los_Angeles" => ['Cheviot_Hills' ] } }
    #,'Chinatown','Culver_City','Cypress_Park', 'Downtown', 'Encino', 'Echo_Park', 'Glendale', 'Hollywood', 'Inglewood', 'Koreatown','Little_Tokyo','Los_Feliz', 'Malibu','North_Hills', 'North_Hollywood', 'North_Ridge', 'Pacific_Palisades','Pacoima','Palms','Pasadena', 'Porter_Ranch','Rancho_Park','Redondo_Beach', 'Santa_Monica', 'Sawtelle','Sepulveda_Basin','Shadow_Hills', 'Sherman_Oaks','Silver_Lake','South_Park', 'Tarzana', 'Terminal_Island','Toluca_Lake', 'Torrance','UCLA', 'Universal_City', 'Universal,Park', 'Valley_Glen', 'Van_Nuys', 'Venice','Walnut_Park', 'West Hills', 'West_Hollywood', 'West_Los_Angeles', 'Westchester', 'Westlake','Westmont','Wilmington','Wilshire_Center','Windsor_Square','Winnetka','Woodland_Hills'
 
    #todo: each state/city can be it's own sidekiq worker
    categories.each do |category|
      sleep 15
      states.each do |state, cities|
        sleep 1
        cities.each do |city, neighborhoods|
          sleep 1
          neighborhoods.each do |neighborhood|
            sleep 20
              begin 
                initial_page_request = RestClient.get("http://www.yelp.com/search?cflt=#{category}&l=p%3A#{state}%3A#{city}%3A%3A#{neighborhood}", "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36")
                # find main("\w*") and string parse for unique ID:
                html_page = Nokogiri::HTML(initial_page_request)
                scripts = html_page.css('script').map(&:text) 
                parent_request_id = scripts.map do |script|
                  script.match(/main\(\"\w*\"\)/).to_s
                end.reject!(&:empty?).last.scan(/\(([^\)]+)\)/).last.first.scan(/\w*/)[1]
              rescue => e
                puts "Unable to get parent_request_id: #{e}" 
                sleep 5
              ensure
                sleep 3.0 + rand
              end
          
            formatted_city_with_state = "#{neighborhood.gsub("_", "%20")}%20#{city.gsub("_", "%20")},%20#{state}"
            url = "http://www.yelp.com/search/snippet?find_desc&find_loc=#{formatted_city_with_state}&start=20&cflt=#{category}&parent_request_id=#{parent_request_id}&request_origin=user"

            #   end of parent_request_id/start of parse_biz_worker

            search_results = RestClient.get(url, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36" )

            if !search_results.nil?
              results = JSON.parse(search_results)
              doc = Nokogiri::HTML(results["search_results"])
              next_url = results["seo_pagination"]["relNextUrl"]
              # if !next_url.empty?
              #   ParseBusinessesWorker.perform_async(next_url)
              # end

              doc.css('ul.search-results div.search-result').each do |element|
                name = element.css('.media-story .biz-name').text
                puts "****BUSINESS******"
                puts "name #{name}"

                img_node = element.css('.media-avatar img:first')
                image = img_node.xpath("@*[starts-with(name(), 'src')]").text
                puts "image #{image}"
                data_key = element.xpath("@*[starts-with(name(), 'data-key')]").text.to_i

                full_address_nodeset = element.css('.secondary-attributes address:first')
                if !full_address_nodeset.empty?
                  #full_address_nodeset is a nokogiri nodeset with one node.
                  full_address = full_address_nodeset.first.children
                  street_address = full_address.first.text.strip 
                  puts "#{street_address}"
                  zipcode = full_address.text.split(' ')[-1].to_i
                  if zipcode.is_a?(Integer)
                    zipcode = zipcode
                  end
                  puts "zipcode = #{zipcode}"
                  state = full_address.text.split(' ')[-2]
                  puts "state #{state}"
                
                  city_name = city.gsub("_", " ")
                  puts "city #{city_name}"
                  category = category

                  exists = Business.where(name: name, address: street_address)
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
                  
                    html_page.css('script').map(&:text)
                   
                    map_results = results["search_map"]["markers"]
                    loc = map_results[data_key.to_s] if map_results.has_key?(data_key.to_s)
                    puts "loc #{loc}"
                    if loc.present?
                      business.location = Location.new(loc['location'])
                      business.save
                    end
                  end
                end
              end
            end
            # ParseBusinessesWorker.perform_async(url, formatted_city_with_state, category)
          end
        end
      end
    end
  end
end