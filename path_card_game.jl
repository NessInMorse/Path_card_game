using Random;


function evolveSpecies(win_indices::Vector{Int8}, playstyles::Vector{Vector{Any}}, mutation_chance::Float64)
        
        p1::Vector{Any} = ["Smart"]
        p2::Vector{Any} = ["Smart"]
        p3::Vector{Any} = ["Smart"]
        p4::Vector{Any} = ["Smart"]

        children = [p1, p2, p3, p4]
        for i in eachindex(playstyles[1][2])
                fill = copy(playstyles[win_indices[1]][2])
                fill[i] = fill[i] + rand(-50:50)
                if fill[i] > 999
                        fill[i] = 999
                elseif fill[i] < -999
                        fill[i] = -999
                end
                push!(children[i], fill)
        end

        new_population = [playstyles[win_indices[1]]]
        append!(new_population, children)
        return new_population
end


function writeHistory(infile, i::Int64, win_indices::Vector{Int8}, playstyles::Vector{Vector{Any}}, win_counts::Vector{Int64})
        printstr::String = "$i" * '\t' * "$(win_counts[win_indices[1]])" * '\t' * join(playstyles[win_indices[1]][2], '\t') * '\n'
        write(infile, printstr)
end


function findHighestPerformers(win_counts::Vector{Int64})
        """
        Finds the maximum and second highest number in the vector
        in:
                win_counts, a vector containing the number of wins of each of the players
        out:
                win_indices, a vector containing the positions of the best performers.
        """
        max_num = win_counts[1]
        max_ind = 1
        for i in eachindex(win_counts)
                if win_counts[i] > max_num
                        max_num = win_counts[i]
                        max_ind = i
                end
        end

        sec_max = 0
        sec_max_ind = 0 
        for i in eachindex(win_counts)
                if win_counts[i] > sec_max && i != max_ind
                        sec_max = win_counts[i]
                        sec_max_ind = i
                end
        end
        win_indices::Vector{Int8} = [max_ind, sec_max_ind]
        return win_indices
end


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

function calculateSmartMove(p::Vector{Int64},
                            move_positions::Vector{Int8},
                            hand::Vector{String},
                            board::Vector{String},
                            start_number::Int8)
        """
        A function that calculates the optimal move using the formula,
                where the card with the highest Score (S) is chosen to be played:

                s = k + N + d + (B - b)
                
                s = score of the card (the higher the better to play the card)
                k = the count of the cards with the same prefix in the hand
                C = the amount of cards with the same prefix not yet played
                d = distance to the starting number
                B = the (resting) cards 'behind' the card that can be played
                b = the (resting) cards 'behind' the card that can be played that the player owns

                there are 4 variables within the phenotype vector which affect the strongness
                        of each of these signals within the formula, with P being the phenotype vector:

                        s = (p1 * k) + (p2 * N) + (p3 * (10 - d)) + (p4 * (B - b))
        in:
                p, a list of all the different variances for the formula (=phenotype).
                move_positions, a list of all the positions of the cards the player can play.
                hand, a list with a string of all the cards in the hand.
                board, a list of all the cards that are played on the board,
                        and empty space for cards not yet placed.
                start_number, the starting number of the game.
        out:
                move, the index of the move to play
        """
        scores::Vector{Int64} = [0 for i in move_positions]
        prefix::Char = 0
        s::Int64 = 0
        k::Int64 = 0
        N::Int64 = 0
        charpoint::Int64 = 0
        num::Int64 = 0
        begin_index::Int64 = 0
        d::Int64 = 0
        B::Int64 = 0
        b::Int64 = 0

        card_pref::Char = 0

        for i in eachindex(move_positions)
                prefix = hand[move_positions[i]][1]
                k = 0
                for j in eachindex(hand)
                        if hand[j][1] == prefix
                                k = k + 1
                        end
                end


                N = 0
                x = hand[move_positions[i]]
                begin_index = ((codepoint(x[1]) - 65) * 10) + 1

                for j in begin_index:(begin_index + 9)
                        if board[j] == ""
                                N = N + 1
                        end
                end

                d = abs(start_number - num)

                B = 0
                if start_number == num
                        B = 9
                elseif start_number < num
                        B = 10 - num
                else
                        B = num - 1
                end



                iter = move_positions[i]
                b = 0
                if d == 0
                        b = k - 1
                elseif (start_number - num) > 0
                        while iter < length(hand) && prefix == card_pref
                                card_pref = hand[iter][1]
                                if prefix == card_pref
                                        b = b + 1
                                end
                                iter = iter + 1
                        end
                else # < 0
                        while iter > 1 && prefix == card_pref
                                card_pref = hand[iter][1]
                                if prefix == card_pref
                                        b = b + 1
                                end
                                iter = iter + 1
                        end
                end
                s = p[1] * k + p[2] * N + p[3] * (10 - d) + p[4] * (B - b)
                scores[i] = s
        end
        max::Int64 = scores[1]
        ind::Int8 = 1
        for i in eachindex(scores)
                if scores[i] > max
                        max = scores[i]
                        ind = i
                end
        end
        
        return move_positions[ind]
end


function chooseMove(move_positions::Vector{Int8},
                    playstyle::Vector{Any},
                    hand::Vector{String},
                    board::Vector{String},
                    start_number::Int8)
        """
        Function that chooses a move based on the playstyle of the CPU.


        out:
                the index of the card that is played by the CPU.
        """

        # Random
        move::Int8 = 0
        if length(move_positions) > 0 
                if length(move_positions) == 1
                        move = move_positions[1]
                elseif playstyle[1] == "Random"
                        move = move_positions[rand(eachindex(move_positions))]
                elseif playstyle[1] == "Smart"
                        move = calculateSmartMove(playstyle[2],
                                                  move_positions,
                                                  hand,
                                                  board,
                                                  start_number)
                end
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
         w::Int8,
         playstyles::Vector{Vector{Any}})
        ONE::Int8 = 1
        board::Vector{String} = createBoard(playercount)
        start_number::Int8 = rand(1:10)
        move_option_board::Vector{Bool} = [false for i in 1:(playercount*10)]
        calls::Int64 = 0
        while all(x -> length(x) > 1, hands)
                
                move_option_board = possibleBoardMoves(move_option_board, board, start_number, calls)
                calls += 1
                move_positions = findPossibleMoves(move_option_board, hands, w)
                move = chooseMove(move_positions,
                                  playstyles[w], 
                                  hands[w], 
                                  board, 
                                  start_number)
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

function createPlaystyles(playercount::Int8)
        play_styles::Vector{Vector{Any}} = []
        options = ["Smart"] # ["Random", "Smart"]
        for i in 1:playercount
                a = rand(options)
                fill_list = []
                push!(fill_list, a)
                if a == "Smart"
                        push!(fill_list, [rand((-999:999)) for i in 1:4])
                end
                push!(play_styles, fill_list)
        end
        return play_styles
end



function main()
        begin_time::Float64 = time()

        infile = open("generation_history.tsv", "w")
        write(infile, "gen\twins\tk\tC\td\tB\n")

        mutation_chance = 0.03
	playercount::Int8 = 2;
        scores::Vector{Int64} = [0::Int64 for i in 1:playercount]
        win_score::Int64 = 250;
        cluster_count::Int8 = 5


        win_counts::Vector{Vector{Int64}} = [[0 for i in 1:playercount] for _ in 1:cluster_count];
        w::Int8 = rand(1:playercount);
        card_set::Vector{String} = [];
        playstyles = createPlaystyles(cluster_count)

        clusters::Vector{Vector{Vector{Any}}} = [[playstyles[i], ["Random"]] for i in 1:cluster_count]
        
        smart_wincounts::Vector{Int64} = [0 for i in 1:cluster_count]
        generations::Int64 = 1000
        games::Int64 = 500
        for i in 1:generations
                # println(playstyles)
                win_counts = [[0 for i in 1:playercount] for _ in 1:cluster_count]
                for j in 1:length(clusters)
                        for _ in 1:games
                                scores = [0::Int64 for i in 1:playercount]
                                win_score = 250;
                                w = rand(1:playercount);
                                while scores[w] < win_score
                                        card_set = createCards(playercount);
                                        hands = shuffleAndDivide(card_set, playercount)
                                        w, points = playGame(card_set, hands, playercount, w, playstyles)
                                        scores[w] = scores[w] + points
                                end
                                win_counts[j][w] = win_counts[j][w] + 1
                        end
                end

                smart_wincounts = [i[1] for i in win_counts]

                win_indices = findHighestPerformers(smart_wincounts)
                writeHistory(infile, i, win_indices, playstyles, smart_wincounts)
                playstyles = evolveSpecies(win_indices, playstyles, mutation_chance)
                clusters = [[playstyles[i], ["Random"]] for i in 1:cluster_count]

        end
        close(infile)
        end_time::Float64 = time()
        println("Generations:\t\t$generations\nGames played:\t\t$games\nPlayercount:\t\t$playercount\nScore to win:\t\t$win_score points\nCompleted in:\t\t", end_time - begin_time, " seconds")
        println(playstyles)
        println(smart_wincounts)
end


main()
