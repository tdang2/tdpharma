class Company < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  has_many :stores, dependent: :destroy
  has_many :employees, through: :stores, dependent: :destroy
  has_many :locations, through: :stores, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :name, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################
  accepts_nested_attributes_for :image
  accepts_nested_attributes_for :locations
  accepts_nested_attributes_for :stores

  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private

end
