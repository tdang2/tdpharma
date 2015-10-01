class Company < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  has_many :stores, dependent: :destroy
  has_many :employees, through: :stores, dependent: :destroy
  has_many :locations, through: :stores, dependent: :destroy
  has_one :registered_location, class_name: Location, as: :locationable, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :destroy

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :name, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################
  accepts_nested_attributes_for :image
  accepts_nested_attributes_for :documents
  accepts_nested_attributes_for :registered_location

  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def photo_thumb
    self.image.photo.url(:thumb) if self.image
  end

  private


end
