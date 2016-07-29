class Users::SessionsController < Devise::SessionsController
  respond_to :json
  # before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #    super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    resource.update!(last_checked_in: DateTime.now) if resource.class == User
    yield resource if block_given?
    if request.format == 'application/json'
      render json: resource.as_json(include: [:roles]), status: 201
    else
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
    yield if block_given?
    if request.format == 'application/json'
      render json: {message: 'Log out successfully'}.as_json, status: 200
    else
      respond_to_on_destroy
    end
  end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
