C1 = [
    0 0 -3/2 2 -1/2
    0 -1/3 -1/2 1 -1/6
    1/12 -2/3 0 2/3 -1/12
    1/6 -1 1/2 1/3 0
    1/2 -2 3/2 0 0
]

C2 = [
    1 -2 1 0 0
    1 -2 1 0 0
    -1/12 16/12 -30/12 16/12 -1/12
    0 0 1 -2 1
    0 0 1 -2 1
]

function central_difference(f, x; accurency = 2)
    df = zeros(eltype(f), length(f))
    if accurency == 2
        df[1] = (f[2] - f[1]) / (x[2] - x[1])
        for j = 2:length(f)-1
            df[j] = (f[j+1] - f[j-1]) / (x[j+1] - x[j-1])
        end
        df[end] = (f[end] - f[end-1]) / (x[end] - x[end-1])
        return df
    elseif accurency == 4
        df[1] = (C1[1, 3] * f[1] + C1[1, 4] * f[2] + C1[1, 5] * f[3]) / (x[2] - x[1])
        df[2] =
            (C1[2, 2] * f[1] + C1[2, 3] * f[2] + C1[2, 4] * f[3] + C1[2, 5] * f[4]) /
            (x[3] - x[1]) * 2
        for j = 3:length(f)-2
            df[j] =
                (
                    C1[3, 1] * f[j-2] +
                    C1[3, 2] * f[j-1] +
                    C1[3, 3] * f[j] +
                    C1[3, 4] * f[j+1] +
                    C1[3, 5] * f[j+2]
                ) / (x[j+1] - x[j-1]) * 2
        end
        df[end-1] =
            (
                C1[4, 1] * f[end-3] +
                C1[4, 2] * f[end-2] +
                C1[4, 3] * f[end-1] +
                C1[4, 4] * f[end]
            ) / (x[end] - x[end-2]) * 2
        df[end] =
            (C1[5, 1] * f[end-2] + C1[5, 2] * f[end-1] + C1[5, 3] * f[end]) /
            (x[end] - x[end-1])
        return df
    end
end

function simpsons_integral(df, x; f0 = 0, accurency = 1)
    f = zeros(typeof(df[1]), length(df))
    if accurency == 1
        for i in eachindex(x)
            i == 1 && (f[i] = f0; continue)
            f[i] = f[i-1] + (df[i] + df[i-1]) / 2 * (x[i] - x[i-1])
        end
        return f
    elseif accurency == 3
        for i in eachindex(x)
            i == 1 && (f[i] = f0; continue)
            if isodd(i)
                f[i] = f[i-2] + (df[i] + 4 * df[i-1] + df[i-2]) / 6 * (x[i] - x[i-2])
            else
                f[i] = f[i-1] + (df[i] + df[i-1]) / 2 * (x[i] - x[i-1])
            end
        end
        return f
    end
end

function fft_expand(f::AbstractArray{ComplexF64}, Nz::Int; atol = 1e-3)
    # must pass values instead of reference
    nz = Int((length(f) - 1))
    F = zeros(ComplexF64, Nz)
    maximum(abs.(f)) == 0 && return F
    f[1:nz] = fft(f[1:nz])
    # Delate high frequency component
    max = maximum(abs.(f[Int(Nz / 2 + 1):nz-Int(Nz / 2)]) / maximum(abs.(f)))
    if isapprox(max, 0, atol = atol)
        F[1:Int(Nz / 2)] = f[1:Int(Nz / 2)] ./ nz .* Nz
        F[end-Int(Nz / 2 - 1):end] = f[nz-Int(Nz / 2 - 1):nz] ./ nz .* Nz
    else
        error("High frequency component not tend to zero! The maximum rtol is $max.")
    end
    return F
end

function ifft_expand(F::AbstractArray, nz::Int)
    Nz = length(F)
    # Add high frequency component as zero
    f = zeros(ComplexF64, nz)
    f[1:Int(Nz / 2)] = F[1:Int(Nz / 2)] ./ Nz .* (nz - 1)
    f[nz-1-Int(Nz / 2 - 2):nz-1] = F[end-Int(Nz / 2 - 2):end] ./ Nz .* (nz - 1)
    # Fourier inverse transform for flow field
    f[1:nz-1] = real(ifft(f[1:nz-1]))
    f[nz] = f[1]
    isapprox(maximum(imag.(f)), 0, atol = 1e-9) || error("The imaginary part is not zero!")
    return real.(f)
end
