using Turing
using Optim
using Test
using StatsBase
using NamedArrays
using ReverseDiff
using Random
using LinearAlgebra
using Zygote

dir = splitdir(splitdir(pathof(Turing))[1])[1]
include(dir*"/test/test_utils/AllUtils.jl")

@testset "ModeEstimation.jl" begin
    @testset "MLE" begin
        Random.seed!(222)
        true_value = [0.0625, 1.75]
        true_value_named = (s=true_value[1],m=true_value[2])

        m1 = optimize(gdemo_default, MLE())
        m2 = optimize(gdemo_default, MLE(), NelderMead())
        m3 = optimize(gdemo_default, MLE(), true_value, LBFGS())
        m4 = optimize(gdemo_default, MLE(), true_value)

        p5 = instantiate_optimisation_problem(gdemo_default, MLE(), unconstrained())
        m5 = optimize(p5.obj, p5.init(true_value), NelderMead())
        m6 = optimize(p5.obj, p5.obj, p5.init(true_value), LBFGS())
        m7 = optimize(p5.obj, p5.obj, p5.init(true_value_named), LBFGS())


        @test all(isapprox.(m1.values.array - true_value, 0.0, atol=0.01))
        @test all(isapprox.(m2.values.array - true_value, 0.0, atol=0.01))
        @test all(isapprox.(m3.values.array - true_value, 0.0, atol=0.01))
        @test all(isapprox.(m4.values.array - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p5.transform(m5.minimizer) - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p5.transform(m6.minimizer) - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p5.transform(m7.minimizer) - true_value, 0.0, atol=0.01))
    end

    @testset "MAP" begin
        Random.seed!(222)
        true_value = [49 / 54, 7 / 6]
        true_value_named = (s=true_value[1],m=true_value[2])

        m1 = optimize(gdemo_default, MAP())
        m2 = optimize(gdemo_default, MAP(), NelderMead())
        m3 = optimize(gdemo_default, MAP(), true_value, LBFGS())
        m4 = optimize(gdemo_default, MAP(), true_value)

        p5 = instantiate_optimisation_problem(gdemo_default, MAP(), unconstrained())
        m5 = optimize(p5.obj, p5.init(true_value), NelderMead())
        m6 = optimize(p5.obj, p5.obj, p5.init(true_value), LBFGS())
        m7 = optimize(p5.obj, p5.obj, p5.init(true_value_named), LBFGS())
        
        @test all(isapprox.(m1.values.array - true_value, 0.0, atol=0.01))
        @test all(isapprox.(m2.values.array - true_value, 0.0, atol=0.01))
        @test all(isapprox.(m3.values.array - true_value, 0.0, atol=0.01))
        @test all(isapprox.(m4.values.array - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p5.transform(m5.minimizer) - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p5.transform(m6.minimizer) - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p5.transform(m7.minimizer) - true_value, 0.0, atol=0.01))
    end

    @testset "MLE constrained" begin
        Random.seed!(222)
        true_value = [0.0625, 1.75]
        true_value_named = (s=true_value[1],m=true_value[2])
        lb = [0.0, 0.0]
        ub = [2.0, 2.0]

        p1 = instantiate_optimisation_problem(gdemo_default, MLE(), constrained())
        m1 = optimize(p1.obj, p1.obj, lb, ub, p1.init(true_value), Fminbox(LBFGS()))
        m2 = optimize(p1.obj, p1.obj, lb, ub, p1.init(true_value_named), Fminbox(LBFGS()))
        m3 = optimize(p1.obj, p1.obj, lb, ub, p1.init(true_value), Fminbox(BFGS()))
        m4 = optimize(p1.obj, p1.obj, lb, ub, p1.init(true_value_named), Fminbox(BFGS()))

        @test all(isapprox.(p1.transform(m1.minimizer) - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p1.transform(m2.minimizer) - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p1.transform(m3.minimizer) - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p1.transform(m4.minimizer) - true_value, 0.0, atol=0.01))
    end

    @testset "MAP constrained" begin
        Random.seed!(222)
        true_value = [49 / 54, 7 / 6]
        true_value_named = (s=true_value[1],m=true_value[2])
        lb = [0.0, 0.0]
        ub = [2.0, 2.0]

        p1 = instantiate_optimisation_problem(gdemo_default, MAP(), constrained())
        m1 = optimize(p1.obj, p1.obj, lb, ub, p1.init(true_value), Fminbox(LBFGS()))
        m2 = optimize(p1.obj, p1.obj, lb, ub, p1.init(true_value_named), Fminbox(LBFGS()))
        m3 = optimize(p1.obj, p1.obj, lb, ub, p1.init(true_value), Fminbox(BFGS()))
        m4 = optimize(p1.obj, p1.obj, lb, ub, p1.init(true_value_named), Fminbox(BFGS()))

        @test all(isapprox.(p1.transform(m1.minimizer) - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p1.transform(m2.minimizer) - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p1.transform(m3.minimizer) - true_value, 0.0, atol=0.01))
        @test all(isapprox.(p1.transform(m4.minimizer) - true_value, 0.0, atol=0.01))
    end
    

    @testset "StatsBase integration" begin
        Random.seed!(54321)
        mle_est = optimize(gdemo_default, MLE())

        @test coefnames(mle_est) == [:s, :m]

        diffs = coef(mle_est).array - [0.0625031; 1.75001]
        @test all(isapprox.(diffs, 0.0, atol=0.1))

        infomat = [0.003907027690416608 4.157954948417027e-7; 4.157954948417027e-7 0.03125155528962335]
        @test all(isapprox.(infomat - informationmatrix(mle_est), 0.0, atol=0.01))

        ctable = coeftable(mle_est)
        @test ctable isa StatsBase.CoefTable

        s = stderror(mle_est).array
        @test all(isapprox.(s - [0.06250415643292194, 0.17677963626053916], 0.0, atol=0.01))

        @test coefnames(mle_est) == params(mle_est)
        @test vcov(mle_est) == informationmatrix(mle_est)

        @test isapprox(loglikelihood(mle_est), -0.0652883561466624, atol=0.01)
    end

    @testset "Linear regression test" begin
        @model function regtest(x, y)
            beta ~ MvNormal(2,1)
            mu = x*beta
            y ~ MvNormal(mu, 1.0)
        end
        
        Random.seed!(987)
        true_beta = [1.0, -2.2]
        x = rand(40, 2)
        y = x*true_beta
        
        model = regtest(x, y)
        mle = optimize(model, MLE())
        
        vcmat = inv(x'x)
        vcmat_mle = informationmatrix(mle).array
        
        @test isapprox(mle.values.array, true_beta)
        @test isapprox(vcmat, vcmat_mle)
    end

    @testset "Dot tilde test" begin
        @model function dot_gdemo(x)
            s ~ InverseGamma(2,3)
            m ~ Normal(0, sqrt(s))
        
            (.~)(x, Normal(m, sqrt(s)))
        end
        
        model_dot = dot_gdemo([1.5, 2.0])

        mle1 = optimize(gdemo_default, MLE())
        mle2 = optimize(model_dot, MLE())

        map1 = optimize(gdemo_default, MAP())
        map2 = optimize(model_dot, MAP())

        @test isapprox(mle1.values.array, mle2.values.array)
        @test isapprox(map1.values.array, map2.values.array)
    end
end
