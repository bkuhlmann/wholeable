# frozen_string_literal: true

module Wholeable
  # Provides core equality behavior.
  class Builder < Module
    def self.add_aliases descendant
      descendant.alias_method :deconstruct, :to_a
      descendant.alias_method :deconstruct_keys, :to_h
      descendant.alias_method :to_s, :inspect
    end

    def initialize *keys
      super()
      @keys = keys.uniq
      @members = []
      setup
    end

    def included descendant
      super
      coalesce_members descendant

      descendant.class_eval <<-METHODS, __FILE__, __LINE__ + 1
        def self.[](...) = new(...)

        def self.new(...) = super.freeze

        def self.members = #{members}

        attr_reader #{keys.map(&:inspect).join ", "}
      METHODS

      self.class.add_aliases descendant
    end

    private

    attr_reader :keys, :members

    def setup
      private_methods.grep(/\A(define)_/).sort.each { |method| __send__ method }
      freeze
    end

    def coalesce_members descendant
      members.replace(descendant.respond_to?(:members) ? (descendant.members + keys).uniq : keys)
    end

    def define_diff
      define_method :diff do |other|
        if other.is_a? self.class
          to_h.merge!(other.to_h) { |_, one, two| [one, two].uniq }
              .select { |_, diff| diff.size == 2 }
        else
          to_h.each.with_object({}) { |(key, value), diff| diff[key] = [value, nil] }
        end
      end
    end

    def define_eql
      define_method(:eql?) { |other| instance_of?(other.class) && hash == other.hash }
    end

    def define_equality
      define_method(:==) { |other| other.is_a?(self.class) && hash == other.hash }
    end

    def define_hash
      define_method :hash do
        members.map { |key| public_send key }
               .prepend(self.class)
               .hash
      end
    end

    def define_inspect
      define_method :inspect do
        klass = self.class
        name = klass.name || klass.inspect

        members.map { |key| "@#{key}=#{public_send(key).inspect}" }
               .join(", ")
               .then { |pairs| "#<#{name} #{pairs}>" }
      end
    end

    def define_members(local_members = members) = define_method(:members) { local_members }

    def define_to_a
      define_method :to_a do
        members.reduce([]) { |collection, key| collection.append public_send(key) }
      end
    end

    def define_to_h
      define_method :to_h do
        members.each.with_object({}) { |key, attributes| attributes[key] = public_send key }
      end
    end

    def define_with
      define_method(:with) { |**attributes| self.class.new(**to_h.merge!(attributes)) }
    end
  end
end
