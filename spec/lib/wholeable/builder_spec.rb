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

    context "with mutability" do
      let :implementation do
        Class.new do
          include Wholeable::Builder.new(:name, kind: :mutable)

          def initialize name: "test"
            @name = name
          end
        end
      end

      it "allows attributes to be mutated" do
        whole.name = "other"
        expect(whole.name).to eq("other")
      end

      it "doesn't freeze when mutable" do
        expect(whole.frozen?).to be(false)
      end
    end

    context "with immutable parent and mutable child" do
      subject(:whole) { child.new }

      let :child do
        Class.new implementation do
          include Wholeable::Builder.new(:place, kind: :mutable)

          def initialize place: "remote"
            super()
            @place = place
          end
        end
      end

      it "allows attributes to be mutated" do
        whole.place = "space"
        expect(whole.place).to eq("space")
      end

      it "doesn't freeze when mutable" do
        expect(whole.frozen?).to be(false)
      end
    end

    context "with mutable parent and immutable child" do
      subject(:whole) { immutable.new }

      let :mutable do
        Class.new do
          include Wholeable::Builder.new(:name, kind: :mutable)

          def initialize name: "test"
            @name = name
          end
        end
      end

      let :immutable do
        Class.new mutable do
          include Wholeable::Builder.new(:label)

          def initialize label: "Test"
            super()
            @label = label
          end
        end
      end

      it "doesn't allow parent attribute to be mutated" do
        expectation = proc { whole.name = "other" }
        expect(&expectation).to raise_error(FrozenError, /name=/)
      end

      it "doesn't allow child attribute to be mutated" do
        expectation = proc { whole.label = "other" }
        expect(&expectation).to raise_error(NoMethodError, /label=/)
      end

      it "freezes class" do
        expect(whole.frozen?).to be(true)
      end
    end
  end

  it_behaves_like "a whole value object"
end
