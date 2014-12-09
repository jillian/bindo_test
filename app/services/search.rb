require 'rest_client'
require 'nokogiri'
require "pry"
require 'json'

# split into distinct jobs - scrape cities, 
# 

class Search

  def scrape_businesses
    categories = ['active']
      #,'arts','auto','beautysvc','education','eventservices','financialservices','food','health','homeservices','nightlife','pets','hotelstravel','localflavor','localservices','massmedia','professional','publicservicesgovt','realestate','religiousorgs','restaurants','shopping']

    #neighborhoods can be captured from nokogiri. path => '#neighborhoods-list > div > ul > li:nth-child(2) > ul:nth-child(1) > li:nth-child(1) > a'
    #
    states = { CA: { "Los_Angeles" => ['Adams_Normandie']}}
      #,'Arleta','Arlington_Heights','Arts_District','Athens','Atwater_Village','Beverly_Hills','Beverley_Crest','Beverly_Grove','Beverly_Hills','Beverlywood','Boyle_Heights','Brentwood', 'Burbank','Canoga_Park','Carthay','Central_Alameda','Century_City','Chatsworth','Chesterfield_Square','Cheviot_Hills','Chinatown','Culver_City','Cypress_Park', 'Downtown', 'Encino', 'Echo_Park', 'Glendale', 'Hollywood', 'Inglewood', 'Koreatown','Little_Tokyo','Los_Feliz', 'Malibu','North_Hills', 'North_Hollywood', 'North_Ridge', 'Pacific_Palisades','Pacoima','Palms','Pasadena', 'Porter_Ranch','Rancho_Park','Redondo_Beach', 'Santa_Monica', 'Sawtelle','Sepulveda_Basin','Shadow_Hills', 'Sherman_Oaks','Silver_Lake','South_Park', 'Tarzana', 'Terminal_Island','Toluca_Lake', 'Torrance','UCLA', 'Universal_City', 'Universal,Park', 'Valley_Glen', 'Van_Nuys', 'Venice','Walnut_Park', 'West Hills', 'West_Hollywood', 'West_Los_Angeles', 'Westchester', 'Westlake','Westmont','Wilmington','Wilshire_Center','Windsor_Square','Winnetka','Woodland_Hills' ] } }
    #
 
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
              puts "#{parent_request_id}"
              rescue => e
                puts "Unable to get parent_request_id: #{e}" 
                sleep 5
              ensure
                sleep 3.0 + rand
              end
          
            formatted_city_with_state = "#{neighborhood.gsub("_", "%20")}%20#{city.gsub("_", "%20")},%20#{state}"
            url = "http://www.yelp.com/search/snippet?find_desc&find_loc=#{formatted_city_with_state}&start=20&cflt=#{category}&parent_request_id=#{parent_request_id}&request_origin=user"
            puts "#{url}"
            
            ParseBusinessesWorker.perform_async(url, formatted_city_with_state, category)
          end
        end
      end
    end
  end
end

test = Search.new
test.scrape_businesses