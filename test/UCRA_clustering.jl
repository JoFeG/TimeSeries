## julia --threads 8
using Base.Threads
thr = nthreads()

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

Indices_df = dff[:,["ID","Name","Train","Test","Class","Length"]]

# Indices_df = CSV.read("ClusterIndices_df.csv", DataFrame)


R = 13 # Repetitions
alg = "kmed"

for set in ["TRAIN", "TEST"]
    for dist in ["euc","dtw","euc_z","dtw_z"]

        ms_suc_rate = zeros(length(IDs))
        di_suc_rate = zeros(length(IDs))
        ga_suc_rate = zeros(length(IDs))
        db_suc_rate = zeros(length(IDs))
        ch_suc_rate = zeros(length(IDs))
        
        
        for i = 1:length(IDs)
            ID = IDs[i]


            TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df)
            distance_matrix = ExpEval.load_distance_matrix(ID, df, set, dist)

            if set == "TRAIN"
                assignments_real = ExpEval.relabelLabels(TRAIN_labels)
                n = Indices_df.Train[i]
            elseif set == "TEST"
                assignments_real = ExpEval.relabelLabels(TEST_labels)
                n = Indices_df.Test[i]
            end


            K = floor(Int,sqrt(n)) # Max number of clusters


            VIs_to_real = zeros(R,K-1)
            ms = zeros(R,K-1)
            di = zeros(R,K-1)
            ga = zeros(K-1)
            db = zeros(R,K-1)
            ch = zeros(R,K-1)
            
            print("$i")
            for r = 1:R
                Threads.@threads for k = 2:K
                    res = Clustering.kmedoids(distance_matrix, k)  
                    VIs_to_real[r,k-1] = Clustering.varinfo(res.assignments, assignments_real)

                    sil = silhouettes(res.assignments, distance_matrix)
                    ms[r,k-1] = sum(sil) / length(sil)
                    
                    di[r,k-1] = ExpEval.dunnindex(res.assignments, distance_matrix)
                    if r==1
                        ga[k-1] = ExpEval.gammaindex2(res.assignments, distance_matrix)
                        print(".")
                    end
                    
                    db[r,k-1] = ExpEval.daviesbouldinindex(res.assignments, distance_matrix, medoids=res.medoids)
                    C_idx = ExpEval.bestMedoids(ones(Int, n), distance_matrix)[1]
                    ch[r,k-1] = ExpEval.calinskiharabaszindex(res.assignments, distance_matrix, medoids=res.medoids, c=C_idx)
                end
            end
            
            best_partition = argmin.(eachrow(VIs_to_real))
            ms_suc_rate[i] = sum(best_partition .== argmax.(eachrow(ms)))/R
            di_suc_rate[i] = sum(best_partition .== argmax.(eachrow(di)))/R
            ga_suc_rate[i] = Float64(best_partition[1] == argmax(ga))
            db_suc_rate[i] = sum(best_partition .== argmin.(eachrow(db)))/R
            ch_suc_rate[i] = sum(best_partition .== argmax.(eachrow(ch)))/R
            
            
            #println(Indices_df[i,:])
            #println("ID = $(IDs[i]), set = $set, dist = $dist, ms_suc_rate=$(ms_suc_rate[i])")

        end

        Indices_df[!, alg*"_ms_"*set*"_"*dist ] = ms_suc_rate
        Indices_df[!, alg*"_di_"*set*"_"*dist ] = di_suc_rate
        Indices_df[!, alg*"_ga_"*set*"_"*dist ] = ga_suc_rate
        Indices_df[!, alg*"_db_"*set*"_"*dist ] = db_suc_rate
        Indices_df[!, alg*"_ch_"*set*"_"*dist ] = ch_suc_rate
        
        println()
        println("set = $set, dist = $dist, alg = $alg:
            ms = $(round(sum(ms_suc_rate)/length(ms_suc_rate),digits=2)) 
            di = $(round(sum(di_suc_rate)/length(di_suc_rate),digits=2))
            ga = $(round(sum(ga_suc_rate)/length(ga_suc_rate),digits=2))
            db = $(round(sum(db_suc_rate)/length(db_suc_rate),digits=2)) 
            ch = $(round(sum(ch_suc_rate)/length(ch_suc_rate),digits=2))")        
    end
end



alg = "hclu"
for set in ["TRAIN", "TEST"]
    for dist in ["euc","dtw","euc_z","dtw_z"]

        ms_suc_rate = zeros(length(IDs))
        di_suc_rate = zeros(length(IDs))
        ga_suc_rate = zeros(length(IDs))
        db_suc_rate = zeros(length(IDs))
        ch_suc_rate = zeros(length(IDs))
        
        
        for i = 1:length(IDs)
            ID = IDs[i]


            TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df)
            distance_matrix = ExpEval.load_distance_matrix(ID, df, set, dist)

            if set == "TRAIN"
                assignments_real = ExpEval.relabelLabels(TRAIN_labels)
                n = Indices_df.Train[i]
            elseif set == "TEST"
                assignments_real = ExpEval.relabelLabels(TEST_labels)
                n = Indices_df.Test[i]
            end


            K = floor(Int,sqrt(n))


            VIs_to_real = zeros(K-1)
            ms = zeros(K-1)
            di = zeros(K-1)
            ga = zeros(K-1)
            db = zeros(K-1)
            ch = zeros(K-1)
            
            res = Clustering.hclust(distance_matrix, linkage=:ward) 
            
            print("$i")
            Threads.@threads for k = 2:K
                res_assignments = Clustering.cutree(res, k=k)
                VIs_to_real[k-1] = Clustering.varinfo(res_assignments, assignments_real)
                
                sil = silhouettes(res_assignments, distance_matrix)
                ms[k-1] = sum(sil) / length(sil)
                    
                di[k-1] = ExpEval.dunnindex(res_assignments, distance_matrix)
                ga[k-1] = ExpEval.gammaindex2(res_assignments, distance_matrix)
                print(".")
                
                res_medoids = ExpEval.bestMedoids(res_assignments, distance_matrix)
                db[k-1] = ExpEval.daviesbouldinindex(res_assignments, distance_matrix, medoids=res_medoids)
                C_idx = ExpEval.bestMedoids(ones(Int, n), distance_matrix)[1]
                ch[k-1] = ExpEval.calinskiharabaszindex(res_assignments, distance_matrix, medoids=res_medoids, c=C_idx)
            end
            
            
            display(VIs_to_real)
        
            
            best_partition = argmin(VIs_to_real)
            
            ms_suc_rate[i] = Float64(best_partition == argmax(ms))
            di_suc_rate[i] = Float64(best_partition == argmax(di))
            ga_suc_rate[i] = Float64(best_partition == argmax(ga))
            db_suc_rate[i] = Float64(best_partition == argmin(db))
            ch_suc_rate[i] = Float64(best_partition == argmax(ch))
            
            
            #println(Indices_df[i,:])
            #println("ID = $(IDs[i]), set = $set, dist = $dist, ms_suc_rate=$(ms_suc_rate[i])")

        end

        Indices_df[!, alg*"_ms_"*set*"_"*dist ] = ms_suc_rate
        Indices_df[!, alg*"_di_"*set*"_"*dist ] = di_suc_rate
        Indices_df[!, alg*"_ga_"*set*"_"*dist ] = ga_suc_rate
        Indices_df[!, alg*"_db_"*set*"_"*dist ] = db_suc_rate
        Indices_df[!, alg*"_ch_"*set*"_"*dist ] = ch_suc_rate
        
        println()
        println("set = $set, dist = $dist, alg = $alg:
            ms = $(round(sum(ms_suc_rate)/length(ms_suc_rate),digits=2)) 
            di = $(round(sum(di_suc_rate)/length(di_suc_rate),digits=2))
            ga = $(round(sum(ga_suc_rate)/length(ga_suc_rate),digits=2))
            db = $(round(sum(db_suc_rate)/length(db_suc_rate),digits=2)) 
            ch = $(round(sum(ch_suc_rate)/length(ch_suc_rate),digits=2))")     
        
    end
end

CSV.write("UCRA_clustering_indices.csv", Indices_df)