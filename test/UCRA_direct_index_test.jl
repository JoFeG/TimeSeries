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


if isfile("Indices_df.csv") 
    Indices_df = CSV.write("ndices_df.csv",Indices_df)
else 
    Indices_df = dff[:,["ID","Name"]]
end


## MEAN SILHOUETTE INDEX
if false
    TRAIN_silhouettes_dtw = [zeros(dff[dff.ID .== ID,:].Train[1]) for ID in IDs]
    TRAIN_silhouettes_euc = [zeros(dff[dff.ID .== ID,:].Train[1]) for ID in IDs]
    I_TRAIN_ms_dtw = zeros(length(IDs))
    I_TRAIN_ms_euc = zeros(length(IDs))


    TEST_silhouettes_dtw = [zeros(dff[dff.ID .== ID,:].Test[1]) for ID in IDs]
    TEST_silhouettes_euc = [zeros(dff[dff.ID .== ID,:].Test[1]) for ID in IDs]
    I_TEST_ms_dtw = zeros(length(IDs))
    I_TEST_ms_euc = zeros(length(IDs))

    for i = 1:length(IDs)
        ID = IDs[i]

        TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true);


        TRAIN_assignments = ExpEval.relabelLabels(TRAIN_labels)

        M_TRAIN_dtw = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw")
        TRAIN_silhouettes_dtw[i] = silhouettes(TRAIN_assignments, M_TRAIN_dtw)
        I_TRAIN_ms_dtw[i] = sum(TRAIN_silhouettes_dtw[i]) / length(TRAIN_silhouettes_dtw[i])

        M_TRAIN_euc = ExpEval.load_distance_matrix(ID, df, "TRAIN", "euc")
        TRAIN_silhouettes_euc[i] = silhouettes(TRAIN_assignments, M_TRAIN_euc)
        I_TRAIN_ms_euc[i] = sum(TRAIN_silhouettes_euc[i]) / length(TRAIN_silhouettes_euc[i])


        TEST_assignments = ExpEval.relabelLabels(TEST_labels)

        M_TEST_dtw = ExpEval.load_distance_matrix(ID, df, "TEST", "dtw")   
        TEST_silhouettes_dtw[i] = silhouettes(TEST_assignments, M_TEST_dtw)
        I_TEST_ms_dtw[i] = sum(TEST_silhouettes_dtw[i]) / length(TEST_silhouettes_dtw[i])

        M_TEST_euc = ExpEval.load_distance_matrix(ID, df, "TEST", "euc")
        TEST_silhouettes_euc[i] = silhouettes(TEST_assignments, M_TEST_euc)
        I_TEST_ms_euc[i] = sum(TEST_silhouettes_euc[i]) / length(TEST_silhouettes_euc[i])

    end

    Indices_df.TRAIN_ms_dtw = I_TRAIN_ms_dtw
    Indices_df.TRAIN_ms_euc = I_TRAIN_ms_euc

    Indices_df.TEST_ms_dtw = I_TEST_ms_dtw
    Indices_df.TEST_ms_euc = I_TEST_ms_euc

    display(Indices_df)

    CSV.write("ndices_df.csv",Indices_df)
end