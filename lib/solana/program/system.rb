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
        },
        # createAccountWithSeed
        3 => {
          instruction: :uint32,
          base: :blob32,
          seed: :string,
          lamports: :near_int64,
          space: :near_int64,
          owner: :blob32
        }
      }

      INSTRUCTION_NAMES = {
        2 => 'transfer',
        3 => 'createAccountWithSeed'
      }

      PROGRAM_NAME = 'system'

      def self.parse(fields, data, keys)
        d = decode_data(fields, data)
        instruction_name = INSTRUCTION_NAMES[d[:instruction]]

        if instruction_name == 'transfer'
          return {
            # compatibility with standard interface
            from_address: keys[0][:pubkey],
            to_address: keys[1][:pubkey],
            program_name: PROGRAM_NAME,
            instruction_name: INSTRUCTION_NAMES[d[:instruction]],

            lamports: d[:lamports],
          }
        elsif instruction_name == 'createAccountWithSeed'
          return {
            # compatibility with standard interface
            from_address: Base58.binary_to_base58(d[:base], :bitcoin),
            to_address: Base58.binary_to_base58(d[:base], :bitcoin),
            program_name: PROGRAM_NAME,
            instruction_name: INSTRUCTION_NAMES[d[:instruction]],

            # stake specific fields
            base: Base58.binary_to_base58(d[:base], :bitcoin),
            seed: d[:seed],
            lamports: d[:lamports],
            space: d[:space],
            owner: Base58.binary_to_base58(d[:owner], :bitcoin),
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

        def create_account_with_seed_instruction(
          funding_pubkey:,
          created_pubkey:,
          base_pubkey:,
          seed:,
          lamports:,
          space:,
          owner_pubkey:
        )
          fields = INSTRUCTION_LAYOUTS[3]
          data = encode_data(fields, {
            instruction: 3,
            base: base_pubkey,
            seed: seed,
            lamports: lamports,
            space: space,
            owner: owner_pubkey
          })

          keys = [
            { pubkey: funding_pubkey, is_signer: true, is_writable: true },
            { pubkey: created_pubkey, is_signer: false, is_writable: true },
            { pubkey: base_pubkey, is_signer: true, is_writable: false }
          ]

          represent(keys, data)
        end
      end
    end
  end
end
