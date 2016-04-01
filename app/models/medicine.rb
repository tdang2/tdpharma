class Medicine < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################
  has_paper_trail

  ### Associations #################################################################################
  has_many :inventory_items, as: :itemable, dependent: :destroy
  has_many :med_batches, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy

  accepts_nested_attributes_for :med_batches
  accepts_nested_attributes_for :image

  ### Callbacks ####################################################################################
  after_create :set_default_image

  ### Validations ##################################################################################
  validates :name, :med_form, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def as_json(options = {})
    json = super(options)
    json['store_thumb'] = store_thumb(options[:store_id]) if options[:store_id]
    json
  end

  def photo_thumb
    {id: self.image.id, photo: self.image.photo.url(:thumb), processed: self.image.processed} if self.image
  end

  def store_thumb(store_id)
    item = Store.find(store_id).inventory_items.find_by(itemable_type: 'Medicine', itemable_id: self.id)
    item.photo_thumb if item
  end

  private
  def set_default_image
    self.create_image!(photo: nil) if self.image.nil?
  end


end
