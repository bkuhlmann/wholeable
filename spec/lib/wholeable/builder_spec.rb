# frozen_string_literal: true

require "spec_helper"

RSpec.describe Wholeable::Builder do
  subject(:whole) { implementation.new }

  let :implementation do
    Class.new do
      include Wholeable::Builder.new(:name, :label)

      def initialize name: "test", label: "Test"
        @name = name
        @label = label
      end
    end
  end

  describe "#included" do
    context "with duplicate inheritance" do
      let :child do
        Class.new(implementation) { include Wholeable::Builder.new(:name, :label) }
      end

      let(:proof) { %i[name label] }

      it "answers unique members for class ancestry" do
        expect(child.members).to eq(proof)
      end

      it "answers unique members for instance ancestry" do
        expect(child.new.members).to eq(proof)
      end
    end

    context "with single level inheritance" do
      let :child do
        Class.new(implementation) { include Wholeable::Builder.new(:place) }
      end

      let(:proof) { %i[name label place] }

      it "answers members for class ancestry" do
        expect(child.members).to eq(proof)
      end

      it "answers members for instance ancestry" do
        expect(child.new.members).to eq(proof)
      end
    end

    context "with multiple level inheritance" do
      let :first do
        Class.new(implementation) { include Wholeable::Builder.new(:latitude) }
      end

      let :second do
        Class.new(first) { include Wholeable::Builder.new(:longitude) }
      end

      let :third do
        Class.new(second) { include Wholeable::Builder.new(:created_at) }
      end

      let(:proof) { %i[name label latitude longitude created_at] }

      it "answers members for class ancestry" do
        expect(third.members).to eq(proof)
      end

      it "answers members for instance ancestry" do
        expect(third.new.members).to eq(proof)
      end
    end
  end

  it_behaves_like "a whole value object"
end
