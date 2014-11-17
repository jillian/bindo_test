class BusinessesController < ApplicationController
  before_action :set_business, only: [:show, :edit, :update, :destroy]

  # GET /businesses
  # GET /businesses.json
  def index
    @businesses = Business.all.includes(:location, :category)
   
  end
  def get_markers  
    businesses = Business.all.includes(:location, :category)
    geojson = Array.new
    businesses.each do |business|
      x = business.location.latitude if business.location.present?
      y = business.location.longitude if business.location.present?

      geojson << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [x, y]
        },
        properties: {
          name: business.name,
          address: business.address,
          :category => business.category,
          :'marker-color' => '#00607d',
          :'marker-symbol' => 'circle',
          :'marker-size' => 'medium'
        }
      }
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
end
