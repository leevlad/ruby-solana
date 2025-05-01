module Solana
  module Program
    class System < Base
      PROGRAM_ID = '11111111111111111111111111111111'
      SYSVAR_RENT_ID = 'SysvarRent111111111111111111111111111111111'

      INSTRUCTION_LAYOUTS = {
        # transfer
        2 => {
          instruction: :uint32,
          lamports: :near_int64
        }
      }

      INSTRUCTION_NAMES = {
        2 => 'transfer'
      }

      PROGRAM_NAME = 'system'

      def self.parse(fields, data, keys)
        d = decode_data(fields, data)
        instruction_name = INSTRUCTION_NAMES[d[:instruction]]
        if instruction_name == 'transfer'
          return {
            from_address: keys[0][:pubkey],
            to_address: keys[1][:pubkey],
            lamports: d[:lamports],
            program_name: PROGRAM_NAME,
            instruction_name: INSTRUCTION_NAMES[d[:instruction]],
          }
        end
        return nil
      end

      class << self
        def transfer_instruction(from_pubkey:, to_pubkey:, lamports:)
          fields = INSTRUCTION_LAYOUTS[2]
          data = encode_data(fields, {instruction: 2, lamports: lamports})

          keys = [
            { pubkey: from_pubkey, is_signer: true, is_writable: true },
            { pubkey: to_pubkey, is_signer: false, is_writable: true }
          ]

          represent(keys, data)
        end
      end
    end
  end
end
