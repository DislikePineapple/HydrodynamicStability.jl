C1 = [
    0 0 -3/2 2 -1/2
    0 -1/3 -1/2 1 -1/6
    1/12 -2/3 0 2/3 -1/12
    1/6 -1 1/2 1/3 0
    1/2 -2 3/2 0 0
]

function central_difference(f, x)
    df = zeros(eltype(f), length(f))
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