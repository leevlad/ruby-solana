module Solana
  module Sedes
    class Layout
      attr_reader :fields

      def initialize(fields)
        @fields = fields
      end

      def serialize(params)
        fields.map do |field, type|
          sede = if type.is_a?(Symbol)
                   Solana::Sedes.send(type)
                 else
                   type
                 end

          sede.serialize(params[field])
        end.flatten
      end

      def deserialize(bytes)
        result = {}
        bytes = bytes.dup # Create a copy to avoid modifying the original
        fields.each do |field, type|
          sede = if type.is_a?(Symbol)
                   Solana::Sedes.send(type)
                 else
                   type
                 end

          size = 0
          if sede.respond_to?(:dynamic_size)
            size = sede.dynamic_size(bytes)
          else
            size = sede.size
          end

          # For fixed length fields, take only the required number of bytes
          result[field] = sede.deserialize(bytes.shift(size))
        end
        result
      end
    end
  end
end
