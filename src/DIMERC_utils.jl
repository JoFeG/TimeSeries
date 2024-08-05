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

function jsonpoints2arrays(
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

function PrintCIMERCjsonPointExample(k,i)
    println("Serie k = $k, de $(length(json))")
    println("json[$k].name = $(json[k].name)")
    println("Largo = $(length(json[k].points))")
    println("json[$k].points[$i] = ")
    println(json[k].points[i])
end