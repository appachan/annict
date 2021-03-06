# frozen_string_literal: true

class StatusActivityCardsComponent < ApplicationComponent
  # @param activity_group [ActivityGroupEntity]
  def initialize(activity_group:)
    @activity_group = activity_group
  end

  private

  attr_reader :activity_group

  def statuses
    activity_group.itemables
  end
end
