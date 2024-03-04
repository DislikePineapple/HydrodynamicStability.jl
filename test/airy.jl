using HydrodynamicStability, Test, SpecialFunctions

"""
    Airy_fun!(M, B, p, t)
    solve the Airy equation
    u'' - t * u = 0,
    which can be write as the first order ODE system
    u' = v
    v' = t * u,
    with the boundary condition
    u(0) = Ai(0)
    u(10) = Ai(10),
    where Ai(x) is the Airy function of the first kind.
"""

function Airy_fun!(M, B, p, t)
    M[1, 2] = 1
    M[2, 1] = t

    B[1] = 0
    B[2] = 0
end

function Airy_bc!(M0, Mend, u)
    M0[1, :] .= 0
    M0[1, 1] = 1
    Mend[1, :] .= 0
    Mend[1, end-1] = 1

    u[1] = airyai(0)
    u[end-1] = airyai(10)
end

y = 0:0.01:10
u₀ = [0.0, 0.0]
prob = BVProblem(Airy_fun!, Airy_bc!, u₀, y)
sol = solve(prob, FDM())

@test isapprox(sol.u[1][2], airyaiprime(0), atol = 1e-5)
