using Random;

function calculateScore(board::Vector{String})
        score::Int64 = 0
        for i in eachindex(board)
                if board[i] == ""
                        if i ÷ 10 == 1
                                score += 15
                        else
                                score += (i % 10) + 1
                        end
                end
        end
        return score
end


function placeCard(board::Vector{String}, hands::Vector{Vector{String}}, w::Int8, move::Int8)
        board[cardIndex(hands[w][move])] = hands[w][move]
        deleteat!(hands[w], move)
        return board
end

function chooseMove(move_positions::Vector{Int8})
        # Random
        move::Int8 = 0
        if length(move_positions) > 0
                move = move_positions[rand(eachindex(move_positions))]
        end
        return move
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

                for i in eachindex(board)
                        if (i % 10) == 1
                                if board[i + 1] != ""
                                        move_option_board[i] = true
                                end
                        elseif (i % 10) != 0
                                if board[i + 1] != ""  || board[i - 1] != ""
                                        move_option_board[i] = true
                                end
                        elseif (i % 10) == 0
                                if board[i - 1] != ""
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
        """
        Finds and returns the possible moves a player can make
        in:
                All the possible moves on the board
                the hands of all the players
                the current player
        out:
                the positions of all the moves the player can take
        """
        move_options::Vector{Int8} = [];
        for i::Int8 in eachindex(hands[w])
                if move_option_board[cardIndex(hands[w][i])]
                        append!(move_options, i)
                end
        end
        return move_options
end


function createBoard(playercount::Int8)
        """
        Creates a board by the numbers of players
        in:
                the playercount
        out:
                a board with 10 times as many cards as there are players
        """
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
                move_positions = findPossibleMoves(move_option_board, hands, w)
                move = chooseMove(move_positions)
                if move > 0 
                        board = placeCard(board, hands, w, move)
                end

                if all(x -> length(x) > 1, hands)
                        w = (w % playercount) + ONE
                        
                end
        end
        
        score = calculateScore(board)
        # println(w)
        # println(board)
        # println(score)
        return w, score
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
        begin_time::Float64 = time()

	playercount::Int8 = 4;
        scores::Vector{Int64} = [0::Int64 for i in 1:playercount]
        win_score::Int64 = 250;
        w::Int8 = rand(1:playercount);
        card_set::Vector{String} = [];
        games::Int64 = 1_500_000
        for i in 1:games
                scores = [0::Int64 for i in 1:playercount]
                win_score = 250;
                w = rand(1:playercount);
                while scores[w] < win_score
                        card_set = createCards(playercount);
                        hands = shuffleAndDivide(card_set, playercount)
                        w, points = playGame(card_set, hands, playercount, w)
                        scores[w] = scores[w] + points
                end
                # println(scores)
        end
        end_time::Float64 = time()
        println("Games played:\t\t$games\nPlayercount:\t\t$playercount\nScore to win:\t\t$win_score points\nCompleted in:\t\t", end_time - begin_time, " seconds")
end


main()
