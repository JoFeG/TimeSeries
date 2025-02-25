function dtw_arrow(x, y; γt=1)
    I = length(x)
    J = length(y)
    
    δm = [isnan(x[i]-y[j]) ? 0 : (x[i]-y[j])^2 for i=1:I, j=1:J]
    
    C = Inf * ones(I+1, J+1)
    C[1,1] = 0
    
    φm = zeros(Int, I+1, J+1)
    φm[2:I+1,1] .= 2
    φm[1,2:J+1] .= 3
    
    
    for i = 2:I+1
        for j = 2:J+1
            if i>2
                ev = any(isnan.([x[i-1], x[i-2], y[j-1]])) ? Inf : 0
            else
                ev = Inf
            end
            if j>2
                eh = any(isnan.([x[i-1], y[j-1], y[j-2]])) ? Inf : 0
            else
                eh = Inf
            end
            
            C[i,j] = δm[i-1,j-1] + min([
                C[i-1, j-1]    
                C[i-1, j] + ev
                C[i, j-1] + eh               
            ]...)
            φm[i,j] = argmin([
                    C[i-1, j-1]
                    C[i-1, j] + ev
                    C[i, j-1] + eh
                    ])
        end
    end    
    
    i = I
    j = J
    πi = [i]
    πj = [j]
    
    kf = 0
    while i>1 || j>1
        if φm[i+1,j+1] == 1
            i = i - 1
            j = j - 1
            if isnan(x[i])||isnan(y[j])
                kf = kf+1
            end
        elseif φm[i+1,j+1] == 2
            i = i - 1
        elseif φm[i+1,j+1] == 3
            j = j - 1
        else
            break
        end        
        append!(πi, max(i,1))
        append!(πj, max(j,1))
    end
    
    Iav = length(filter(!isnan, x))
    Jav = length(filter(!isnan, y))
    
    if γt == 0
        γ = 1
    elseif γt == 1
        γ = (I + J) / (Iav + Jav)
    elseif γt == 2
        γ = (I + J) / (I + J - kf)
    end

    
    return (γ*C[I+1,J+1], reverse!(πi), reverse!(πj))
end