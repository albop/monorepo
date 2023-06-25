using NoLib
const NL = NoLib

using NoLib: QP, CartesianSpace, GridSpace, ProductSpace, draw, ×
using StaticArrays
using NoLib.build


csp = CSpace(;
    z=(-1,1),
    k=(0,10),
)

NoLib.draw(csp)


QP(csp; z=0.3, k=0.1)

gsp = GSpace((:w,:r),
    SVector(
        SVector(0.1, 0.1),
        SVector(-0.1, 0.2)
    )
)

NoLib.draw(gsp)


QP(gsp; i_=1)


ps = gsp × csp

QP(ps; z=3, k=0.3)
