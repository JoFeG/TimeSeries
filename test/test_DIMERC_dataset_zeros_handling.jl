include("../src/DIMERC_utils.jl")

json = LoadDataSet_DIMERC_json()
Y = DIMERCseriesjson2matrix(json)

m, n = size(Y)

Max_gap = 52
Max_tot = 104

ids_over_max_gap = zeros(Int,n)
ids_over_max_tot = zeros(Int,n)

for k = 1:n
    count_gap = 0
    count_tot = 0
    for i = 1:m
        if Y[i,k] == 0
            count_gap += 1
            count_tot += 1
        else
            count_gap >= Max_gap ? ids_over_max_gap[k] = 1 : nothing
            count_gap = 0
        end
    end
    count_gap >= Max_gap ? ids_over_max_gap[k] = 1 : nothing
    count_tot >= Max_tot ? ids_over_max_tot[k] = 1 : nothing
end

println("Series above Max_gap = $(sum(ids_over_max_gap))")
println("Series above Max_tot = $(sum(ids_over_max_tot))")
println("Series excluded      = $(sum((ids_over_max_gap + ids_over_max_tot) .> 0))")

YY = Y[:,(ids_over_max_gap + ids_over_max_tot) .== 0]
m, nn = size(YY)

println("Percentage remaining = $(round(100*nn/n,digits=2))")

indx_is_missing = zeros(Int, m, nn)

Tz_lim = 3

for k = 1:nn
    zero_count = 0
    for i = 1:m
        if YY[i,k] == 0 
            zero_count += 1
        else
            if zero_count >= Tz_lim
                indx_is_missing[(i-zero_count):i-1,k] .= 1
            end
            zero_count = 0
        end
    end
    if zero_count >= Tz_lim
        indx_is_missing[(m-zero_count+1):m,k] .= 1
    end
end

println("\n---------------------\n after removals \n")
println("Total zeros = $(sum(YY.==0)) 
             from a total of nn*m = $(nn*m)
             correspontding to $(round(100*sum(YY .== 0)/(nn*m),digits=2))%")
println("False zeros = $(sum(indx_is_missing)) (missings)")
println(" True zeros = $(sum(YY.==0) - sum(indx_is_missing))")
