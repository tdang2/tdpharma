class Role < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  has_and_belongs_to_many :users

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :name, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################

  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private


end
