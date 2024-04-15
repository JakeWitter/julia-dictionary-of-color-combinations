module AJDoCC

using JSON: parsefile
using Colors: RGB
using DataFrames, Colors
using Random: rand

# Read the JSON file
json_data = parsefile("colors.json")

# Create the initial DataFrame 'colours' directly from the JSON data
colours = DataFrame(json_data)

# Add 'id' column to 'df' containing a unique sequential key for each color
colours.colour_id = 1:size(colours, 1)
# Parse loaded JSON to RGB
colours.rgb = map(x->RGB((x/255)...), colours.rgb)
# Drop unnecessary cols and order
select!(colours, [:colour_id, :name, :rgb, :combinations])

# Create an empty DataFrame 'combinations'
combinations = DataFrame(
    combination_id = Int[], 
    colour_ids = Vector{Int}[],
    length = Int[],
    rgbs = Vector{RGB{Float64}}[]
)

# Iterate colours, creating combinations and adding to them
for (i, colour_row) in enumerate(eachrow(colours))
    # Get the combination IDs for the color
    assoc_combinations = Vector{Int}(colour_row.combinations)
    
    # Iterate over each combination our colour belongs to
    for combination in assoc_combinations
        # Find that combination in combinations
        match_combinations = filter(x -> combination == x.combination_id, combinations)

        # Add it if necessary, otherwise add to it
        if size(match_combinations)[1] == 0
            push!(combinations, (combination, [colour_row.colour_id], 1, [colour_row.rgb]))
        else
            comb = match_combinations[1,:]
            push!(comb.colour_ids, colour_row.colour_id)
            push!(comb.rgbs,       colour_row.rgb)
        end
    end
end

combinations.length = map(x->size(x)[1], combinations.colour_ids)

sort!(combinations, :combination_id)

############################################################################################

twos()   = filter(x->x.length==2, combinations)
threes() = filter(x->x.length==3, combinations)
fours()  = filter(x->x.length==4, combinations)

function random(len::Int64)
    @assert 2 <= len <= 4
    combs = filter(x->x.length==len, combinations)
    return combs.rgbs[rand(1:size(combs)[1])]
end

end