###########################################################
#     Basic utils to interact with the DIMERC dataset     #
###########################################################

using JSON3

function LoadDataSet_DIMERC_json(
        path = "./data/dimerc/sales_2016-2021-level4.json"
    )
    
    str = read(path)
    json = JSON3.read(str);
    
    return json
end

function PrintDIMERCjsonPointExample(k,i)
    println("Serie k = $k, de $(length(json))")
    println("json[$k].name = $(json[k].name)")
    println("Largo = $(length(json[k].points))")
    println("json[$k].points[$i] = ")
    println(json[k].points[i])
end

function DIMERCjsonpoints2arrays(
        points::JSON3.Array,
        include_time=false
    )
    
    m = length(points)    
    
    x = [points[k].x for k in 1:m]
    y = [points[k].y for k in 1:m]
    
    if include_time           
        t = [points[k].date for k in 1:m]
        return x, y, t
    end
    
    return x, y
end

function DIMERCseriesjson2matrix(points::JSON3.Array)
    # Constructs a matrix Y of (m × n) with series in the columns and 0s replaced over gaps.
    
    n = length(json)
    series = []
    xs = []
    for k = 1:n
        x, y = DIMERCjsonpoints2arrays(json[k].points)

        series = [series..., y]
        xs = [xs..., x]
    end
    max_x = maximum(maximum.(xs))
    min_x = minimum(minimum.(xs))
    #println("min_x = ", min_x)
    #println("max_x = ", max_x)
    m = max_x - min_x + 1

    Y = zeros(m,n)

    for k = 1:n
        for i = 1:m
            #println("k=",k,", i=",i)
            data = series[k][xs[k] .== min_x+i-1]
            if length(data)>0
                Y[i,k] = data[1]
            else
                Y[i,k] = 0
            end
        end
    end    
    
    return Y
end
