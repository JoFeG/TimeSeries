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

if false
    if isfile("Indices_df.csv") 
        Indices_df = CSV.read("Indices_df.csv", DataFrame)
    else 
        Indices_df = dff[:,["ID","Name"]]
    end
end

## MEAN SILHOUETTE INDEX ##########################################################
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

    CSV.write("Indices_df.csv",Indices_df)
end

## DUNN INDEX #####################################################################
if false
    I_TRAIN_di_dtw = zeros(length(IDs))
    I_TRAIN_di_euc = zeros(length(IDs))

    I_TEST_di_dtw = zeros(length(IDs))
    I_TEST_di_euc = zeros(length(IDs))

    for i = 1:length(IDs)
        ID = IDs[i]

        TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true);


        TRAIN_assignments = ExpEval.relabelLabels(TRAIN_labels)

        M_TRAIN_dtw = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw")
        I_TRAIN_di_dtw[i] = ExpEval.dunnindex(TRAIN_assignments, M_TRAIN_dtw)
        
        M_TRAIN_euc = ExpEval.load_distance_matrix(ID, df, "TRAIN", "euc")
        I_TRAIN_di_euc[i] = ExpEval.dunnindex(TRAIN_assignments, M_TRAIN_euc)
         

        TEST_assignments = ExpEval.relabelLabels(TEST_labels)

        M_TEST_dtw = ExpEval.load_distance_matrix(ID, df, "TEST", "dtw")   
        I_TEST_di_dtw[i] = ExpEval.dunnindex(TEST_assignments, M_TEST_dtw)

        M_TEST_euc = ExpEval.load_distance_matrix(ID, df, "TEST", "euc")
        I_TEST_di_euc[i] = ExpEval.dunnindex(TEST_assignments, M_TEST_euc)

    end

    Indices_df.TRAIN_di_dtw = I_TRAIN_di_dtw
    Indices_df.TRAIN_di_euc = I_TRAIN_di_euc

    Indices_df.TEST_di_dtw = I_TEST_di_dtw
    Indices_df.TEST_di_euc = I_TEST_di_euc

    display(Indices_df)

    CSV.write("Indices_df.csv",Indices_df)
end


## GAMMA INDEX ####################################################################
if false
    I_TRAIN_ga_dtw = zeros(length(IDs))
    I_TRAIN_ga_euc = zeros(length(IDs))

    I_TEST_ga_dtw = zeros(length(IDs))
    I_TEST_ga_euc = zeros(length(IDs))

    for i = 1:length(IDs)
        ID = IDs[i]

        TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true);


        TRAIN_assignments = ExpEval.relabelLabels(TRAIN_labels)

        M_TRAIN_dtw = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw")
        I_TRAIN_ga_dtw[i] = ExpEval.gammaindex(TRAIN_assignments, M_TRAIN_dtw)
        
        M_TRAIN_euc = ExpEval.load_distance_matrix(ID, df, "TRAIN", "euc")
        I_TRAIN_ga_euc[i] = ExpEval.gammaindex(TRAIN_assignments, M_TRAIN_euc)
         

        TEST_assignments = ExpEval.relabelLabels(TEST_labels)

        M_TEST_dtw = ExpEval.load_distance_matrix(ID, df, "TEST", "dtw")   
        I_TEST_ga_dtw[i] = ExpEval.gammaindex(TEST_assignments, M_TEST_dtw)

        M_TEST_euc = ExpEval.load_distance_matrix(ID, df, "TEST", "euc")
        I_TEST_ga_euc[i] = ExpEval.gammaindex(TEST_assignments, M_TEST_euc)

    end

    Indices_df.TRAIN_ga_dtw = I_TRAIN_ga_dtw
    Indices_df.TRAIN_ga_euc = I_TRAIN_ga_euc

    Indices_df.TEST_ga_dtw = I_TEST_ga_dtw
    Indices_df.TEST_ga_euc = I_TEST_ga_euc

    display(Indices_df)

    CSV.write("Indices_df.csv",Indices_df)
end


###################################################################################
###################################################################################

if true
    if isfile("IndicesZ_df.csv") 
        IndicesZ_df = CSV.read("IndicesZ_df.csv", DataFrame)
    else 
        IndicesZ_df = dff[:,["ID","Name"]]
    end
end

## MEAN SILHOUETTE INDEX ##########################################################
if true
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

        M_TRAIN_dtw = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw_z")
        TRAIN_silhouettes_dtw[i] = silhouettes(TRAIN_assignments, M_TRAIN_dtw)
        I_TRAIN_ms_dtw[i] = sum(TRAIN_silhouettes_dtw[i]) / length(TRAIN_silhouettes_dtw[i])

        M_TRAIN_euc = ExpEval.load_distance_matrix(ID, df, "TRAIN", "euc_z")
        TRAIN_silhouettes_euc[i] = silhouettes(TRAIN_assignments, M_TRAIN_euc)
        I_TRAIN_ms_euc[i] = sum(TRAIN_silhouettes_euc[i]) / length(TRAIN_silhouettes_euc[i])


        TEST_assignments = ExpEval.relabelLabels(TEST_labels)

        M_TEST_dtw = ExpEval.load_distance_matrix(ID, df, "TEST", "dtw_z")   
        TEST_silhouettes_dtw[i] = silhouettes(TEST_assignments, M_TEST_dtw)
        I_TEST_ms_dtw[i] = sum(TEST_silhouettes_dtw[i]) / length(TEST_silhouettes_dtw[i])

        M_TEST_euc = ExpEval.load_distance_matrix(ID, df, "TEST", "euc_z")
        TEST_silhouettes_euc[i] = silhouettes(TEST_assignments, M_TEST_euc)
        I_TEST_ms_euc[i] = sum(TEST_silhouettes_euc[i]) / length(TEST_silhouettes_euc[i])

    end

    IndicesZ_df.TRAIN_ms_dtw = I_TRAIN_ms_dtw
    IndicesZ_df.TRAIN_ms_euc = I_TRAIN_ms_euc

    IndicesZ_df.TEST_ms_dtw = I_TEST_ms_dtw
    IndicesZ_df.TEST_ms_euc = I_TEST_ms_euc

    display(IndicesZ_df)

    CSV.write("IndicesZ_df.csv",IndicesZ_df)
end

## DUNN INDEX #####################################################################
if true
    I_TRAIN_di_dtw = zeros(length(IDs))
    I_TRAIN_di_euc = zeros(length(IDs))

    I_TEST_di_dtw = zeros(length(IDs))
    I_TEST_di_euc = zeros(length(IDs))

    for i = 1:length(IDs)
        ID = IDs[i]

        TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true);


        TRAIN_assignments = ExpEval.relabelLabels(TRAIN_labels)

        M_TRAIN_dtw = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw_z")
        I_TRAIN_di_dtw[i] = ExpEval.dunnindex(TRAIN_assignments, M_TRAIN_dtw)
        
        M_TRAIN_euc = ExpEval.load_distance_matrix(ID, df, "TRAIN", "euc_z")
        I_TRAIN_di_euc[i] = ExpEval.dunnindex(TRAIN_assignments, M_TRAIN_euc)
         

        TEST_assignments = ExpEval.relabelLabels(TEST_labels)

        M_TEST_dtw = ExpEval.load_distance_matrix(ID, df, "TEST", "dtw_z")   
        I_TEST_di_dtw[i] = ExpEval.dunnindex(TEST_assignments, M_TEST_dtw)

        M_TEST_euc = ExpEval.load_distance_matrix(ID, df, "TEST", "euc_z")
        I_TEST_di_euc[i] = ExpEval.dunnindex(TEST_assignments, M_TEST_euc)

    end

    IndicesZ_df.TRAIN_di_dtw = I_TRAIN_di_dtw
    IndicesZ_df.TRAIN_di_euc = I_TRAIN_di_euc

    IndicesZ_df.TEST_di_dtw = I_TEST_di_dtw
    IndicesZ_df.TEST_di_euc = I_TEST_di_euc

    display(IndicesZ_df)

    CSV.write("IndicesZ_df.csv",IndicesZ_df)
end


## GAMMA INDEX ####################################################################
if true
    I_TRAIN_ga_dtw = zeros(length(IDs))
    I_TRAIN_ga_euc = zeros(length(IDs))

    I_TEST_ga_dtw = zeros(length(IDs))
    I_TEST_ga_euc = zeros(length(IDs))

    for i = 1:length(IDs)
        ID = IDs[i]

        TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true);


        TRAIN_assignments = ExpEval.relabelLabels(TRAIN_labels)

        M_TRAIN_dtw = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw_z")
        I_TRAIN_ga_dtw[i] = ExpEval.gammaindex(TRAIN_assignments, M_TRAIN_dtw)
        
        M_TRAIN_euc = ExpEval.load_distance_matrix(ID, df, "TRAIN", "euc_z")
        I_TRAIN_ga_euc[i] = ExpEval.gammaindex(TRAIN_assignments, M_TRAIN_euc)
         

        TEST_assignments = ExpEval.relabelLabels(TEST_labels)

        M_TEST_dtw = ExpEval.load_distance_matrix(ID, df, "TEST", "dtw_z")   
        I_TEST_ga_dtw[i] = ExpEval.gammaindex(TEST_assignments, M_TEST_dtw)

        M_TEST_euc = ExpEval.load_distance_matrix(ID, df, "TEST", "euc_z")
        I_TEST_ga_euc[i] = ExpEval.gammaindex(TEST_assignments, M_TEST_euc)

    end

    IndicesZ_df.TRAIN_ga_dtw = I_TRAIN_ga_dtw
    IndicesZ_df.TRAIN_ga_euc = I_TRAIN_ga_euc

    IndicesZ_df.TEST_ga_dtw = I_TEST_ga_dtw
    IndicesZ_df.TEST_ga_euc = I_TEST_ga_euc

    display(IndicesZ_df)

    CSV.write("IndicesZ_df.csv",IndicesZ_df)
end