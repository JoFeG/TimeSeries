function calculate_distance_matrix_euc(
        ID::Int, 
        DataSumary_df::DataFrame; 
        train::Bool = true,
        test::Bool = true,
        zscore::Bool = false
    )
    
    dataset = DataSumary_df[DataSumary_df.ID .== ID, :]
    
    TEST, TEST_labels, TRAIN, TRAIN_labels = LoadDataBase(ID, DataSumary_df)

    if train
        if zscore
            TRAIN = (TRAIN .- mean(TRAIN, dims=2)) ./ std(TRAIN, dims=2)
            out_path = "./UCRArchive_2018/" * dataset.Name[] * "/" * "TRAIN_dist_mat_euc_z.csv"
        else
            out_path = "./UCRArchive_2018/" * dataset.Name[] * "/" * "TRAIN_dist_mat_euc.csv"
        end
        
        TRAIN_dist_mat_euc = Distances.pairwise(Distances.Euclidean(), TRAIN, dims=1)
        
        writedlm(out_path,  TRAIN_dist_mat_euc, ',')
        println(out_path)
    end
    
    
    if test
        if zscore
            TEST = (TEST .- mean(TEST, dims=2)) ./ std(TEST, dims=2)
            out_path = "./UCRArchive_2018/" * dataset.Name[] * "/" * "TEST_dist_mat_euc_z.csv" 
        else
            out_path = "./UCRArchive_2018/" * dataset.Name[] * "/" * "TEST_dist_mat_euc.csv" 
        end            
            
        TEST_dist_mat_euc = Distances.pairwise(Distances.Euclidean(), TEST, dims=1)
        
        writedlm(out_path,  TEST_dist_mat_euc, ',')
        println(out_path)
    end
end

function load_distance_matrix(
        ID::Int,
        DataSumary_df::DataFrame,
        T::String,
        dist::String
    )
    
    dataset = DataSumary_df[DataSumary_df.ID .== ID, :]
    in_path = "./UCRArchive_2018/" * dataset.Name[] * "/" * T * "_dist_mat_" * dist * ".csv"
    
    isfile(in_path) || throw(ArgumentError("No matrix existing in path $in_path"))
    
    return readdlm(in_path, ',')

end

function calculate_distance_matrix_dtw(
        ID::Int, 
        DataSumary_df::DataFrame; 
        train::Bool = true,
        test::Bool = true,
        zscore::Bool = false
    )

    dataset = DataSumary_df[DataSumary_df.ID .== ID, :]
    
    TEST, TEST_labels, TRAIN, TRAIN_labels = LoadDataBase(ID, DataSumary_df)

    if train
        if zscore
            TRAIN = (TRAIN .- mean(TRAIN, dims=2)) ./ std(TRAIN, dims=2)
            out_path = "./UCRArchive_2018/" * dataset.Name[] * "/" * "TRAIN_dist_mat_dtw_z.csv" 
        else
            out_path = "./UCRArchive_2018/" * dataset.Name[] * "/" * "TRAIN_dist_mat_dtw.csv" 
        end
        
        n_TR = dataset.Train[]
        TRAIN_dist_mat_dtw = zeros(n_TR, n_TR)
        for i = 1:n_TR-1
            for j = i+1:n_TR
                TRAIN_dist_mat_dtw[i,j] = DynamicAxisWarping.dtw(TRAIN[i,:], TRAIN[j,:])[1]
                TRAIN_dist_mat_dtw[j,i] = TRAIN_dist_mat_dtw[i,j]
            end
        end
        
        writedlm(out_path,  TRAIN_dist_mat_dtw, ',')
        println(out_path)
    end
        
    if test
        if zscore
            TEST = (TEST .- mean(TEST, dims=2)) ./ std(TEST, dims=2)
            out_path = "./UCRArchive_2018/" * dataset.Name[] * "/" * "TEST_dist_mat_dtw_z.csv"
        else
            out_path = "./UCRArchive_2018/" * dataset.Name[] * "/" * "TEST_dist_mat_dtw.csv"
        end
        
        n_TE = dataset.Test[]
        TEST_dist_mat_dtw = zeros(n_TE, n_TE)
        for i = 1:n_TE-1
            for j = i+1:n_TE
                TEST_dist_mat_dtw[i,j] = DynamicAxisWarping.dtw(TEST[i,:], TEST[j,:])[1]
                TEST_dist_mat_dtw[j,i] = TEST_dist_mat_dtw[i,j]
            end
        end
 
        writedlm(out_path,  TEST_dist_mat_dtw, ',')
        println(out_path)
    end
end




function calculate_distance_matrix_dtwAB(
        X::Matrix{Float64},
        gamma::Int
    )
    
    n, m = size(X)
    
    X_dist_mat_dtwAB = zeros(n, n)
    for i = 1:n-1
        for j = i+1:n
            X_dist_mat_dtwAB[i,j] = dtw_arrow(X[i,:], X[j,:], γt=gamma)[1]
            X_dist_mat_dtwAB[j,i] = X_dist_mat_dtwAB[i,j]
        end
    end
        
    return X_dist_mat_dtwAB
end
