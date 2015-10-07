class Api::V1::MedicinesController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store

  def index
    begin
      med = Medicine.all
      render json: prepare_json(med.as_json(methods: :photo_thumb)), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def create
    begin
      med = Medicine.find_or_create_by!(medicine_params)
      item = @store.inventory_items.find_by(itemable: med)
      render json: prepare_json(item.as_json(include: [itemable: {methods: :photo_thumb}])), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def show
    begin
      render json: prepare_json(Medicine.find(params[:id]).as_json(methods: :photo_thumb)), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def update
    begin
      med = Medicine.find(params[:id])
      med.update!(medicine_params)
      item = @store.inventory_items.find_by(itemable: med)
      render json: prepare_json(item.as_json(include: [itemable: {methods: :photo_thumb}])), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def destroy
    begin
      Medicine.find(params[:id]).destroy!
      render json: prepare_json({message: 'Medicine successfully deleted'}), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  private
  def medicine_params
    params.require(:medicine).permit(:name, :concentration, :concentration_unit, :med_form,
                                     image_attributes: [:id, :photo],
                                     med_batches_attributes: [:id, :mfg_date, :expire_date, :package, :mfg_location, :store_id,
                                                              :amount_per_pkg, :amount_unit, :total_units, :total_price, :user_id, :category_id])
  end

  def get_store
    @store = current_user.store if current_user
  end
end