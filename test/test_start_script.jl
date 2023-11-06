# push!(LOAD_PATH, "./src/"); using ExpEval 
# to be able to reload use the following. Functions exported via using remain the same, test using ExpEval.___

using DelimitedFiles
using DataFrames

push!(LOAD_PATH, "./src/") 
include("../src/ExpEval.jl") # repeat to reload 


ID = 3
df = ExpEval.LoadDataSumary()
TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true);
