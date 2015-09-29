class Api::V1::MedicinesController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store

  def index

  end

  def create

  end

  def show

  end

  def update

  end

  def destroy

  end

  private
  def medicine_params
    params.require(:medicine).permit(:name, :concentration, :concentration_unit, :med_form,
                                     image_attributes: [:id, :photo],
                                     med_batches_attributes: [:id, :mfg_date, :expire_date, :package, :mfg_location,
                                                              :amount_per_pkg, :amount_unit, :total_units, :price, :user_id, :category_id])
  end

  def get_store
    @store = current_user.store if current_user
  end
end