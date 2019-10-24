class HomeController < ApplicationController
  def index
    @labels = Overweight::Report.new.generate
  end
end
