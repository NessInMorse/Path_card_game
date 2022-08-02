using Random;



function chooseMove(board::Vector{String}, moves::Vector{Bool}, hands::Vector{Vector{String}}, w::Int8)
        # Random
        println(moves)
        r = rand(eachindex(moves))
        return board, hands
end

function possibleBoardMoves(move_option_board::Vector{Bool},
                            board::Vector{String},
                            start_number::Int8,
                            calls::Int64)
        if calls == 0
                positions = [start_number + 10 * (i-1) for i in 1:(trunc(Int64,length(move_option_board)/10))]
        
                for i in positions
                        move_option_board[i] = true
                end

                return move_option_board
        else
                positions = [start_number + 10 * (i-1) for i in 1:(trunc(Int64,length(move_option_board)/10))]
                move_option_board = [false for i in 1:length(board)]
                for i in positions
                        move_option_board[i] = true
                end

                for i in eachindex(move_option_board)
                        if (i % 10) == 1
                                if move_option_board[i + 1] == true
                                        move_option_board[i] = true
                                end
                        elseif (i % 10) != 0
                                if move_option_board[i + 1] == true  || move_option_board[i - 1] == true
                                        move_option_board[i] = true
                                end
                        elseif (i % 10) == 0
                                if move_option_board[i - 1] == true
                                        move_option_board[i] = true
                                end
                        end
                end
                
                return move_option_board
        end

end

function findPossibleMoves(move_option_board::Vector{Bool},
                           hands::Vector{Vector{String}},
                           w::Int8)
        move_options::Vector{Int8} = [0 for i in hands[w]];
        println(move_option_board)
        println(hands[w])
        for i::Int8 in eachindex(hands[w])
                if move_option_board[cardIndex(hands[w][i])]
                        append!(move_options, i)
                end
        end
        println(move_options)
        return move_options
end


function createBoard(playercount::Int8)
        str::String = "";
        board::Vector{String} = [str for i in 1:playercount*10]
        return board
end

function playGame(card_set::Vector{String}, 
         hands::Vector{Vector{String}},
         playercount::Int8,
         w::Int8)
        ONE::Int8 = 1
        board::Vector{String} = createBoard(playercount)
        start_number::Int8 = rand(1:10)
        move_option_board::Vector{Bool} = [false for i in 1:(playercount*10)]
        calls::Int64 = 0
        while all(x -> length(x) > 1, hands)
                
                move_option_board = possibleBoardMoves(move_option_board, board, start_number, calls)
                calls += 1
                moves = findPossibleMoves(move_option_board, hands, w)
                board, hands = chooseMove(board, moves, hands, w)

                if all(x -> length(x) > 1, hands)
                        w = (w % playercount) + ONE
                        
                end
                if calls == 5
                        break
                end
        end
        a = rand((1:playercount))
        b = rand((1:100))
        return a, b
end


function cardIndex(x::String)
        a = (codepoint(x[1]) - 65) * 10
        b = parse(Int64, x[2:end])
        return (a + b)
end


function shuffleAndDivide(card_set::Vector{String}, playercount::Int8)
        """
        A function which shuffles and divides the cards to all players
        in:
                Vector{String}: card_set, a vector with
                        all the card names
                Int8: playercount, the total amount of players
        out:
                Vector{Vector{String}}: hands, all the 
                        cards of all the hands of the players

        """
        shuffle_set = shuffle(copy(card_set))
        
        hands::Vector{Vector{String}} = [shuffle_set[1 + ((i - 1) * 10) : 10 + ((i - 1) * 10)] 
                                                for i in 1:playercount]
        hands = [sort!(i, by = cardIndex) for i in hands]
        return hands
end

function createCards(players::Int8)
        """
        Creates the cardset that is used in the game.
        in:
                Int8: players, the amount of players in the game
        out:
                
        """
	starting_pos::Int8 = 64;
	cards::Int8 = 10;

	max::Int8 = 24;
	all_cards::Vector{String} = [];
	new_set::Vector{String} = [];
	for i in 1:players
		new_set = [Char(i + starting_pos) * string(j) for j in 1:cards];
		append!(all_cards, new_set)
	end

	return all_cards
end




function main()
	playercount::Int8 = 4;
        scores::Vector{Int64} = [0::Int64 for i in 1:playercount]
        win_score::Int64 = 250;
        w::Int8 = rand(1:playercount);

        while scores[w] < win_score
                card_set::Vector{String} = createCards(playercount);
                hands = shuffleAndDivide(card_set, playercount)
                w, points = playGame(card_set, hands, playercount, w)
                scores[w] = scores[w] + points
        end
        println(scores)

end


main()
