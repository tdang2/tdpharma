class Medicine < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  has_many :inventory_items, as: :itemable, dependent: :destroy
  has_many :med_batches, dependent: :destroy
  has_one :image, as: :imageable

  accepts_nested_attributes_for :med_batches
  accepts_nested_attributes_for :image

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :name, :med_form, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def photo_thumb
    self.image.photo.url(:thumb) if self.image
  end

  private


end
