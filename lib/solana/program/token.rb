module Solana
  module Program
    class Token < Base
      PROGRAM_ID = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'

      INSTRUCTION_LAYOUTS = {
        # transfer
        3 => {
          instruction: :uint8,
          amount: :uint64,
        },

        # transfer_checked
        12 => {
          instruction: :uint8,
          amount: :uint64,
          decimals: :uint8
        }
      }

      INSTRUCTION_NAMES = {
        3 => 'transfer',
        12 => 'transfer_checked'
      }

      PROGRAM_NAME = 'token'

      def self.parse(fields, data, keys)
        d = decode_data(fields, data)

        instruction_name = INSTRUCTION_NAMES[d[:instruction]]
        if instruction_name == 'transfer'
          return {
            from_address: keys[0][:pubkey],
            to_address: keys[1][:pubkey],
            amount: d[:amount],
            program_name: PROGRAM_NAME,
            instruction_name: INSTRUCTION_NAMES[d[:instruction]],
          }
        elsif instruction_name == 'transfer_checked'
          return {
            mint_address: keys[1][:pubkey],
            from_address: keys[0][:pubkey],
            to_address: keys[2][:pubkey],
            amount: d[:amount],
            decimals: d[:decimals],
            program_name: PROGRAM_NAME,
            instruction_name: INSTRUCTION_NAMES[d[:instruction]],
          }
        end
        return nil
      end

      class << self
        def transfer_checked_instruction(from_token_account_pubkey:, token_pubkey:, to_token_account_pubkey:, from_pubkey:, amount:, decimals:)
          fields = INSTRUCTION_LAYOUTS[12]
          data = encode_data(fields, {instruction: 12, amount: amount, decimals: decimals})

          keys = [
            {pubkey: from_token_account_pubkey, is_signer: false, is_writable: true},
            {pubkey: token_pubkey, is_signer: false, is_writable: false},
            {pubkey: to_token_account_pubkey, is_signer: false, is_writable: true},
            {pubkey: from_pubkey, is_signer: false, is_writable: false}
          ]
          represent(keys, data)
        end
      end
    end
  end
end
