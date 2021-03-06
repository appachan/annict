# frozen_string_literal: true

class PageInfoEntity < ApplicationEntity
  attribute? :end_cursor, Types::String.optional
  attribute? :has_next_page, Types::Bool
end
