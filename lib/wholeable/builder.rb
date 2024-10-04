# frozen_string_literal: true

module Wholeable
  # Provides core equality behavior.
  class Builder < Module
    def initialize *keys
      super()
      @keys = keys.uniq
      private_methods.grep(/\A(define)_/).sort.each { |method| __send__ method }
      freeze
    end

    def included descendant
      super

      descendant.class_eval <<-READER, __FILE__, __LINE__ + 1
        def self.new(...) = super.freeze

        attr_reader #{keys.map(&:inspect).join ", "}
      READER

      descendant.alias_method :deconstruct, :to_a
      descendant.alias_method :deconstruct_keys, :to_h
    end

    private

    attr_reader :keys

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

    def define_hash local_keys = keys
      define_method :hash do
        local_keys.map { |key| public_send key }
                  .prepend(self.class)
                  .hash
      end
    end

    def define_inspect local_keys = keys
      define_method :inspect do
        klass = self.class
        name = klass.name || klass.inspect

        local_keys.map { |key| "@#{key}=#{public_send(key).inspect}" }
                  .join(", ")
                  .then { |pairs| "#<#{name} #{pairs}>" }
      end
    end

    def define_to_a local_keys = keys
      define_method :to_a do
        local_keys.reduce([]) { |array, key| array.append public_send(key) }
      end
    end

    def define_to_h local_keys = keys
      define_method :to_h do
        local_keys.each.with_object({}) { |key, dictionary| dictionary[key] = public_send key }
      end
    end

    def define_with
      define_method(:with) { |**attributes| self.class.new(**to_h.merge!(attributes)) }
    end
  end
end
