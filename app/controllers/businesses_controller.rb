class BusinessesController < ApplicationController
  before_action :set_business, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json

  def index
    @businesses = Business.all.includes(:location, :category).page(params[:page])
    # respond_with @businesses
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
              image: get_biz_img(business.image),
              zipcode: business.zipcode,
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
    @businesses.by_zipcode(params[:zipcode]) if params.has_key?(:zipcode)
  end

  # def by_zipcode
  #   @bev_hills = Business.where("zipcode = '90210'")
  #   # SELECT * from businesses where zipcode = '90210';)
  # end

  def by_zipcode(zipcode)
    where("zipcode = ?", zipcode)
    geojson_2 = {
          "type" => "FeatureCollection",
          "features" => []
        }
    if businesses.size > 0
      businesses.each do |business|
        if business.location.present?
          geojson_2["features"] << {
              type: 'Feature',
              properties: {
                title: business.name,
                address: business.address,
                category: business.category.name,
                image: business.image,
                zipcode: business.zipcode,
                :'marker-color' => map_color_by_category(business.category.name),
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
    render json: geojson_2
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
      case category
      when 'active'
        color ='#FF0000'
      when 'arts'
        color = '#E80C7A'
      when 'auto'
        color = '#6A7287'
      when 'beautysvc'
        color = '#0A8CFF'
      when 'education'
        color = '#16FFF1'
      when 'financialservices'
        color= '#09E89B'
      when 'food'
        color='#0AFF65'
      when 'health'
        color='#FF0A80'
      when 'homeservices'
        color= '#B609E8'
      when 'hotelstravel'
        color ='#7A38E8'
      when 'localflavor'
        color ='#FFF50E'
      when 'localservices'
        color = '#D3D3D3'
      when 'massmedia'
        color='#20E840'
      when 'nightlife'
        color ='#000'
      when 'pets'
        color ='#02FF2C'
      when 'professional'
        color ='#C607FF'
      when 'publicservicesgovt'
        color ='#FFA500'
      when 'realestate'
        color ='#FFF50E'
      when 'religiousorgs'
        color ='#0C72FF'
      when 'restaurants'
        color ='#5C4033'
      when 'shopping'
        color ='#42E8B4'

      end
      color
    end


 def get_biz_img(img_url)  
    img_urls = img_url.split('//')
    "http://#{img_urls[1]}"
  end
end