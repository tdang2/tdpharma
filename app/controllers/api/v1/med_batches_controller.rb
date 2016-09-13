class Api::V1::MedBatchesController < Api::ApiController
  before_action :doorkeeper_authorize!
  before_action :get_store

  def index
    batches = @store.med_batches.where(barcode: params[:barcode]) if params[:barcode]
    batches ||= @store.med_batches.available_batches
    render json: batches.as_json(include: [:inventory_item, :category, :medicine]), status: 200
  end

  private
  def get_store
    @store = current_resource_owner.store if current_resource_owner
  end

end