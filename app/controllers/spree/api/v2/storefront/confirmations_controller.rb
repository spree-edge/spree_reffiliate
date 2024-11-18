module Spree
  module Api
    module V2
      module Storefront
        class ConfirmationsController < ::Spree::Api::V2::ResourceController
          before_action :load_affiliate
          before_action :load_object, only: [:new, :create]

          def new
            if @affiliate
              render json: { message: Spree.t(:affiliate_found, scope: :affiliate_confirmation) }, status: :ok
            else
              render json: { error: Spree.t(:not_found, scope: :affiliate_confirmation) }, status: :not_found
            end
          end

          def create
            if @user.update(user_params)
              @user.update(can_activate_associated_partner: true)
              render json: { message: Spree.t(:account_updated), user: @user }, status: :ok
            else
              render json: { error: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity
            end
          end

          private

          def load_affiliate
            @affiliate = Spree::Affiliate.find_by(activation_token: params[:activation_token])
            unless @affiliate
              render json: { error: Spree.t(:activation_token_expired) }, status: :gone
            end
          end

          def load_object
            @user = Spree::User.find_by(email: @affiliate&.email)
            unless @user
              render json: { error: Spree.t(:user_not_found) }, status: :not_found
            end
          end

          def user_params
            params.require(:user).permit(:password, :password_confirmation)
          end
        end
      end
    end
  end
end
