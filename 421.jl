function dice_result(dice)
    if dice[1] == dice[2] == dice[3]
        if dice[1] == 1
            return 7
        end
        return dice[1]
    end
    sorted_dice = sort([dice...])
    if sorted_dice[1] == 1 && sorted_dice[2] == 2 && sorted_dice[3] == 4
        if dice[1] == 2
            return 10
        end
        return 8
    end
    if (sorted_dice[2] == sorted_dice[1] + 1 &&
        sorted_dice[3] == sorted_dice[2] + 1)
        return 3
    end
    1
end

type Reroll
    score::Float64
    dice::(Int64, Int64)
end


DICE_SCORE = Dict{Array{Float64}, Reroll}()

for i = 1:6
    for j = 1:6
        for k = 1:6
            DICE_SCORE[[i, j, k]] = Reroll(dice_result((i, j, k)), (0, 0))
        end
    end
end

function score_cdf(score)
    num_under = count(x -> x <= score, values(DICE_SCORE))
    return num_under / length(DICE_SCORE)
end

function new_roll(dice, i, val)
    roll = [dice...]
    roll[i] = val
    roll
end


function max_expected_value(dice, dice_score, bias = 0)
    current_score = DICE_SCORE[dice]
    max_score = current_score.score + bias
    best_i = 0
    best_j = 0
    for i = 1:3
        for j = 1:3
            if i == j
                # rolls = [new_roll(dice, i, k).score for k = 1:6]
                # println(rolls)
                results = [dice_score[new_roll(dice, i, k)].score for k = 1:6]
                # println(results)
                score = sum(results) / 6
            else
                score = sum([dice_score[new_roll(new_roll(dice, i, x), j, y)].score
                             for x = 1:6, y = 1:6]) / 36
            end
            if score > max_score
                max_score = score
                best_i = i
                best_j = j
            end
        end
    end
    return Reroll(max_score, (best_i, best_j))
end

BEST_ONE_STEP = Dict{Array{Int64}, Reroll}()
BEST_TWO_STEP = Dict{Array{Int64}, Reroll}()

for i = 1:6
    for j = 1:6
        for k = 1:6
            BEST_ONE_STEP[[i, j, k]] = max_expected_value([i, j, k], DICE_SCORE)
        end
    end
end

for i = 1:6
    for j = 1:6
        for k = 1:6
            BEST_TWO_STEP[[i, j, k]] = max_expected_value([i, j, k], BEST_ONE_STEP, 1)
        end
    end
end


println(BEST_TWO_STEP)

# println(max_expected_value([4,2,5], DICE_SCORE))
# println(score_cdf(10))

println(BEST_TWO_STEP[[2,2,2]])
