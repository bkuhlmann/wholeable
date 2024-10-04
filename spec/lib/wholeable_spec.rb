# frozen_string_literal: true

require "spec_helper"

RSpec.describe Wholeable do
  subject(:whole) { implementation.new }

  let :implementation do
    Class.new do
      include Wholeable[:name, :label]

      def initialize name: "test", label: "Test"
        @name = name
        @label = label
      end
    end
  end

  it_behaves_like "a whole value object"
end
