class Medicine < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################


  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :name, :concentration, :concentration_unit, :med_form, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private
end
