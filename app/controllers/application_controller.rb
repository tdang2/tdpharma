class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:email, :password, :first_name, :last_name, :phone )}
  end


  def authenticate_user_from_token!
    if params[:email]
      @current_user = User.find_by_email(params[:email])
      if @current_user
        # We use Devise.secure_compare to compare the token in the database with the token given in the params, mitigating timing attacks.
        if params[:token].nil? or !Devise.secure_compare(@current_user.authentication_token, params[:token])
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
    else
      render json: {errors: 'No user information'}.to_json, status: 401
    end
  end

  def prepare_json(result)
    {
        authentication_token: @current_user.authentication_token,
        data: result
    }
  end

end
