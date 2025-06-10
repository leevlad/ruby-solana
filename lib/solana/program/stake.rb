module Solana
  module Program
    class Stake < Base
      PROGRAM_ID = 'Stake11111111111111111111111111111111111111'
      SYSVAR_RENT_ID = 'SysvarRent111111111111111111111111111111111'
      SYSVAR_CLOCK_ID = 'SysvarC1ock11111111111111111111111111111111'
      SYSVAR_STAKE_HISTORY_ID = 'SysvarStakeHistory1111111111111111111111111'
      SYSVAR_STAKE_CONFIG_ID = 'StakeConfig11111111111111111111111111111111'

      INSTRUCTION_LAYOUTS = {
        0 => {
          instruction: :uint32,
          staker: :blob32,
          withdrawer: :blob32,
          lockup_epoch: :uint64,
          lockup_timestamp: :near_int64,
          lockup_custodian: :blob32
        },
        2 => {
          instruction: :uint32
        },
        5 => {
          instruction: :uint32
        },
        4 => {
          instruction: :uint32,
          amount: :uint64
        }
      }

      INSTRUCTION_NAMES = {
        0 => 'initialize',
        2 => 'delegate',
        5 => 'undelegate',
        4 => 'withdraw'
      }

      PROGRAM_NAME = 'stake'

      def self.parse(fields, data, keys)
        d = decode_data(fields, data)
        instruction_name = INSTRUCTION_NAMES[d[:instruction]]

        case instruction_name
        when 'initialize'
          return {
            from_address: Base58.binary_to_base58(d[:staker], :bitcoin),
            to_address: keys[0][:pubkey],
            program_name: PROGRAM_NAME,
            instruction_name: INSTRUCTION_NAMES[d[:instruction]],

            staker: Base58.binary_to_base58(d[:staker], :bitcoin),
            withdrawer: Base58.binary_to_base58(d[:withdrawer], :bitcoin),
            stake_account: keys[0][:pubkey],
            lockup_epoch: d[:lockup_epoch],
            lockup_timestamp: d[:lockup_timestamp],
            lockup_custodian: Base58.binary_to_base58(d[:lockup_custodian], :bitcoin),
          }
        when 'delegate'
          return {
            from_address: keys[5][:pubkey],
            to_address: keys[1][:pubkey],
            program_name: PROGRAM_NAME,
            instruction_name: INSTRUCTION_NAMES[d[:instruction]],

            stake_account: keys[0][:pubkey],
            vote_account: keys[1][:pubkey],
            clock_sysvar: keys[2][:pubkey],
            stake_history_sysvar: keys[3][:pubkey],
            stake_config: keys[4][:pubkey],
            stake_authority: keys[5][:pubkey],
          }
        when 'undelegate'
          return {
            from_address: keys[2][:pubkey],
            to_address: keys[0][:pubkey],
            program_name: PROGRAM_NAME,
            instruction_name: INSTRUCTION_NAMES[d[:instruction]],

            stake_account: keys[0][:pubkey],
            clock_sysvar: keys[1][:pubkey],
            stake_authority: keys[2][:pubkey],
          }
        when 'withdraw'
          return {
            from_address: keys[0][:pubkey],
            to_address: keys[1][:pubkey],
            program_name: PROGRAM_NAME,
            instruction_name: INSTRUCTION_NAMES[d[:instruction]],

            stake_account: keys[0][:pubkey],
            destination: keys[1][:pubkey],
            clock_sysvar: keys[2][:pubkey],
            stake_history_sysvar: keys[3][:pubkey],
            withdraw_authority: keys[4][:pubkey],
            lamports: d[:amount]
          }
        else
          raise "Unknown instruction: #{instruction_name}"
        end
      end

      class << self
        def initialize_instruction(staker, withdrawer, lockup_epoch: 0, lockup_timestamp: 0, lockup_custodian: nil)
          fields = INSTRUCTION_LAYOUTS[0]
          data = encode_data(fields, {
            instruction: 0,
            staker: staker,
            withdrawer: withdrawer,
            lockup_epoch: lockup_epoch,
            lockup_timestamp: lockup_timestamp,
            lockup_custodian: lockup_custodian || staker
          })

          keys = [
            { pubkey: staker, is_signer: true, is_writable: true }, # stake account
            { pubkey: SYSVAR_RENT_ID, is_signer: false, is_writable: false } # rent sysvar
          ]

          represent(keys, data)
        end

        def delegate_instruction(stake_account:, vote_account:, stake_authority:)
          fields = INSTRUCTION_LAYOUTS[2]
          data = encode_data(fields, {
            instruction: 2
          })

          keys = [
            { pubkey: stake_account, is_signer: false, is_writable: true }, # stake account
            { pubkey: vote_account, is_signer: false, is_writable: false }, # vote account
            { pubkey: SYSVAR_CLOCK_ID, is_signer: false, is_writable: false }, # clock sysvar
            { pubkey: SYSVAR_STAKE_HISTORY_ID, is_signer: false, is_writable: false }, # stake history sysvar
            { pubkey: SYSVAR_STAKE_CONFIG_ID, is_signer: false, is_writable: false }, # stake config account
            { pubkey: stake_authority, is_signer: true, is_writable: false } # stake authority
          ]

          represent(keys, data)
        end

        def undelegate_instruction(stake_account:, stake_authority:)
          fields = INSTRUCTION_LAYOUTS[5]
          data = encode_data(fields, {
            instruction: 5
          })

          keys = [
            { pubkey: stake_account, is_signer: false, is_writable: true }, # stake account
            { pubkey: SYSVAR_CLOCK_ID, is_signer: false, is_writable: false }, # clock sysvar
            { pubkey: stake_authority, is_signer: true, is_writable: false } # stake authority
          ]

          represent(keys, data)
        end

        def withdraw_instruction(stake_account:, destination:, withdraw_authority:, amount:)
          fields = INSTRUCTION_LAYOUTS[4]
          data = encode_data(fields, {
            instruction: 4,
            amount: amount
          })

          keys = [
            { pubkey: stake_account, is_signer: false, is_writable: true }, # stake account
            { pubkey: destination, is_signer: false, is_writable: true }, # destination account
            { pubkey: SYSVAR_CLOCK_ID, is_signer: false, is_writable: false }, # clock sysvar
            { pubkey: SYSVAR_STAKE_HISTORY_ID, is_signer: false, is_writable: false }, # stake history sysvar
            { pubkey: withdraw_authority, is_signer: true, is_writable: false } # withdraw authority
          ]

          represent(keys, data)
        end
      end
    end
  end
end
