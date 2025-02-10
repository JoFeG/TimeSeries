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

