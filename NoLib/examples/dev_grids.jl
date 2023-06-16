using NoLib


g1 = NoLib.CGrid( ((0.0, 1.0, 11),) )
g2 = NoLib.CGrid( ((0.0, 1.0, 11), (100.0, 200.0, 3)) )
g3 = NoLib.CGrid( ((0.0, 1.0, 11), (100.0, 200.0, 3), (-1.0, 1.0, 3)) )

[g1...]

[g2...]
[g3...]


@time sum( g1 );
@time sum( g2 )

@time sum( g3 )

[g3...]