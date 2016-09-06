class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_resource_owner
  before_action :default_url_options
  before_action :set_locale
  before_filter :authenticate_user_from_token!, if: :check_api_authentication? # This is for mobile app api
  before_filter :set_paper_trail_whodunnit

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  #TODO: After set up doorkeeper, update this using current_user method instead
  def user_for_paper_trail
    author = 'Public User'
    author = @current_user.id if @current_user
    author = current_admin_user.id if admin_user_signed_in?
    author
  end

  protected
  def current_resource_owner
    if doorkeeper_token
      # Authorization code grant flow
      @author = User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token.resource_owner_id
      # If not, then request is made through client credentials grant flow
      @author ||= Doorkeeper::Application.find(doorkeeper_token.application_id)
    end
  end

  def check_api_authentication?
    params['controller'].include?('api/v1/')
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :first_name, :last_name, :phone])
  end

  def authenticate_user_from_token!
    if request.headers['Authorization'].nil?
      render json: {errors: 'No user information'}.to_json, status: 401
      return
    end
    info = request.headers['Authorization'].split(':')
    @current_user = User.find_by_email(info[0])
    if @current_user
      # We use Devise.secure_compare to compare the token in the database with the token given in the params, mitigating timing attacks.
      if !Devise.secure_compare(@current_user.authentication_token, info[1])
        sign_out @current_user
        render json: {errors: 'Invalid User Token'}.to_json, status: 401
      else
        # update access token after 24 hour from last log in
        @current_user.ensure_authentication_token(true) if @current_user.updated_at + 24.hours < DateTime.now
        sign_in @current_user
      end
    else
      render json: {errors: 'No user found'}.to_json, status: 401
    end
  end

  def prepare_json(result)
    {
        authentication_token: @current_user.authentication_token,
        data: result
    }
  end

end
