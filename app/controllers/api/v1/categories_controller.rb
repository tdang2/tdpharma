class Api::V1::CategoriesController < Api::ApiController
  before_action :doorkeeper_authorize!
  before_action :get_store

  def index
    if @store
      render json: Category.get_store_categories(@store.id).as_json, status: 200
    else
      render json: {message: 'Current user has no associated store'}, status: 400
    end
  end

  def create
    if @store
      @store.categories.create!(category_params)
      render json: Category.get_store_categories(@store.id).as_json, status: 200
    else
      render json: {message: 'Current user has no associated store'}, status: 400
    end
  end

  def show
    if @store
      render json: Category.find(params[:id]).get_info(@store.id), status: 200
    else
      render json: {message: 'Current user has no associated store'}, status: 400
    end
  end

  def update
    if @store
      @store.categories.find(params[:id]).update!(category_params)
      render json: Category.get_store_categories(@store.id).as_json, status: 200
    else
      render json: {message: 'Current user has no associated store'}, status: 400
    end
  end

  def destroy
    if @store
      @store.categories.find(params[:id]).destroy!
      render json: Category.get_store_categories(@store.id).as_json, status: 200
    else
      render json: {message: 'Current user has no associated store'}, status: 400
    end
  end

  private
  def get_store
    @store = current_resource_owner.store if current_resource_owner
  end

  def category_params
    params.require(:category).permit(:name, :parent_id, image_attributes: [:id, :photo])
  end


end