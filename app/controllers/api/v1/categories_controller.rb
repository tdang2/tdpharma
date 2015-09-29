class Api::V1::CategoriesController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store

  def index
    begin
      if @store
        render json: prepare_json(Category.get_store_categories(@store.id).as_json), status: 200
      else
        render json: prepare_json({message: 'Current user has no associated store'}), status: 400
      end
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def create
    begin
      if @store
        @store.categories.create!(category_params)
        render json: prepare_json(Category.get_store_categories(@store.id).as_json), status: 200
      else
        render json: prepare_json({message: 'Current user has no associated store'}), status: 400
      end
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def show
    begin
      if @store
        render json: prepare_json(Category.find(params[:id]).get_info(@store.id)), status: 200
      else
        render json: prepare_json({message: 'Current user has no associated store'}), status: 400
      end
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def update
    begin
      if @store
        @store.categories.find(params[:id]).update!(category_params)
        render json: prepare_json(Category.get_store_categories(@store.id).as_json), status: 200
      else
        render json: prepare_json({message: 'Current user has no associated store'}), status: 400
      end
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def destroy
    begin
      if @store
        @store.categories.find(params[:id]).destroy!
        render json: prepare_json(Category.get_store_categories(@store.id).as_json), status: 200
      else
        render json: prepare_json({message: 'Current user has no associated store'}), status: 400
      end
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  private
  def get_store
    @store = current_user.store if current_user
  end

  def category_params
    params.require(:category).permit(:name, :parent_id, image_attributes: [:id, :photo])
  end


end