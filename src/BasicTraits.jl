module BasicTraits

using Test

################################################################################

export AbstractTrait
abstract type AbstractTrait{T} end

Base.getindex(obj::AbstractTrait) = obj.val
Base.convert(::Type{T}, obj::AbstractTrait{T}) where {T} = obj[]

export hastrait
hastrait(::Type, ::Type{<:AbstractTrait}) = false

export test_trait

################################################################################

implies(x, y) = !x || y
const ⟹ = implies

################################################################################

export Trait_Add
struct Trait_Add{T} <: AbstractTrait{T}
    val::T
    function Trait_Add(val::T) where {T}
        @assert hastrait(T, Trait_Add)
        return new{T}(val)
    end
end

Base.iszero(x::Trait_Add{T}) where {T} = x == zero(Trait_Add{T})
Base.:+(x::Trait_Add{T}) where {T} = x
Base.:-(x::Trait_Add{T}, y::Trait_Add{T}) where {T} = x + -y

function test_trait(::Type{Trait_Add{T}}) where {T}
    @test hastrait(T, Trait_Add)
    n = zero(Trait_Add{T})::Trait_Add{T}
    x = rand(Trait_Add{T})::Trait_Add{T}
    y = rand(Trait_Add{T})::Trait_Add{T}
    z = rand(Trait_Add{T})::Trait_Add{T}
    @test n == n
    @test x == x
    @test (x == n) ⟹ (x == x + x)
    @test iszero(n)
    @test (x == n) == iszero(x)
    @test x + n == x            # neutral element
    @test n + x == x
    @test +x == x
    @test (x + y) + z == x + (y + z) # associative
    @test x + y == y + x             # commutative
    @test -x == n - x                # inverse
    @test x - y == x + -y
    return nothing
end

################################################################################

hastrait(::Type{Int}, ::Type{<:Trait_Add}) = true
Base.:(==)(x::Trait_Add{Int}, y::Trait_Add{Int}) = x[] == y[]
Base.rand(::Type{Trait_Add{Int}}) = Trait_Add(rand(-100:+100))
Base.zero(::Type{Trait_Add{Int}}) = Trait_Add(zero(Int))
Base.:+(x::Trait_Add{Int}, y::Trait_Add{Int}) = Trait_Add(x[] + y[])
Base.:-(x::Trait_Add{Int}) = Trait_Add(-x[])

################################################################################

export Trait_Mul
struct Trait_Mul{T} <: AbstractTrait{T}
    val::T
    function Trait_Mul(val::T) where {T}
        @assert hastrait(T, Trait_Mul)
        return new{T}(val)
    end
end

Base.isone(x::Trait_Mul{T}) where {T} = x == one(Trait_Mul{T})

function test_trait(::Type{Trait_Mul{T}}) where {T}
    @test hastrait(T, Trait_Mul)
    e = one(Trait_Mul{T})::Trait_Mul{T}
    x = rand(Trait_Mul{T})::Trait_Mul{T}
    y = rand(Trait_Mul{T})::Trait_Mul{T}
    z = rand(Trait_Mul{T})::Trait_Mul{T}
    @test e == e
    @test x == x
    @test (x == e) ⟹ (x == x * x)
    @test isone(e)
    @test (x == e) == isone(x)
    @test x * e == x            # neutral element
    @test e * x == x
    @test (x * y) * z == x * (y * z) # associative
    return nothing
end

################################################################################

hastrait(::Type{Int}, ::Type{<:Trait_Mul}) = true
Base.:(==)(x::Trait_Mul{Int}, y::Trait_Mul{Int}) = x[] == y[]
Base.rand(::Type{Trait_Mul{Int}}) = Trait_Mul(rand(-100:+100))
Base.one(::Type{Trait_Mul{Int}}) = Trait_Mul(one(Int))
Base.:*(x::Trait_Mul{Int}, y::Trait_Mul{Int}) = Trait_Mul(x[] * y[])

hastrait(::Type{String}, ::Type{<:Trait_Mul}) = true
Base.:(==)(x::Trait_Mul{String}, y::Trait_Mul{String}) = x[] == y[]
Base.rand(::Type{Trait_Mul{String}}) = Trait_Mul(String(rand('a':'z', rand(0:10))))
Base.one(::Type{Trait_Mul{String}}) = Trait_Mul(one(String))
Base.isone(x::Trait_Mul{String}) = isone(x[])
Base.:*(x::Trait_Mul{String}, y::Trait_Mul{String}) = Trait_Mul(x[] * y[])

################################################################################

export Trait_Number
struct Trait_Number{T} <: AbstractTrait{T}
    val::T
    function Trait_Number(val::T) where {T}
        @assert hastrait(T, Trait_Number)
        return new{T}(val)
    end
end

Trait_Add(x::Trait_Number) = Trait_Add(x[])
Trait_Mul(x::Trait_Number) = Trait_Mul(x[])

Base.:(==)(x::Trait_Number{T}, y::Trait_Number{T}) where {T} = Trait_Add(x) == Trait_Add(y)
Base.rand(::Type{Trait_Number{T}}) where {T} = Trait_Number(rand(Trait_Add{T})[])

Base.zero(::Type{Trait_Number{T}}) where {T} = Trait_Number(zero(Trait_Add{T})[])
Base.iszero(x::Trait_Number{T}) where {T} = iszero(Trait_Add(x))
Base.:+(x::Trait_Number{T}) where {T} = Trait_Number((+Trait_Add(x))[])
Base.:+(x::Trait_Number{T}, y::Trait_Number{T}) where {T} = Trait_Number((Trait_Add(x) + Trait_Add(y))[])

Base.one(::Type{Trait_Mul{T}}) where {T} = Trait_Number(one(Trait_Mul{T})[])
Base.isone(x::Trait_Number{T}) where {T} = isone(Trait_Mul(x))
Base.:*(x::Trait_Number{T}, y::Trait_Number{T}) where {T} = Trait_Number((Trait_Mul(x) * Trait_Mul(y))[])

function test_trait(::Type{Trait_Number{T}}) where {T}
    @test hastrait(T, Trait_Number)
    test_trait(Trait_Add{T})
    test_trait(Trait_Mul{T})

    n = zero(Trait_Number{T})::Trait_Number{T}
    x = rand(Trait_Number{T})::Trait_Number{T}
    y = rand(Trait_Number{T})::Trait_Number{T}
    z = rand(Trait_Number{T})::Trait_Number{T}

    @test n * x == n                   # zero cancels
    @test x * n == n
    @test (x + y) * z == x * z + y * z # left distributive

    return nothing
end

################################################################################

hastrait(::Type{Int}, ::Type{<:Trait_Number}) = true

################################################################################

# TODO: Traits for constructors (higher order traits)
export Trait_Vector
struct Trait_Vector{T} <: AbstractTrait{T}
    val::T
    function Trait_Vector(val::T) where {T}
        @assert hastrait(T, Trait_Add)
        @assert hastrait(T, Trait_Vector)
        return new{T}(val)
    end
end

Trait_Add(x::Trait_Vector) = Trait_Add(x[])

Base.:(==)(x::Trait_Vector{T}, y::Trait_Vector{T}) where {T} = Trait_Add(x) == Trait_Add(y)
Base.rand(::Type{Trait_Vector{T}}) where {T} = Trait_Vector(rand(Trait_Add{T})[])

Base.zero(::Type{Trait_Vector{T}}) where {T} = Trait_Vector(zero(Trait_Add{T})[])
Base.iszero(x::Trait_Vector{T}) where {T} = iszero(Trait_Add(x))
Base.:+(x::Trait_Vector{T}) where {T} = Trait_Vector((+Trait_Add(x))[])
Base.:+(x::Trait_Vector{T}, y::Trait_Vector{T}) where {T} = Trait_Vector((Trait_Add(x) + Trait_Add(y))[])
Base.:-(x::Trait_Vector{T}) where {T} = Trait_Vector((-Trait_Add(x))[])
Base.:-(x::Trait_Vector{T}, y::Trait_Vector{T}) where {T} = Trait_Vector((Trait_Add(x) - Trait_Add(y))[])

function test_trait(::Type{Trait_Vector{T}}) where {T}
    @test hastrait(T, Trait_Vector)
    test_trait(Trait_Add{T})

    n = zero(Trait_Vector{T})::Trait_Vector{T}
    x = rand(Trait_Vector{T})::Trait_Vector{T}
    y = rand(Trait_Vector{T})::Trait_Vector{T}

    S = eltype(T)::Type
    @test hastrait(S, Trait_Number)

    z = zero(Trait_Number{S})
    a = rand(Trait_Number{S})
    b = rand(Trait_Number{S})

    @test z * x == n
    @test (a * b) * x == a * (b * x)
    @test (a + b) * x == a * x + b * x
    @test a * (x + y) == a * x + a * y

    return nothing
end

################################################################################

hastrait(::Type{Vector{S}}, ::Type{<:Trait_Add}) where {S} = hastrait(S, Trait_Add)
function Base.:(==)(x::Trait_Add{Vector{S}}, y::Trait_Add{Vector{S}}) where {S}
    return mapreduce((x, y) -> Trait_Add(x) == Trait_Add(y), &, x[], y[])
end
Base.rand(::Type{Trait_Add{Vector{S}}}) where {S} = Trait_Add(S[rand(Trait_Add{S})[] for i in 1:10])
Base.zero(::Type{Trait_Add{Vector{S}}}) where {S} = Trait_Add(zeros(S, 10))
Base.iszero(x::Trait_Add{Vector{S}}) where {S} = iszero(x[])
Base.:+(x::Trait_Add{Vector{S}}) where {S} = Trait_Add(+x[])
Base.:+(x::Trait_Add{Vector{S}}, y::Trait_Add{Vector{S}}) where {S} = Trait_Add(x[] + y[])
Base.:-(x::Trait_Add{Vector{S}}) where {S} = Trait_Add(-x[])
Base.:-(x::Trait_Add{Vector{S}}, y::Trait_Add{Vector{S}}) where {S} = Trait_Add(x[] - y[])

hastrait(::Type{Vector{S}}, ::Type{<:Trait_Vector}) where {S} = hastrait(S, Trait_Number)
Base.eltype(::Type{Trait_Vector{Vector{S}}}) where {S} = S
Base.:*(a::Trait_Number{S}, x::Trait_Vector{Vector{S}}) where {S} = Trait_Vector(S[(a * Trait_Number(x))[] for x in x[]])

end
