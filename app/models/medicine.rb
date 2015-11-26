class Medicine < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

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
  def photo_thumb
    {id: self.image.id, photo: self.image.photo.url(:thumb), processed: self.image.processed} if self.image
  end

  private
  def set_default_image
    self.create_image!(photo: nil) if self.image.nil?
  end


end
