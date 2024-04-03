using Clustering
using DataFrames
using CSV
include("../src/ExpEval.jl")


df = ExpEval.LoadDataSumary()
dff = df[isa.(df.Length,Number), :] 

nm_cap = 1000
    
dff = dff[
    (dff.Length .< nm_cap) .&
    (dff.Train .< nm_cap) .&
    (dff.Test .< nm_cap) .&
    (dff.ID .!= 93) .&                   # HAS MISSING VALUES
    (dff.ID .!= 94) .&                   # HAS MISSING VALUES
    (dff.ID .!= 95),                     # HAS MISSING VALUES
    :]
IDs = dff.ID