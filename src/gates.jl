
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

function draw(rdr::Renderer, step, num_steps, gate::ProbabilitiesGate)
    #println("Prob for step ", step);
    result = getResult(rdr.p)
    ip = getIntermediateProbability(result, step)
    if ip === nothing
        error("Can not retrieve probabilities for step ", step)
    end
    nq = getNumberQubits(rdr.p)
    nn = 1 << nq

    offsetY = 1 - rdr.base_h / 2
    deltaY = (nq - 1 + rdr.base_h) / nn
    #println("n = ", nq, " and N = ", nn, ", dY = ", deltaY)

    for i = 1:nn
        startY = (i - 1) * deltaY + offsetY
        set_source_rgb(rdr.ctx, 1, 1, 1)
        plotrectangle(rdr, step - rdr.base_w / 2, startY, rdr.base_w, deltaY, true)
        prob = abs2(ip[i])
        if prob > 0.01
            set_source_rgb(rdr.ctx, 0, 0.65, 0)
            plotrectangle(rdr, step - rdr.base_w / 2, startY, prob * rdr.base_w, deltaY, true)
        end
        set_source_rgb(rdr.ctx, 0.7, 0.7, 0.7)
        plotrectangle(rdr, step - rdr.base_w / 2, startY, rdr.base_w, deltaY)
    end
end

function draw(rdr::Renderer, step, num_steps, gate::Toffoli)
    i1, i2, i3 = gate.first, gate.second, gate.third
    set_source_rgb(rdr.ctx, 0.5, 0.5, 0.5)
    plotline(rdr, step, i1, step, i3)
    plotline(rdr, step, i2, step, i3)
    x, y = world_to_pixel(rdr, step, i1)
    drawcircle(rdr, x, y, 2.5, true)
    x, y = world_to_pixel(rdr, step, i2)
    drawcircle(rdr, x, y, 2.5, true)
    x, y = world_to_pixel(rdr, step, i3)
    drawcircle(rdr, x, y, 6)
end

function draw(rdr::Renderer, step, num_steps, gate::Oracle)
    i = getMainQubitIndex(gate)
    ii = getAffectedQubitIndexes(gate)
    mn, mx = extrema(ii)
    set_source_rgba(rdr.ctx, 0.35, 0.35, 1, 0.9)
    plotrectangle(rdr, step - rdr.base_w / 2, i - rdr.base_h / 2, rdr.base_w, rdr.base_h, true)
    select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD)
    set_source_rgb(rdr.ctx, 1, 1, 1)
    label = getCaption(gate)
    if textextent(rdr, label).width > BLOCK_PIXELS
        label = "..."
    end
    plottext(rdr, step, i, label)
    select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)

    set_source_rgb(rdr.ctx, 0.2, 1, 0.2)
    if mn < i
        plotrectangle(rdr, step - rdr.base_w / 2, i + rdr.base_h / 2, rdr.base_w, i - mn, true)
    end
    if mx > i
        plotrectangle(rdr, step - rdr.base_w / 2, i + rdr.base_h / 2, rdr.base_w, mx - i, true)
    end
    set_source_rgb(rdr.ctx, 0, 0.5, 0)
    h = mx + rdr.base_h - mn
    plotrectangle(rdr, step - rdr.base_w / 2, mn - rdr.base_h / 2, rdr.base_w, h)
end
