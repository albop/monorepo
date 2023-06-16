using Documenter
using NoLib

makedocs(
    sitename = "NoLib",
    format = Documenter.HTML(),
    modules = [NoLib]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
