class HomeController < ApplicationController
  before_action :authenticate_user!, except: :index

  def index
    # This method is before sign in
  end

  def show
    # This method is to trigger angular after sign in
  end
end
