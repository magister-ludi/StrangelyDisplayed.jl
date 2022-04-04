module StrangelyDisplayed

using Cairo
using ImageCore
using StrangelyQuantum

export drawProgram, drawTrialHistogram, drawHistogram

include("renderer.jl")
include("diagram.jl")
include("trial.jl")

end # module StrangelyDisplayed
