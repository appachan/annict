# frozen_string_literal: true

class SeriesEntity < ApplicationEntity
  local_attributes :name

  attribute? :name, Types::String
  attribute? :name_en, Types::String.optional
  attribute? :series_works, Types::Array.of(SeriesWorkEntity)
end
