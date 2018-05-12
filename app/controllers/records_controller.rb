# frozen_string_literal: true

class RecordsController < ApplicationController
  impressionist actions: %i(show)

  before_action :authenticate_user!, only: %i(destroy)

  def show
    load_user
    load_record

    if @record.episode_record?
      @episode_record = @record.episode_record
      @work = @episode_record.work
      @episode = @episode_record.episode
      @comments = @episode_record.comments.order(created_at: :desc)
      @comment = @episode_record.comments.new
      @is_spoiler = user_signed_in? && current_user.hide_episode_record_body?(@episode)
      store_page_params(work: @work)
      render "episode_records/show"
    else
      @work_record = @record.work_record
      @work = @work_record.work
      @is_spoiler = user_signed_in? && current_user.hide_work_record_body?(@work)
      @work_records = @user.
        work_records.
        published.
        where.not(id: @work_record.id).
        includes(work: :work_image).
        order(id: :desc)
      store_page_params(work: @work)
      render "work_records/show"
    end
  end

  def destroy
    load_user
    load_record
    authorize @record, :destroy?

    @record.destroy

    path = if @record.episode_record?
      episode_record = @record.episode_record
      work_episode_path(episode_record.work, episode_record.episode)
    else
      work_record = @record.work_record
      work_records_path(work_record.work)
    end

    redirect_to path, notice: t("messages._common.deleted")
  end

  private

  def load_user
    @user = User.find_by!(username: params[:username])
  end

  def load_record
    @record = @user.records.find(params[:id])
  end

  def redirect_to_user_record(record, provider:)
    username = record.user.username
    utm = {
      utm_source: provider,
      utm_medium: "record_share",
      utm_campaign: username
    }

    redirect_to record_path(username, record, utm)
  end
end
