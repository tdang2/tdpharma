class Api::ApiController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :current_resource_owner
  before_action :current_client_app
  before_filter :set_paper_trail_whodunnit

  rescue_from StandardError, with: :render_error
  include Devisable

  def render_error(e)
    render json: {errors: e.message}, status: 400
  end

  # Set this up for cancancan with doorkeeper
  def current_ability
    @current_ability = Ability.new(current_resource_owner)
  end

  def user_for_paper_trail
    author = 'Public User'
    author = current_resource_owner.id if current_resource_owner
    author
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :first_name, :last_name, :phone])
  end

  def current_resource_owner
    # Authorization code and password grant flow
    if doorkeeper_token
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token.resource_owner_id
    end
  end

  def current_client_app
    # If not, then request is made through client credentials grant flow
    if doorkeeper_token and doorkeeper_token.resource_owner_id.nil? and doorkeeper_token.application_id
      Doorkeeper::Application.find(doorkeeper_token.application_id)
    end
  end


end