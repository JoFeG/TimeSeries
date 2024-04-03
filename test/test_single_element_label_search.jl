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

# ID = 15, TRAIN class 1 has count 1
# ID = 27, TRAIN class 41 has count 1
# ID = 27, TEST class 44 has count 1
# ID = 101, TRAIN class 1 has count 1
# ... (all)
# ID = 101, TRAIN class 18 has count 1

for i = 1:length(IDs)
    ID = IDs[i]
    TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df)
    
    TRAIN_assignments = ExpEval.relabelLabels(TRAIN_labels)
    k = length(unique(TRAIN_assignments))
    for j = 1:k
        if sum(TRAIN_assignments .== j) == 1
            println("ID = $ID, TRAIN class $j has count 1")
        end
        if sum(TRAIN_assignments .== j) == 0
            println("ID = $ID, TRAIN class $j has count 0")
        end
    end
    
    TEST_assignments = ExpEval.relabelLabels(TEST_labels)
    k = length(unique(TEST_assignments))
    for j = 1:k
        if sum(TEST_assignments .== j) == 1
            println("ID = $ID, TEST class $j has count 1")
        end
        if sum(TRAIN_assignments .== j) == 0
            println("ID = $ID, TRAIN class $j has count 0")
        end
    end
end


