
function drawProgram(p::Program)
    simulator = SimpleQuantumExecutionEnvironment()
    result = runProgram(simulator, p)

    nq = getNumberQubits(p)
    steps = getSteps(p)
    ns = length(steps)

    ww = (ns + 5) * (BLOCK_PIXELS + GAP_PIXELS)
    hh = (nq + 2) * (BLOCK_PIXELS + GAP_PIXELS)
    rdr = Renderer(p, ww, hh)

    set_plot_area(rdr, GAP_PIXELS, ww - GAP_PIXELS, hh - GAP_PIXELS, GAP_PIXELS)
    set_plot_range(rdr, 0, ns + 2, 0, nq + 1)

    set_source_rgb(rdr.ctx, 0, 0, 0)
    set_font_size(rdr.ctx, 12)
    set_text_align(rdr, LeftAlign, CentreVer)
    for q = 1:nq
        set_source_rgb(rdr.ctx, 0, 0, 0)
        plottext(rdr, 0, q, "q[", q, "]|0>")
    end

    wires(rdr, nq, ns)

    set_text_align(rdr, CentreHor, CentreVer)
    for (s, step) in enumerate(steps)
        for gate in getGates(step)
            draw(rdr, s, ns, gate)
        end
    end

    qubits = getQubits(result)
    set_text_align(rdr, CentreHor, CentreVer)
    for (q, qubit) in enumerate(qubits)
        probBox(rdr, ns + 1, q, getProbability(qubit))
    end

    return RGB{N0f8}.(permutedims(rdr.img))
end

function wires(rdr::Renderer, numQubits, numSteps)
    set_source_rgb(rdr.ctx, 0.2, 0.2, 0.2)
    for q = 1:numQubits
        plotline(rdr, 1, q, numSteps + 1, q)
    end
end

function drawblock(rdr::Renderer, x, y, caption)
    set_font_size(rdr.ctx, 20)
    set_source_rgb(rdr.ctx, 0.1, 0.75, 0.9)
    plotrectangle(rdr, x - rdr.base_w / 2, y - rdr.base_h / 2, rdr.base_w, rdr.base_h, true)
    select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD)
    set_source_rgb(rdr.ctx, 1, 1, 1)
    plottext(rdr, x, y, caption)
    select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)
end

function draw(rdr::Renderer, step, num_steps, gate::Gate)
    drawblock(rdr, step, getMainQubitIndex(gate), getCaption(gate))
end

draw(::Renderer, step, ::Identity) = nothing

function draw(rdr::Renderer, step, num_steps, gate::Cnot)
    i1 = getMainQubitIndex(gate)
    i2 = getSecondQubitIndex(gate)
    set_source_rgb(rdr.ctx, 0.5, 0.5, 0.5)
    plotline(rdr, step, i1, step, i2)
    x, y = world_to_pixel(rdr, step, i1)
    drawcircle(rdr, x, y, 2.5, true)
    x, y = world_to_pixel(rdr, step, i2)
    drawcircle(rdr, x, y, 6)
end

function draw(rdr::Renderer, step, num_steps, gate::Cz)
    i1 = getMainQubitIndex(gate)
    i2 = getSecondQubitIndex(gate)
    set_source_rgb(rdr.ctx, 0.5, 0.5, 0.5)
    plotline(rdr, step, i1, step, i2)
    x, y = world_to_pixel(rdr, step, i1)
    drawcircle(rdr, x, y, 2.5, true)
    drawblock(rdr, step, i2, "Z")
end

function draw(rdr::Renderer, step, num_steps, gate::Measurement)
    set_source_rgb(rdr.ctx, 0.5, 0.5, 0.5)
    q = getMainQubitIndex(gate) + rdr.base_h / 4
    plotline(rdr, step, q, num_steps + 1, q)
    drawblock(rdr, step, getMainQubitIndex(gate), getCaption(gate))
end

# TODO:
#function draw(rdr::Renderer, step, num_steps, gate::Toffoli)
#function draw(rdr::Renderer, step, num_steps, gate::AbstractBlockGate)
#function draw(rdr::Renderer, step, num_steps, gate::Oracle)

function probBox(rdr::Renderer, x, y, prob)
    set_font_size(rdr.ctx, 11)
    select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD)

    set_source_rgb(rdr.ctx, 0.75, 0.75, 0.75)
    plotrectangle(rdr, x - rdr.base_w / 2, y - rdr.base_h / 2, rdr.base_w, rdr.base_h, true)
    pct = prob * 100
    if pct ≥ 1
        set_source_rgb(rdr.ctx, 0.5, 0.5, 0.5)
        h = rdr.base_h * prob
        plotrectangle(rdr, x - rdr.base_w / 2, y + rdr.base_h / 2, rdr.base_w, -h, true)
    end
    set_source_rgb(rdr.ctx, 1, 1, 1)
    if pct < 1
        lbl = "Off"
    elseif pct > 99
        lbl = "On"
    else
        lbl = string(round(pct, digits = 2), "%")
    end
    plottext(rdr, x, y, lbl)
    select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)
end
