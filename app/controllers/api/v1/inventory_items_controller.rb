class Api::V1::InventoryItemsController < Api::ApiController
  before_action :doorkeeper_authorize!
  before_action :get_store

  has_scope :by_medicine_name
  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean
  has_scope :by_category

  def index
    unless @store
      render json: {message: 'Current user has no associated store'}, status: 400
    else
      items = apply_scopes(@store.inventory_items).order(:item_name)
      if params[:inventory_id]
        # Return the page that contains the inventory id. Applied scope filter before search.
        # Return empty value if the interested inventory item has already been filtered out
        position = items.map(&:id).index(params[:inventory_id].to_i)
        params[:page] = position.nil? ? ((items.count.to_f/25).ceil + 2) : (((position+1).to_f/25).ceil)
      end
      res = {
          items: items.page(params[:page]).as_json(include: [:itemable, :sale_price, :category, :available_batches], methods: :photo_thumb),
          total_count: items.count,
          page: params[:page]
      }
      render json: res, status: 200
    end
  end

  def show
    render json: {message: 'Current user has no associated store'}, status: 400 unless @store
    item = @store.inventory_items.includes(:itemable, :sale_price, :med_batches).find(params[:id])
    render_item(item)
  end

  def update
    render json: {message: 'Current user has no associated store'}, status: 400 unless @store
    item = @store.inventory_items.find(params[:id])
    item.update!(inventory_item_params)
    render_item(item)
  end

  private
  def render_item(item)
    render json: item.as_json(include: [:itemable,
                                        :sale_price,
                                        :available_batches],
                              methods: [:photo_thumb,
                                        :photo_medium]), status: 200
  end

  def inventory_item_params
    params.require(:inventory_item).permit(:amount, :status,
                                           image_attributes: [:id, :photo],
                                           med_batch_attributes: [:id, :mfg_date, :expire_date, :package, :mfg_location,
                                                                  :store_id, :amount_per_pkg, :number_pkg, :total_units,
                                                                  :total_price, :user_id, :category_id],
                                           sale_price_attributes: [:id, :amount, :discount])
  end

  def get_store
    @store = current_resource_owner.store if current_resource_owner
  end


end