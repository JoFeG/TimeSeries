## julia --threads 4
using Base.Threads
thr = nthreads()

println("working with $thr threads")

thr > 15  || throw(Error("\n\nAdd more threads:\n\$ export JULIA_NUM_THREADS=16\n\$ julia\n"))

include("../src/ExpEval.jl")






# TRAIN AND TEST euc
if true
    df = ExpEval.LoadDataSumary()
    dff = df[isa.(df.Length,Number), :] 
    IDs = dff.ID
    
    Threads.@threads for ID in IDs
        ExpEval.calculate_distance_matrix_euc(ID, df, train=false, test=true)
        println("------------------------------------------ $ID euc done")
    end
end



# Just for TEST dtw
if false
    df = ExpEval.LoadDataSumary()
    dff = df[isa.(df.Length,Number), :] 
    nm_cap = 1000
    
    dff = dff[
        (dff.Length .< nm_cap) .&
        (dff.Test .< nm_cap), :]

    IDs = dff.ID
    Threads.@threads for ID in IDs
        ExpEval.calculate_distance_matrix_dtw(ID, df, train=false, test=true)
        println("------------------------------------------ $ID dtw test done")
    end
end
