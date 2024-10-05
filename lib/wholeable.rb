# frozen_string_literal: true

require "wholeable/builder"

# Main namespace.
module Wholeable
  def self.[](*, **) = Builder.new(*, **)
end
