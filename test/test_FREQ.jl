include("../src/FREQ_utils.jl")

path = "./data/freq/raw/2023_set_n1/"


using DelimitedFiles
summary, header = readdlm("./data/freq/experiment_data_summary.csv", ',', header=true)

summary

i = 3
y, P0, t = SamplerRaw_FREQ(path * summary[i,1] * ".csv")

