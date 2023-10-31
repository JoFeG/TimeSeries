module ExpEval
    
    using DelimitedFiles
    using DataFrames
    using Distances
    using Downloads
    using DynamicAxisWarping
    # using ZipFile


    
    export LoadDataSumary,
           LoadDataBase,
           calculate_distance_matrix_euc#,
           # calculate_distance_matrices_dtw
    
    include("UCR_archive_utils.jl")
    include("DTW_arrow.jl")
    include("distance_matrices.jl")

end
