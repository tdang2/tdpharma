class Api::V1::MedBatchesController < ApplicationController
  before_filter :authenticate_user!             # standard devise web app
  before_action :get_store
  rescue_from StandardError, with: :render_error

  def render_error(e)
    NewRelic::Agent.notice_error(e) if Rails.env.production?
    render json: prepare_json({errors: e.message}), status: 400
  end

  def index
    batches = @store.med_batches.where(barcode: params[:barcode]) if params[:barcode]
    batches ||= @store.med_batches.available_batches
    render json: prepare_json(batches.as_json(include: [:inventory_item, :category, :medicine])), status: 200
  end

  private
  def get_store
    @store = @current_user.store if @current_user
  end

end