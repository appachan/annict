# frozen_string_literal: true

class UserWorkTagsController < ApplicationController
  def show
    @user = User.only_kept.find_by!(username: params[:username])
    @tag = @user.work_tags.find_by!(name: params[:id])
    @taggable = @user.work_taggables.find_by(work_tag: @tag)
    @works = Work.joins(:work_taggings).merge(WorkTagging.where(user: @user, work_tag: @tag))
  end
end
