using Random;



function playGame(card_set::Vector{String}, 
         hands::Vector{Vector{String}},
         playercount::Int8)
        i::Int8 = 0;
        while all(x -> length(x) > 1, hands)

                i = (i % playercount) + 1
                break
        end
        a = rand((1:playercount))
        b = rand((1:100))
        return a, b
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

function allUnder(scores::Vector{Int64}, win_score::Int64)
        """
        Checks whether all scores are under a certain value
        returns true when statement is true and false when it is not
        in:


        """
        for i in scores
                if i > win_score
                        return false
                end
        end
        return true
end


function main()
	playercount::Int8 = 4;
        scores::Vector{Int64} = [0::Int64 for i in 1:playercount]
        win_score::Int64 = 250;
        w::Int8 = 1;

        while scores[w] < win_score
                card_set::Vector{String} = createCards(playercount);
                hands = shuffleAndDivide(card_set, playercount)
                w, points = playGame(card_set, hands, playercount)
                scores[w] = scores[w] + points
        end
        println(scores)

end


main()
