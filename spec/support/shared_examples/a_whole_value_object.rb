# frozen_string_literal: true

RSpec.shared_examples "a whole value object" do
  let(:similar) { implementation.new }
  let(:different) { implementation.new name: "odd" }

  describe ".members" do
    it "answers members" do
      expect(implementation.members).to eq(%i[name label])
    end
  end

  describe "#initialize" do
    it "answers attributes" do
      expect(whole).to have_attributes(name: "test", label: "Test")
    end
  end

  describe "#frozen?" do
    it "answers true" do
      expect(whole.frozen?).to be(true)
    end
  end

  describe "#diff" do
    it "answers differences when two instances are not equal" do
      expect(similar.diff(different)).to eq(name: %w[test odd])
    end

    it "answers differences when types are different" do
      expect(whole.diff(Data.define)).to eq(name: ["test", nil], label: ["Test", nil])
    end

    it "answers empty hash when there are no differences" do
      expect(whole.diff(similar)).to eq({})
    end
  end

  describe "#eql?" do
    it "answers true when values are equal" do
      expect(whole.eql?(similar)).to be(true)
    end

    it "answers false when values are not equal" do
      expect(whole.eql?(different)).to be(false)
    end

    it "answers false with different type" do
      expect(whole.eql?("other")).to be(false)
    end
  end

  describe "#equal?" do
    it "answers true when object IDs are identical" do
      expect(whole.equal?(whole)).to be(true)
    end

    it "answers false when object IDs are different" do
      expect(whole.equal?(similar)).to be(false)
    end
  end

  describe "#==" do
    it "answers true when values are equal" do
      expect((whole == similar)).to be(true)
    end

    it "answers false when values are not equal" do
      expect((whole == different)).to be(false)
    end

    it "answers false with different type" do
      expect((whole == "other")).to be(false)
    end
  end

  describe "#hash" do
    it "answers identical hash when values are equal" do
      expect(whole.hash).to eq(similar.hash)
    end

    it "answers different hash when values are not equal" do
      expect(whole.hash).not_to eq(different.hash)
    end

    it "answers different hash with different type" do
      expect(whole.hash).not_to eq("other".hash)
    end
  end

  describe "#inspect" do
    it "answers inspection information" do
      expect(whole.inspect).to match(/#<#<Class:.+{18}>\s@name="test",\s@label="Test">/)
    end
  end

  describe "#members" do
    it "answers array of attribute keys" do
      expect(whole.members).to eq(%i[name label])
    end
  end

  describe "#to_a" do
    it "answers array" do
      expect(whole.to_a).to eq(%w[test Test])
    end
  end

  describe "#to_h" do
    it "answers hash" do
      expect(whole.to_h).to eq(name: "test", label: "Test")
    end
  end

  describe "#with" do
    it "answers new instance with defaults" do
      expect(whole.with).to have_attributes(name: "test", label: "Test")
    end

    it "answers new instance with partial changes" do
      modification = whole.with label: "Mod"
      expect(modification).to have_attributes(name: "test", label: "Mod")
    end

    it "answers new instance with complete changes" do
      modification = whole.with name: "mod", label: "Mod"
      expect(modification).to have_attributes(name: "mod", label: "Mod")
    end
  end

  describe "#deconstruct" do
    it "answers array" do
      expect(whole.deconstruct).to eq(%w[test Test])
    end
  end

  describe "#deconstruct_keys" do
    it "answers hash" do
      expect(whole.deconstruct_keys).to eq(name: "test", label: "Test")
    end
  end
end
