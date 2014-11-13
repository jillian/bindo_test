class SearchController < ApplicationController

  def run
    test = Search.new
    test.locate_businesses
    redirect_to root_url
  end

end