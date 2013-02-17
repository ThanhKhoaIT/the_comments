module TheCommentsController
  COMMENTS_COOKIES_TOKEN = 'JustTheCommentsCookies'

  # View token for Commentable controller
  #
  # class PagesController < ApplicationController
  #   include TheCommentsController::ViewToken
  # end
  module ViewToken
    extend ActiveSupport::Concern

    included do
      def comments_view_token
        cookies[:comments_view_token] = { :value => SecureRandom.hex, :expires => 7.days.from_now } unless cookies[:comments_view_token]
        cookies[:comments_view_token]
      end
    end
  end

  # Cookies for spam protection
  #
  # class ApplicationController < ActionController::Base
  #   include TheCommentsController::Cookies
  # end
  module Cookies
    extend ActiveSupport::Concern

    included do
      before_action :set_the_comments_cookies

      private

      def set_the_comments_cookies
        cookies[:the_comment_cookies] = { :value => TheCommentsController::COMMENTS_COOKIES_TOKEN, :expires => 1.year.from_now }
      end
    end
  end

  # Base functionality of Comments Controller
  #
  # class CommentsController < ApplicationController
  #   include TheCommentsController::Base
  # end
  module Base
    extend ActiveSupport::Concern

    included do
      include TheCommentsController::ViewToken

      skip_before_action :set_the_comments_cookies, only: [:create]

      # Protection
      before_action :ajax_requests_required, only: [:create]
      before_action :cookies_required,       only: [:create]
      before_action :empty_trap_required,    only: [:create]

      # preparation
      before_action :define_commentable, only: [:create]

      def create
        @comment = @commentable.comments.new comment_params
        if @comment.valid?
          @comment.save
          return render(layout: false, template: 'comments/comment')
        end
        render json: { errors: @comment.errors }
      end

      private

      def denormalized_fields
        title = @commentable.commentable_title
        url   = @commentable.commentable_path
        @commentable ? { commentable_title: title, commentable_url: url } : {}
      end

      def define_commentable
        commentable_klass = params[:comment][:commentable_type].constantize
        commentable_id    = params[:comment][:commentable_id]

        @commentable = commentable_klass.where(id: commentable_id).first
        return render(json: { errors: { commentable: [:undefined] } }) unless @commentable
      end

      def comment_params
        params
          .require(:comment)
          .permit(:title, :contacts, :raw_content, :parent_id)
          .merge(user: current_user, view_token: comments_view_token)
          .merge(denormalized_fields)
      end

      # Protection tricks
      def cookies_required
        unless cookies[:the_comment_cookies] == TheCommentsController::COMMENTS_COOKIES_TOKEN
          errors = {}
          errors[t('the_comments.cookies')] = [t('the_comments.cookies_required')]
          return render(json: { errors: errors })
        end
      end
      

      def ajax_requests_required
        unless request.xhr?
          # Log IP address and user Agent
          return render(text: t('the_comments.ajax_requests_required'))
        end
      end

      def empty_trap_required
        spam_bot = true unless params[:email].blank? && params[:comment][:email].blank?
        if spam_bot
          # Log IP address and user Agent
          errors = {}
          errors[t('the_comments.trap')] = [t('the_comments.trap_message')]
          return render(json: { errors: errors })
        end
      end
    end
  end
end