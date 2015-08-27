class User < ActiveRecord::Base
  ### Attributes ###################################################################################
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  validates :first_name, :last_name, presence: true

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################

  ### Scopes #######################################################################################

  ### Other ########################################################################################

  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
      self.save!
    end
  end

  private
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

end
