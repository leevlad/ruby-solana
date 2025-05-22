module Solana
  module Sedes
    class String
      def initialize
        @size = nil # Variable size
      end

      def dynamic_size(bytes)
        # First 8 bytes are the length as a 64-bit integer
        length = bytes.first(8).pack('C*').unpack('Q<').first
        # Return total size: 8 bytes for length + length bytes for string
        return 8 + length
      end

      def serialize(obj)
        raise "Can only serialize strings" unless obj.is_a?(::String)
        # First 8 bytes are the length as a 64-bit integer
        length_bytes = [obj.length].pack('Q<').bytes
        # Then the string bytes
        string_bytes = obj.bytes
        length_bytes + string_bytes
      end

      def deserialize(bytes)
        # First 8 bytes are the length as a 64-bit integer
        length = bytes.shift(8).pack('C*').unpack('Q<').first
        # Then read the string and remove those bytes from the array
        string_bytes = bytes.shift(length)
        string_bytes.pack('C*')
      end
    end
  end
end
