class BusinessesController < ApplicationController
  before_action :set_business, only: [:show, :edit, :update, :destroy]

  # GET /businesses
  # GET /businesses.json
  def index
    @businesses = Business.all.includes(:location, :category)

    # @json = Array.new

    # @businesses.each do |business|
    #   @json << business.to_json
    # end

    # render :json => @businesses, :include => [:category, :location]
    
    respond_to do |format|
      format.html
      format.json { render json: @businesses, :include => 
        [
        :location =>{:only => [:latitude, :longitude]}, 
        :category =>{:only => [:name]}  
        ]
      }
    end
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
      params.require(:business).permit(:name, :image, :category, :latitude, :longitude, :zipcode, :address, :city, :data_key_id, :integer)
    end
end
