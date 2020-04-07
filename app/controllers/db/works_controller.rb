# frozen_string_literal: true

module Db
  class WorksController < Db::ApplicationController
    before_action :authenticate_user!, only: %i(new create edit update destroy)

    def index
      @is_no_episodes = search_params[:no_episodes] == "1"
      @is_no_image = search_params[:no_image] == "1"
      @is_no_release_season = search_params[:no_release_season] == "1"
      @is_no_slots = search_params[:no_slots] == "1"
      @season_slugs = search_params[:season_slugs]

      @works = Work.without_deleted.preload(:work_image)
      @works = @works.with_no_episodes if @is_no_episodes
      @works = @works.with_no_image if @is_no_image
      @works = @works.with_no_season if @is_no_release_season
      @works = @works.with_no_slots if @is_no_slots
      @works = @works.by_seasons(@season_slugs) if @season_slugs.present?
      @works = @works.order(id: :desc).page(params[:page]).per(100)
    end

    def new
      @work = Work.new
      authorize_db_resource @work
    end

    def create
      @work = Work.new(work_params)
      @work.user = current_user
      authorize_db_resource @work

      return render(:new) unless @work.valid?

      @work.save_and_create_activity!

      redirect_to db_edit_work_path(@work), notice: t("resources.work.created")
    end

    def edit
      @work = Work.without_deleted.find(params[:id])
      authorize_db_resource @work
    end

    def update
      @work = Work.without_deleted.find(params[:id])
      authorize_db_resource @work

      @work.attributes = work_params
      @work.user = current_user

      return render(:edit) unless @work.valid?

      @work.save_and_create_activity!

      redirect_to db_edit_work_path(@work), notice: t("resources.work.updated")
    end

    def hide
      @work = Work.find(params[:id])
      authorize @work, :hide?

      @work.soft_delete_with_children

      flash[:notice] = t("resources.work.unpublished")
      redirect_back fallback_location: db_works_path
    end

    def destroy
      @work = Work.find(params[:id])
      authorize @work, :destroy?

      @work.destroy

      flash[:notice] = t("resources.work.deleted")
      redirect_back fallback_location: db_works_path
    end

    def activities
      @work = Work.find(params[:id])
      @activities = @work.db_activities.order(id: :desc)
      @comment = @work.db_comments.new
    end

    private

    def search_params
      params.permit(:commit, :no_episodes, :no_image, :no_release_season, :no_slots, season_slugs: [])
    end

    def work_params
      params.require(:work).permit(
        :title, :title_kana, :title_alter, :title_en, :title_alter_en, :media, :official_site_url,
        :official_site_url_en, :wikipedia_url, :wikipedia_url_en, :twitter_username,
        :twitter_hashtag, :sc_tid, :mal_anime_id, :number_format_id, :synopsis,
        :synopsis_source, :synopsis_en, :synopsis_source_en, :season_year, :season_name,
        :manual_episodes_count, :start_episode_raw_number, :no_episodes, :started_on, :ended_on
      )
    end
  end
end
