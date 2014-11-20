class BusinessesController < ApplicationController
  before_action :set_business, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json
  def index
    # @businesses = Business.where(available: true)

    @businesses = Business.all.includes(:location, :category)
    respond_with @businesses
  end
  
  def get_markers  
    businesses = Business.all.includes(:location, :category)
    geojson = {
          "type" => "FeatureCollection",
          "features" => []
        }
    businesses.each do |business|   
      if business.location.present?
        x = business.location.latitude 
        y = business.location.longitude
        puts "lat long = #{x}, #{y}"

        geojson["features"] << {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [x, y]
          },
          properties: {
            name: business.name,
            address: business.address,
            category: business.category.name,
            image: business.image,
            :'marker-color' => '#00607d',
            :'marker-symbol' => 'circle',
            :'marker-size' => 'medium'
          }
        }
      else
        puts "no lat/long"
      end
    end
    puts "#{geojson.class}"
    puts "#{geojson.inspect}"


    render json: geojson

  end

  def filter
    @businesses = Business.all
    @businesses.by_category(params[:category]) if params.has_key?(:category)
    @businesses.by_location(params[:location]) if params.has_key?(:location)
  end



  # GET /businesses/1
  # GET /businesses/1.json
  def show
  end

  # DELETE /businesses/1
  # DELETE /businesses/1.json
  def destroy
    @business.destroy
    respond_to do |format|
      format.html { redirect_to businesses_url, notice: 'Business was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_business
      @business = Business.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def business_params
      params.require(:business).permit(:name, :image, :zipcode, :address,
        category_attributes: [:name],  
        location_attributes:[:latitude, :longitude])
    end
end
