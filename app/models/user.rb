class User < ActiveRecord::Base
  ### Attributes ###################################################################################
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  has_and_belongs_to_many :roles
  has_many :employees, class_name: User, foreign_key: :manager_id
  belongs_to :manager, class_name: User
  belongs_to :store
  has_many :sales, class_name: Transaction, foreign_key: :sale_user_id
  has_many :purchases, class_name: Transaction, foreign_key: :purchase_user_id

  ### Callbacks ####################################################################################
  before_save :ensure_authentication_token

  ### Validations ##################################################################################
  validates :first_name, :last_name, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################

  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def ensure_authentication_token(force=false)
    if authentication_token.blank? or force == true
      self.authentication_token = generate_authentication_token
      self.save!
    end
  end

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end

  private
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

end
