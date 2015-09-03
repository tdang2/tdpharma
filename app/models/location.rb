class Location < ActiveRecord::Base
  ### Attributes ###################################################################################
  after_validation :geocode, :if => :address_changed?

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################
  geocoded_by :address

  ### Associations #################################################################################
  belongs_to :locationable, polymorphic: true

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :address, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################

  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private

end