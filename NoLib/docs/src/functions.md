# Spaces, grids and functions

## Spaces

```@example
import NoLib
NoLib.CartesianSpace(;
    x=[-Inf, Inf],
    y=[0, Inf]
)
```

```@example space
import NoLib
space = NoLib.CartesianSpace(;
    x=[0, 10]
)
```


## Grids

```@example space
grid = NoLib.discretize(space)
```

## GVector

```example space
v = GVector(grid, [e.^2 for e in grid])
```


## Functions