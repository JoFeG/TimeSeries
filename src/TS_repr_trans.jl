using Statistics: mean

function TS_moving_average(y, hw)
    m = length(y)
    ŷ = zeros(m)
    
    for t = 1:m
        if t < hw
            ŷ[t] = mean(@view y[1:t])
        elseif t > m-hw
            ŷ[t] = mean(@view y[t:end])
        else
            ŷ[t] = mean(@view y[t-hw+1:t+hw])
        end
    end
    
    return ŷ
end


function TS_exponential_smoothing(y, α)
    m = length(y)
    ŷ = zeros(m)
    ŷ[1] = y[1]
    
    for t = 2:m
        ŷ[t] = α*y[t] + (1-α)*ŷ[t-1]
    end
    
    return ŷ
end

function TS_zscore_normalization(y)
    μ = mean(y)
    σ = std(y)

    ŷ = (y .- μ) / σ
    
    return ŷ
end

