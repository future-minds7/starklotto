/**
 * This file is autogenerated by Scaffold-Stark.
 * You should not edit it manually or your changes might be overwritten.
 */

const deployedContracts = {
  sepolia: {
    Lottery: {
      address:
        "0x75c487e15c2541cb6904e735e3727120a4344a79404394bc17f7729a8c57f06",
      abi: [
        {
          type: "impl",
          name: "LotteryImpl",
          interface_name: "contracts::Lottery::ILottery",
        },
        {
          type: "struct",
          name: "core::integer::u256",
          members: [
            {
              name: "low",
              type: "core::integer::u128",
            },
            {
              name: "high",
              type: "core::integer::u128",
            },
          ],
        },
        {
          type: "enum",
          name: "core::bool",
          variants: [
            {
              name: "False",
              type: "()",
            },
            {
              name: "True",
              type: "()",
            },
          ],
        },
        {
          type: "struct",
          name: "contracts::Lottery::Ticket",
          members: [
            {
              name: "player",
              type: "core::starknet::contract_address::ContractAddress",
            },
            {
              name: "number1",
              type: "core::integer::u16",
            },
            {
              name: "number2",
              type: "core::integer::u16",
            },
            {
              name: "number3",
              type: "core::integer::u16",
            },
            {
              name: "number4",
              type: "core::integer::u16",
            },
            {
              name: "number5",
              type: "core::integer::u16",
            },
            {
              name: "claimed",
              type: "core::bool",
            },
            {
              name: "drawId",
              type: "core::integer::u64",
            },
          ],
        },
        {
          type: "interface",
          name: "contracts::Lottery::ILottery",
          items: [
            {
              type: "function",
              name: "Initialize",
              inputs: [
                {
                  name: "ticketPrice",
                  type: "core::integer::u256",
                },
                {
                  name: "accumulatedPrize",
                  type: "core::integer::u256",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "BuyTicket",
              inputs: [
                {
                  name: "drawId",
                  type: "core::integer::u64",
                },
                {
                  name: "numbers",
                  type: "core::array::Array::<core::integer::u16>",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "DrawNumbers",
              inputs: [
                {
                  name: "drawId",
                  type: "core::integer::u64",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "ClaimPrize",
              inputs: [
                {
                  name: "drawId",
                  type: "core::integer::u64",
                },
                {
                  name: "ticketId",
                  type: "core::felt252",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "CheckMatches",
              inputs: [
                {
                  name: "drawId",
                  type: "core::integer::u64",
                },
                {
                  name: "number1",
                  type: "core::integer::u16",
                },
                {
                  name: "number2",
                  type: "core::integer::u16",
                },
                {
                  name: "number3",
                  type: "core::integer::u16",
                },
                {
                  name: "number4",
                  type: "core::integer::u16",
                },
                {
                  name: "number5",
                  type: "core::integer::u16",
                },
              ],
              outputs: [
                {
                  type: "core::integer::u8",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "GetAccumulatedPrize",
              inputs: [],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "GetFixedPrize",
              inputs: [
                {
                  name: "matches",
                  type: "core::integer::u8",
                },
              ],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "CreateNewDraw",
              inputs: [
                {
                  name: "accumulatedPrize",
                  type: "core::integer::u256",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "GetDrawStatus",
              inputs: [
                {
                  name: "drawId",
                  type: "core::integer::u64",
                },
              ],
              outputs: [
                {
                  type: "core::bool",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "GetUserTickets",
              inputs: [
                {
                  name: "drawId",
                  type: "core::integer::u64",
                },
              ],
              outputs: [
                {
                  type: "core::array::Array::<core::felt252>",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "GetUserTicketsCount",
              inputs: [
                {
                  name: "drawId",
                  type: "core::integer::u64",
                },
              ],
              outputs: [
                {
                  type: "core::integer::u32",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "GetTicketInfo",
              inputs: [
                {
                  name: "drawId",
                  type: "core::integer::u64",
                },
                {
                  name: "ticketId",
                  type: "core::felt252",
                },
              ],
              outputs: [
                {
                  type: "contracts::Lottery::Ticket",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "GetTicketCurrentId",
              inputs: [],
              outputs: [
                {
                  type: "core::integer::u64",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "GetWinningNumbers",
              inputs: [
                {
                  name: "drawId",
                  type: "core::integer::u64",
                },
              ],
              outputs: [
                {
                  type: "core::array::Array::<core::integer::u16>",
                },
              ],
              state_mutability: "view",
            },
          ],
        },
        {
          type: "impl",
          name: "OwnableImpl",
          interface_name: "openzeppelin_access::ownable::interface::IOwnable",
        },
        {
          type: "interface",
          name: "openzeppelin_access::ownable::interface::IOwnable",
          items: [
            {
              type: "function",
              name: "owner",
              inputs: [],
              outputs: [
                {
                  type: "core::starknet::contract_address::ContractAddress",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "transfer_ownership",
              inputs: [
                {
                  name: "new_owner",
                  type: "core::starknet::contract_address::ContractAddress",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "renounce_ownership",
              inputs: [],
              outputs: [],
              state_mutability: "external",
            },
          ],
        },
        {
          type: "constructor",
          name: "constructor",
          inputs: [
            {
              name: "owner",
              type: "core::starknet::contract_address::ContractAddress",
            },
          ],
        },
        {
          type: "event",
          name: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferred",
          kind: "struct",
          members: [
            {
              name: "previous_owner",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
            {
              name: "new_owner",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
          ],
        },
        {
          type: "event",
          name: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferStarted",
          kind: "struct",
          members: [
            {
              name: "previous_owner",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
            {
              name: "new_owner",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
          ],
        },
        {
          type: "event",
          name: "openzeppelin_access::ownable::ownable::OwnableComponent::Event",
          kind: "enum",
          variants: [
            {
              name: "OwnershipTransferred",
              type: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferred",
              kind: "nested",
            },
            {
              name: "OwnershipTransferStarted",
              type: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferStarted",
              kind: "nested",
            },
          ],
        },
        {
          type: "event",
          name: "contracts::Lottery::Lottery::TicketPurchased",
          kind: "struct",
          members: [
            {
              name: "drawId",
              type: "core::integer::u64",
              kind: "data",
            },
            {
              name: "player",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "data",
            },
            {
              name: "ticketId",
              type: "core::felt252",
              kind: "data",
            },
            {
              name: "numbers",
              type: "core::array::Array::<core::integer::u16>",
              kind: "data",
            },
          ],
        },
        {
          type: "event",
          name: "contracts::Lottery::Lottery::DrawCompleted",
          kind: "struct",
          members: [
            {
              name: "drawId",
              type: "core::integer::u64",
              kind: "data",
            },
            {
              name: "winningNumbers",
              type: "core::array::Array::<core::integer::u16>",
              kind: "data",
            },
            {
              name: "accumulatedPrize",
              type: "core::integer::u256",
              kind: "data",
            },
          ],
        },
        {
          type: "event",
          name: "contracts::Lottery::Lottery::PrizeClaimed",
          kind: "struct",
          members: [
            {
              name: "drawId",
              type: "core::integer::u64",
              kind: "data",
            },
            {
              name: "player",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "data",
            },
            {
              name: "ticketId",
              type: "core::felt252",
              kind: "data",
            },
            {
              name: "prizeAmount",
              type: "core::integer::u256",
              kind: "data",
            },
          ],
        },
        {
          type: "event",
          name: "contracts::Lottery::Lottery::Event",
          kind: "enum",
          variants: [
            {
              name: "OwnableEvent",
              type: "openzeppelin_access::ownable::ownable::OwnableComponent::Event",
              kind: "flat",
            },
            {
              name: "TicketPurchased",
              type: "contracts::Lottery::Lottery::TicketPurchased",
              kind: "nested",
            },
            {
              name: "DrawCompleted",
              type: "contracts::Lottery::Lottery::DrawCompleted",
              kind: "nested",
            },
            {
              name: "PrizeClaimed",
              type: "contracts::Lottery::Lottery::PrizeClaimed",
              kind: "nested",
            },
          ],
        },
      ],
      classHash:
        "0x74f0c443ca875f734982b76b8917e6c6417aaf591f48b9f226df985409420e7",
    },
  },
} as const;

export default deployedContracts;
