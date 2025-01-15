use starknet::ContractAddress;
use core::dict::Felt252DictTrait;

#[derive(Drop, Copy, Serde, starknet::Store)]
//serde for serialization and deserialization
struct Ticket {
    player: ContractAddress,
    number1: u16,  
    number2: u16,
    number3: u16,
    number4: u16,
    claimed: bool,
    drawId: u64,
}

#[derive(Drop, Serde, starknet::Store)]
//serde for serialization and deserialization
struct Draw {
    drawId: u64,
    accumulatedPrize: u256,
    winningNumber1: u16,  
    winningNumber2: u16,
    winningNumber3: u16,
    winningNumber4: u16,
    //map of ticketId to ticket
    //tickets: Map<felt252, Ticket>,
    isActive: bool,
    //start time of the draw,timestamp unix
    startTime: u64,
    //end time of the draw,timestamp unix
    endTime: u64,
}

#[starknet::interface]
trait ILottery<TContractState> {
    fn Initialize(ref self: TContractState, owner: ContractAddress, ticketPrice: u256);
    fn BuyTicket(ref self: TContractState, drawId: u64, numbers: Array<u16>);
    fn DrawNumbers(ref self: TContractState, drawId: u64);
    fn ClaimPrize(ref self: TContractState, drawId: u64, ticketId: felt252);
    fn CheckMatches(self: @TContractState, drawId: u64, number1: u16, number2: u16, number3: u16, number4: u16) -> u8;
    fn GetAccumulatedPrize(self: @TContractState) -> u256;
    fn GetFixedPrize(self: @TContractState, matches: u8) -> u256;
    fn CreateNewDraw(ref self: TContractState, accumulatedPrize: u256);
    fn GetDrawStatus(self: @TContractState, drawId: u64) -> bool;
    fn GetUserTickets(self: @TContractState, drawId: u64) -> Array<felt252>;
    fn GetTicketInfo(self: @TContractState, drawId: u64, ticketId: felt252) -> Ticket;
}

#[starknet::contract]
mod Lottery {
    
    use core::dict::Felt252DictTrait;
    use openzeppelin_access::ownable::OwnableComponent;
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::storage::Map;
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    use super::{Draw, ILottery, Ticket};

    //ownable component by openzeppelin
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    //ownable component by openzeppelin
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    const STRK_CONTRACT_ADRESS: felt252 =
        0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d;

    const PRIZE_POOL_PERCENTAGE: u256 = 70; // 70% va al pool de premios
    const ACCUMULATED_PERCENTAGE: u256 = 30; // 30% va al acumulado

    #[storage]
    struct Storage {
        ticketPrice: u256,
        draws: Map<u64, Draw>,
        tickets: Map<(u64, felt252), Ticket>, 
        currentDrawId: u64,
        currentTicketId: u64,
        fixedPrize4Matches: u256,
        fixedPrize3Matches: u256,
        fixedPrize2Matches: u256,
        //ownable component by openzeppelin
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        accumulatedPrize: u256,
        userTickets: Map<(ContractAddress, u64), felt252>,
        userTicketCount: Map<(ContractAddress, u64), u32>, // (usuario, drawId) -> cantidad de tickets
        userTicketIds: Map<(ContractAddress, u64, u32), felt252>, // (usuario, drawId, índice) -> ticketId
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        TicketPurchased: TicketPurchased,
        DrawCompleted: DrawCompleted,
        PrizeClaimed: PrizeClaimed,
    }

    #[derive(Drop, starknet::Event)]
    struct TicketPurchased {
        drawId: u64,
        player: ContractAddress,
        ticketId: felt252,
        numbers: Array<u16>,
    }

    #[derive(Drop, starknet::Event)]
    struct DrawCompleted {
        drawId: u64,
        winningNumbers: Array<u16>,
        accumulatedPrize: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct PrizeClaimed {
        drawId: u64,
        player: ContractAddress,
        ticketId: felt252,
        prizeAmount: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.ownable.initializer(owner);
        self.fixedPrize4Matches.write(4000000000000000000);
        self.fixedPrize3Matches.write(3000000000000000000);
        self.fixedPrize2Matches.write(2000000000000000000);
        self.currentDrawId.write(0);
    }

    #[abi(embed_v0)]
    impl LotteryImpl of ILottery<ContractState> {
        //OK
        fn Initialize(ref self: ContractState, owner: ContractAddress, ticketPrice: u256) {
            self.ownable.assert_only_owner();
            self.ticketPrice.write(ticketPrice);
            self.CreateNewDraw(0);
        }

        //OK
        fn BuyTicket(ref self: ContractState, drawId: u64, numbers: Array<u16>) {
            assert(self.ValidateNumbers(@numbers), 'Invalid numbers');
            let draw = self.draws.read(drawId);
            assert(draw.isActive, 'Draw is not active');

            // Procesar el pago del ticket
            self.ProcessTicketPayment();

            //TODO: We need to process the payment
            let ticket = Ticket {
                player: get_caller_address(),
                number1: *numbers.at(0),
                number2: *numbers.at(1),
                number3: *numbers.at(2),
                number4: *numbers.at(3),
                claimed: false,
                drawId: drawId,
            };

            let ticketId = GenerateTicketId(ref self);
            self.tickets.write((drawId, ticketId), ticket);

            self.emit(TicketPurchased { drawId, player: get_caller_address(), ticketId, numbers });
            
           
            // Incrementar contador y guardar ticketId
            let count = self.userTicketCount.read((get_caller_address(), drawId));
            self.userTicketIds.write((get_caller_address(), drawId, count), ticketId);
            self.userTicketCount.write((get_caller_address(), drawId), count + 1);
        }

        //OK
        fn DrawNumbers(ref self: ContractState, drawId: u64) {
            self.ownable.assert_only_owner();
            let mut draw = self.draws.read(drawId);
            assert(draw.isActive, 'Draw is not active');

            let winningNumbers = GenerateRandomNumbers();
            draw.winningNumber1 = *winningNumbers.at(0);
            draw.winningNumber2 = *winningNumbers.at(1);
            draw.winningNumber3 = *winningNumbers.at(2);
            draw.winningNumber4 = *winningNumbers.at(3);
            draw.isActive = false;
            self.draws.write(drawId, draw);

            self.emit(DrawCompleted { 
                drawId, 
                winningNumbers, 
                accumulatedPrize: self.accumulatedPrize.read() 
            });
        }

        //OK
        fn ClaimPrize(ref self: ContractState, drawId: u64, ticketId: felt252) {
            let draw = self.draws.read(drawId);
            let ticket = self.tickets.read((drawId, ticketId));
            assert(!ticket.claimed, 'Prize already claimed');
            assert(!draw.isActive, 'Draw still active');

            let matches = self.CheckMatches(drawId, ticket.number1, ticket.number2, ticket.number3, ticket.number4);
            let prize = self.GetFixedPrize(matches);

            if prize > 0 {
                // Procesar el pago del premio
                self.ProcessPrizePayment(ticket.player, prize);
                
                let mut ticket = ticket;
                ticket.claimed = true;
                self.tickets.write((drawId, ticketId), ticket);

                self.emit(PrizeClaimed { 
                    drawId, 
                    player: ticket.player, 
                    ticketId, 
                    prizeAmount: prize 
                });
            }
        }

        //OK
        fn CheckMatches(self: @ContractState, drawId: u64, number1: u16, number2: u16, number3: u16, number4: u16) -> u8 {
            // Obtener el sorteo
            let draw = self.draws.read(drawId);
            assert(!draw.isActive, 'Draw must be completed');

            // Obtener los números ganadores
            let winningNumber1 = draw.winningNumber1;
            let winningNumber2 = draw.winningNumber2;
            let winningNumber3 = draw.winningNumber3;
            let winningNumber4 = draw.winningNumber4;

            // Contador de coincidencias
            let mut matches: u8 = 0;

            // Para cada número del ticket
            let mut i: usize = 0;
            if number1 == winningNumber1 {
                matches += 1;
            }
            if number2 == winningNumber2 {
                matches += 1;
            }
            if number3 == winningNumber3 {
                matches += 1;
            }
            if number4 == winningNumber4 {
                matches += 1;
            }

            matches
        }


        //OK
        fn GetAccumulatedPrize(self: @ContractState) -> u256 {
            self.accumulatedPrize.read()
        }

        //OK
        fn GetFixedPrize(self: @ContractState, matches: u8) -> u256 {
            match matches {
                0 => 0,
                1 => 0,
                2 => self.fixedPrize2Matches.read(),
                3 => self.fixedPrize3Matches.read(),
                4 => self.fixedPrize4Matches.read(),
                _ => 0,
            }
        }

        //OK
        fn CreateNewDraw(ref self: ContractState, accumulatedPrize: u256) {
            let drawId = self.currentDrawId.read() + 1;
            let newDraw = Draw {
                drawId,
                accumulatedPrize: accumulatedPrize,
                winningNumber1: 0,
                winningNumber2: 0,
                winningNumber3: 0,
                winningNumber4: 0,
                //tickets: Map::new(),
                isActive: true,
                startTime: get_block_timestamp(),
                endTime: get_block_timestamp() + 604800 // 1 Week
            };
            self.draws.write(drawId, newDraw);
            self.currentDrawId.write(drawId);
        }

        //OK
        fn GetDrawStatus(self: @ContractState, drawId: u64) -> bool {
            self.draws.read(drawId).isActive
        }

        fn GetUserTickets(self: @ContractState, drawId: u64) -> Array<felt252> {
            let mut userTickets = ArrayTrait::new();
            let count = self.userTicketCount.read((get_caller_address(), drawId));
            
            let mut i: u32 = 0;
            loop {
                if i >= count {
                    break;
                }
                let ticketId = self.userTicketIds.read((get_caller_address(), drawId, i));
                userTickets.append(ticketId);
                i += 1;
            };
            
            userTickets
        }

        fn GetTicketInfo(self: @ContractState, drawId: u64, ticketId: felt252) -> Ticket {
            let draw = self.draws.read(drawId);
            let ticket = self.tickets.read((drawId, ticketId));
            // Verificar que el ticket pertenece al caller
            assert(ticket.player == get_caller_address(), 'Not ticket owner');
            ticket
        }

        fn ProcessTicketPayment(ref self: ContractState) {
            let caller = get_caller_address();
            let contract = get_contract_address();
            let price = self.ticketPrice.read();
            
            // Crear dispatcher para el token STRK
            let strk = IERC20Dispatcher { contract_address: contract_address_const::<STRK_CONTRACT_ADRESS>() };
            
            // Transferir tokens del usuario al contrato
            strk.transfer_from(caller, contract, price);
            
            // Calcular distribución
            let prize_pool = (price * PRIZE_POOL_PERCENTAGE) / 100;
            let accumulated = (price * ACCUMULATED_PERCENTAGE) / 100;
            
            // Actualizar premio acumulado
            self.accumulatedPrize.write(self.accumulatedPrize.read() + accumulated);
        }

        fn ProcessPrizePayment(ref self: ContractState, winner: ContractAddress, amount: u256) {
            // Crear dispatcher para el token STRK
            let strk = IERC20Dispatcher { contract_address: contract_address_const::<STRK_CONTRACT_ADRESS>() };
            
            // Transferir premio al ganador
            strk.transfer(winner, amount);
            
            // Actualizar premio acumulado si es necesario
            if amount > self.accumulatedPrize.read() {
                self.accumulatedPrize.write(0);
            } else {
                self.accumulatedPrize.write(self.accumulatedPrize.read() - amount);
            }
        }
    }

    const MaxNumber: u16 = 40; // max number
    const RequiredNumbers: usize = 5; // amount of numbers per ticket

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        //OK
        fn ValidateNumbers(self: @ContractState, numbers: @Array<u16>) -> bool {
            // Verify correct amount of numbers
            if numbers.len() != RequiredNumbers {
                return false;
            }

            // Verify that there are no duplicates and numbers are in range
            let mut usedNumbers: Felt252Dict<bool> = Default::default();
            let mut i: usize = 0;
            let mut valid = true;

            loop {
                if i >= numbers.len() {
                    break;
                }

                let number = *numbers.at(i);

                // Verify range (0-99)
                if number > MaxNumber {
                    valid = false;
                    break;
                }

                // Verify duplicates
                if usedNumbers.get(number.into()) == true {
                    valid = false;
                    break;
                }

                usedNumbers.insert(number.into(), true);
                i += 1;
            };

            valid
        }
    }

    //OK
    fn GenerateTicketId(ref self: ContractState) -> felt252 {
        let ticketId = self.currentTicketId.read() + 1;
        self.currentTicketId.write(ticketId);
        ticketId.into()
    }

    //OK
    fn GenerateRandomNumbers() -> Array<u16> {
        let mut numbers = ArrayTrait::new();
        let blockTimestamp = get_block_timestamp();
        
        // Usar solo timestamp para generar números (para testing)
        let mut count = 0;
        let mut usedNumbers: Felt252Dict<bool> = Default::default();

        loop {
            if count >= 4 {
                break;
            }
            let number = (blockTimestamp + count) % (MaxNumber.into() + 1);
            let number_u16: u16 = number.try_into().unwrap();
            
            if usedNumbers.get(number.into()) != true {
                numbers.append(number_u16);
                usedNumbers.insert(number.into(), true);
                count += 1;
            }
        };

        numbers
    }
    // fn GenerateRandomNumbers() -> Array<u16> {
    //     TODO: We need to use VRF de Pragma Oracle to generate random numbers

    //     now we are generating random numbers for testing
    //     let mut numbers = ArrayTrait::new();
    //     let blockTimestamp = get_block_timestamp();
    //     let blockHash = get_block_hash();

    //     seed is the combination of the block timestamp and the block hash
    //     let seed = blockTimestamp + blockHash;

    //     generate 4 unique numbers between 0-99
    //     let mut usedNumbers: Felt252Dict<bool> = Default::default();
    //     let mut count = 0;

    //     while count < 4 {
    //         let number = (seed + count) % 100;

    //         check if the number is already used
    //         if !usedNumbers.contains(number) {
    //             numbers.append(number);
    //             usedNumbers.insert(number, true);
    //             count += 1;
    //         }
    //     }

    //     numbers
    // }
}
