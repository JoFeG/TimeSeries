using DelimitedFiles

function LoadSeries_FREQ(path)
    data, header = readdlm(path, ',', header=true)
    
    records = [occursin("CL_",h) for h in header]
    M = size(data)[1]
    y_raw = zeros(M)
    for t = 1:M
        for k = 1:length(header)
            records[k] ? y_raw[t] += data[t,k] : nothing
        end
    end
    y_raw / sum(records)
    
    ## OBS y_raw == data[:,findfirst(i -> i == "CIO", header)[2]]
    return y_raw
end

function SamplerRaw_FREQ(path; Ts=0.3, event_time=30, f0=50)
    data, header = readdlm(path, ',', header=true)
    
    y_raw = data[:,findfirst(i -> i == "CIO", header)[2]]
    
    # WARNING: This assumes 0.02 sampling time in the raw file!
    delta_i = floor(Int, Ts / 0.02)
    start = data[:,findfirst(i -> i == "Inicio", header)[2]][1]
    
    index = start:delta_i:(start + floor(Int, event_time / 0.02))
#=
    println("
start      = $start
index[1]   = $(index[1])
delta_i    = $delta_i          
index[end] = $(index[end])
        ")
=#
    delta_freq = y_raw[index] .- f0
    P0 = data[:,findfirst(i -> i == "Potencia", header)[2]][1]
    time = Ts * (0:length(delta_freq)-1)
    
    return delta_freq, P0, time
end