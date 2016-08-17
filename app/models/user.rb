class User < ActiveRecord::Base
  ### Attributes ###################################################################################
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # This enum has to match with the client dictionary files such as config_angular_translate_en.js
  enum preferred_language: [:en, :vn]


  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################
  has_paper_trail

  ### Associations #################################################################################
  has_and_belongs_to_many :roles
  has_many :employees, class_name: User, foreign_key: :manager_id
  belongs_to :manager, class_name: User
  belongs_to :store
  has_many :purchase_transactions
  has_many :sale_transactions
  has_many :adjustment_transactions
  has_one :profile_image, class_name: Image, as: :imageable, dependent: :destroy

  ### Callbacks ####################################################################################
  before_save :ensure_authentication_token
  after_create :assign_employee_role
  after_create :set_default_image

  ### Validations ##################################################################################
  validates :first_name, :last_name, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################

  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def ensure_authentication_token(force=false)
    if authentication_token.blank? or force == true
      self.authentication_token = generate_authentication_token
      self.save! if force
    end
  end

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end

  def photo_thumb
    {id: profile_image.id, photo: profile_image.photo_thumb, processed: profile_image.processed} if profile_image
  end

  def photo_medium
    {id: profile_image.id, photo: profile_image.photo_medium, processed: profile_image.processed} if profile_image
  end

  private
  def assign_employee_role
    role = Role.find_by(name: 'employee')
    if role and self.roles.count == 0 and !self.roles.include?(role)
      self.roles << role
    end
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  def set_default_image
    if profile_image.nil?
      self.create_profile_image(photo: nil)
    end
  end

end
