# frozen_string_literal: true
module Conf

  class UsersController < ApplicationController

    before_action :authenticate_user!
    before_action :set_user, only: %i[edit update destroy]
    load_and_authorize_resource class: 'User', except: [:create]

    def index
      @users = current_user.merchant.users.not_admins.order(:deleted, :first_name)
    end

    def new
      @user = User.new
    end

    def edit; end

    def create
      @user = User.new(user_params)
      @user.merchant_id = current_user.merchant_id
      respond_to do |format|
        if @user.save
          format.html{ redirect_to conf_users_path, notice: 'Usuario creado con éxito.' }
          format.json{ render action: 'show', status: :created, location: @user }
        else
          format.html{ render action: 'new' }
          format.json{ render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      params[:user] = { deleted: false } if params[:recover].present?
      params[:user].delete(:password) if params[:user][:password].blank?
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password_confirmation)
      end
      method = params[:user][:password].present? ? :update : :update_without_password
      respond_to do |format|
        if @user.send(method, user_params)
          format.html do
            path = current_user.can?('users/manage_all') ? conf_users_path : after_sign_in_path_for
            redirect_to path, notice: 'User actualizado con éxito.'
          end
          format.json{ head :no_content }
        else
          format.html{ render action: 'edit' }
          format.json{ render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @user.soft_delete
      redirect_to conf_users_path, notice: 'User eliminado con éxito.'
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :email,
        :first_name,
        :last_name,
        :phone,
        :password,
        :password_confirmation,
        :active,
        permission_keys: []
      )
    end

  end

end
