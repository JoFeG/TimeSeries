using DelimitedFiles

function LoadSeries_FREQ(path)
    println(path)
    data, header = readdlm(path, ',', header=true)
    display(header)
    display(data)
    
    records = [occursin("CL_",h) for h in header]
    M = size(data)[1]
    y_raw = zeros(M)
    for t = 1:M
        for k = 1:length(header)
            records[k] ? y_raw[t] += data[t,k] : nothing
        end
    end
    y_raw / sum(records)
    return y_raw
end