class BusinessesController < ApplicationController
  before_action :set_business, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json
  def index
    # @businesses = Business.where(available: true)

    @businesses = Business.all.includes(:location, :category).page(params[:page])
    respond_with @businesses
  end

  def get_markers
    businesses = Business.includes(:location, :category).all
    Rails.logger.error("Business: #{businesses}")
    geojson = {
          "type" => "FeatureCollection",
          "features" => []
        }
    if businesses.size > 0
      businesses.each do |business|
        if business.location.present?
          geojson["features"] << {
            type: 'Feature',
            properties: {
              title: business.name,
              address: business.address,
              category: business.category.name,
              image: business.image,
              :'marker-color' => map_color_by_category(business.category.name), # '#00607d',
              :'marker-symbol' => 'circle',
              :'marker-size' => 'medium'
            },
            geometry: {
              type: 'Point',
              coordinates: [business.location.longitude, business.location.latitude]
            }
          }
        else
          Rails.logger.error("no lat/long")
        end
      end
    else
      Rails.logger.error("Size is 0")
    end

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

    def map_color_by_category category
      color = '#000000'
      case category
      when 'active'
        color ='#FF0000'
      when 'arts'
        color = '#E80C7A'
      end
      color
    end
end
