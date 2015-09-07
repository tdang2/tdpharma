class Store < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  belongs_to :company
  has_many   :employees, class_name: User
  has_one :location, as: :locationable, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :destroy

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :name, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################
  accepts_nested_attributes_for :location, allow_destroy: :true
  accepts_nested_attributes_for :image, allow_destroy: :true
  accepts_nested_attributes_for :documents, allow_destroy: :true

  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private

end
