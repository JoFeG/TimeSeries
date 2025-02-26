include("../src/ExpEval.jl")

ID = 3
df = ExpEval.LoadDataSumary()
TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true);

M1 = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw")

n, m = size(TRAIN)

# This is introduces for each series 
# a missing gap of length uniformly selected between 0 and 10%
# Starting at an uniformly random placement in the series


M = m                  # Experiment 1
# M = round(Int,m/5)   # Experiment 2

for i = 1:n
    gap_max_prop = 0.1
    gap_length = round(Int, gap_max_prop * m * rand())
    gap_start = rand(1:M-gap_length+1)
    
    TRAIN[i, gap_start:gap_start+gap_length-1] .= NaN
end

for i = 1:n
    gap_max_prop = 0.1
    gap_length = round(Int, gap_max_prop * m * rand())
    gap_start = rand(1:M-gap_length+1)
    
    TRAIN[i, gap_start:gap_start+gap_length-1] .= NaN
end

# Repeat for 2%
for i = 1:n
    gap_max_prop = 0.02
    gap_length = round(Int, gap_max_prop * m * rand())
    gap_start = rand(1:M-gap_length+1)
    
    TRAIN[i, gap_start:gap_start+gap_length-1] .= NaN
end

M0 = ExpEval.calculate_distance_matrix_dtwAB(TRAIN, 0)
MA = ExpEval.calculate_distance_matrix_dtwAB(TRAIN, 1)
MB = ExpEval.calculate_distance_matrix_dtwAB(TRAIN, 2)

M1 = sqrt.(M1)
M0 = sqrt.(M0)
MA = sqrt.(MA)
MB = sqrt.(MB)
