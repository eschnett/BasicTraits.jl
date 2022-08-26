using BasicTraits
using Test

test_trait(Trait_Add{Int})
test_trait(Trait_Mul{Int})
test_trait(Trait_Number{Int})

test_trait(Trait_Mul{String})

test_trait(Trait_Vector{Vector{Int}})
