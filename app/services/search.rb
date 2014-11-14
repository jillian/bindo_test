require 'rest_client'
require 'nokogiri'

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
              initial_page_request = RestClient.get("http://www.yelp.com/search?l=p%3A#{state}%3A#{city}%3A%3A#{neighborhood}#find_desc&find_loc&cflt=#{category}&l", "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36")

              # find main("\w*") and string parse for unique ID:
              html_page = Nokogiri::HTML(initial_page_request)
              scripts = html_page.css('script').map(&:text)
              parent_request_id = scripts.map do |script|
                script.match(/main\(\"\w*\"\)/).to_s
              end.reject!(&:empty?).first.scan(/\(([^\)]+)\)/).last.first.scan(/\w*/)[1]

              formatted_city_with_state = "#{city.gsub("_", "%20")},%20#{state}"
              url = "http://www.yelp.com/search/snippet?find_desc&find_loc=#{formatted_city_with_state}&start=20&cflt=active&parent_request_id=#{parent_request_id}&request_origin=user"

            ParseBusinessesWorker.perform_async(url, formatted_city_with_state, category)
          end
        end
      end
    end

  end
end