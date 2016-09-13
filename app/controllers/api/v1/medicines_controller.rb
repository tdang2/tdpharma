class Api::V1::MedicinesController < Api::ApiController
  before_action :doorkeeper_authorize!
  before_action :get_store

  def index
      # preventing SQL injection with search string
      med = @store.medicines.where('name LIKE ?', "%#{params[:search]}%") if params[:search]
      med ||= @store.medicines.all.limit(100)
      render json: med.as_json(store_id: current_resource_owner.store.id,
                               include: [image: {methods:
                                                     [:photo_thumb,
                                                      :photo_medium]}
                               ],
                               methods: [:photo_thumb]), status: 200
  end

  def create
    params[:medicine][:name] = params[:medicine][:name].titleize
    params[:medicine][:med_batches_attributes].each {|p| p[:store_id] ||= @store.id} if params[:medicine][:med_batches_attributes]
    med = Medicine.find_or_initialize_by(name: params[:medicine][:name],
                                         concentration: params[:medicine][:concentration],
                                         mfg_location: params[:medicine][:mfg_location],
                                         med_form: params[:medicine][:med_form],
                                         concentration_unit: params[:medicine][:concentration_unit],
                                         manufacturer: params[:medicine][:manufacturer]).tap do |m|
      m.update!(medicine_params)
    end
    # Identify the store inventory that represents this medicine
    inven = @store.inventory_items.find_by(itemable: med)
    if params[:image]
      inven.update(image_attributes: {photo: params[:image]})
    elsif params[:direct_upload_url]
      inven.update(image_attributes: {direct_upload_url: params[:direct_upload_url]})
    end
    render json: inven.as_json(include: [:itemable,
                                         :sale_price,
                                         :available_batches,
                                         image: {methods: [:photo_thumb, :photo_medium]}],
                               methods: :photo_thumb), status: 200
  end

  def show
    render json: Medicine.find(params[:id]).as_json(include: [image: {methods: [:photo_thumb, :photo_medium]}]), status: 200
  end

  def update
    med = Medicine.find(params[:id])
    params[:medicine][:med_batches_attributes].each {|p| p[:store_id] ||= @store.id} if params[:medicine][:med_batches_attributes]
    med.update!(medicine_params)
    item = @store.inventory_items.find_by(itemable: med)
    render json: item.as_json(include: [:itemable, :sale_price, :available_batches, image: {methods: [:photo_thumb, :photo_medium]}], methods: :photo_thumb), status: 200
  end

  def destroy
    Medicine.find(params[:id]).destroy!
    render json: {message: 'Medicine successfully deleted'}, status: 200
  end

  private
  def medicine_params
    params.require(:medicine).permit(:name, :concentration, :concentration_unit, :med_form, :mfg_location, :manufacturer,
                                     image_attributes: [:id, :photo],
                                     med_batches_attributes: [:id, :mfg_date, :expire_date, :package, :store_id,
                                                              :amount_per_pkg, :number_pkg, :total_units, :total_price,
                                                              :user_id, :category_id, :paid])
  end


  def get_store
    @store = current_resource_owner.store if current_resource_owner
  end
end