class Api::V1::UsersController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :set_user, only: [:update, :show, :destroy]
  load_and_authorize_resource

  def index

  end

  def update
    begin
      @user.update!(user_params)
      authorize! :assign_roles, @user if params[:role_ids]
      render json: @user.as_json(include: :roles), status: 200
    rescue StandardError => e
      render json: {errors: e.message}.to_json,  status: 400
    end
  end

  def show
    begin
      render json: @user.as_json(include: :roles), status: 200
    rescue StandardError => e
      render json: {errors: e.message}.to_json, status: 400
    end
  end

  def destroy
    begin
      @user.destroy!
      render json: {message: 'success'}.to_json, status: 200
    rescue StandardError => e
      render json: {errors: e.message}.to_json, status: 400
    end
  end

  private
  def set_user
    @user = current_user
  end

  def assign_roles
    @user.roles << Role.where(id: params[:role_ids])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :password, :email, :phone)
  end

end
