####################################################
#     Basic utils to interact with the archive     #
####################################################

function DownloadData()    
    path = "./UCRArchive_2018/"
    if isdir("path")
        println("./UCRArchive_2018 directory already exist")
    else
        archive_url = "https://www.cs.ucr.edu/~eamonn/time_series_data_2018/UCRArchive_2018.zip"
        cp(Downloads.download(archive_url), ".\UCRArchive_2018.zip")
        println("Unizip archive using pasword: \"someone\"")
        
    end
end
    
function LoadDataSumary()
    url="https://www.cs.ucr.edu/~eamonn/time_series_data_2018/DataSummary.csv"
    DataSumary, DataSumary_header = readdlm(Downloads.download(url), ',', header = true)
    # Original names "\ufeffID", "Train ", "Test " for some reason
    DataSumary_header[[1,4,5]] = ["ID", "Train", "Test"] 
    
    DataSumary_df = DataFrame(DataSumary, vec(DataSumary_header))
    
    return DataSumary_df
end

"""
    TEST, TEST_labels, TRAIN, TRAIN_labels = LoadDataBase(ID, DataSumary_df, [verbose=false])
   
Loads the series from the database specified by `ID` into the rows of the arrays 
`TEST` and `TRAIN`. The original data sumary dataframe can be loaded from www.cs.ucr.edu
via `DataSumary_df = LoadDataSumary()`. If nothig is provided it will be loaded 
from there.
"""
function LoadDataBase(
        ID::Int, 
        DataSumary_df::DataFrame, 
        verbose::Bool = false
    )
    
    path = "./UCRArchive_2018/"
    if !(ispath("./UCRArchive_2018/"))
        println("path='./UCRArchive_2018/' not found.") 
        println("Download and unzip data from:")
        println("https://www.cs.ucr.edu/~eamonn/time_series_data_2018/UCRArchive_2018.zip")    
    end
    
    dataset = DataSumary_df[DataSumary_df.ID .== ID, :]
    
    TE = readdlm(path * dataset.Name[] * "/" * dataset.Name[] * "_TEST.tsv",'\t')
    TEST_labels = Int.(TE[:,1])
    TEST = TE[:,2:end]

    TR = readdlm(path * dataset.Name[] * "/" * dataset.Name[] * "_TRAIN.tsv",'\t')
    TRAIN_labels = Int.(TR[:,1])
    TRAIN = TR[:,2:end]
    
    if verbose
        println("ID      : ", dataset.ID[])
        println("Name    : ", dataset.Name[])
        println("Length  : ", dataset.Length[])
        println("Train   : ", dataset.Train[])
        println("Test    : ", dataset.Test[])
        println("Classes : ", dataset.Class[])
        println("    Train Classes: ", sort(unique(TEST_labels)))
        println("    Test  Classes: ", sort(unique(TRAIN_labels)))
        println("------------------------------------------------------------------------")
    end
    
    return TEST, TEST_labels, TRAIN, TRAIN_labels
end

function LoadDataBase(
        ID::Int, 
        verbose::Bool = false
    )
    
    DataSumary_df = LoadDataSumary()

    return LoadDataBase(ID, DataSumary_df, verbose)
end

"""
    labels = relabelLabels(labels_old)
    
Takes a vector of `n` labels from `c` clases (works for ints and strings) 
and maps it bijectivelly to the new classes `1,2,...,c`.

Example: `[b,b,a,c,b] -> [2,2,1,3,2]`    
"""
function relabelLabels(labels_old)

    classes = sort(unique(labels_old))
    labels = Array{Int, 1}(undef, length(labels_old))
    
    for i = 1:length(labels_old)
        for j = 1:length(classes)
            if labels_old[i] == classes[j]
                labels[i] = j
            end
        end
    end
    return labels
end
