class Price < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  belongs_to :priceable, polymorphic: true

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :amount, presence: true, numericality: {greater_than: 0}

  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private
end
