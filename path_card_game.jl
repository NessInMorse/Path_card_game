using Random;

function createCards(players::Int8)
	starting_pos::Int8 = 64;
	cards::Int8 = 10;

	max::Int8 = 24;
	all_cards::Vector{Vector{String}} = [];
	new_set::Vector{String} = [];
	for i in 1:players
		new_set = [Char(i+starting_pos) * string(j) for j in 1:cards];
		println(new_set)
		append!(all_cards, [new_set])
		println(all_cards)
	end

	return all_cards
end


function main()
	playercount::Int8 = 4;
	card_set::Vector{Vector{String}} = createCards(playercount);
	

end


main()
