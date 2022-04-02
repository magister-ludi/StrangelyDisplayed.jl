
function ticdist(maxval)
    f = 1
    t = (1, 2, 5)
    p = 1
    while true
        v = f * t[p]
        if 4 ≤ (maxval / v) ≤ 8
            return v
        end
        p += 1
        if p > 3
            p = 1
            f *= 10
        end
    end
end

function drawTrialHistogram(p::Program, ntrials::Integer)
    nq = getNumberQubits(p)
    nvals = 2^nq
    counts = zeros(Int, nvals)
    simulator = SimpleQuantumExecutionEnvironment()
    for _ = 1:ntrials
        result = runProgram(simulator, p)
        qubits = getQubits(result)
        counts[1 + toNumber(qubits)] += 1
    end
    ww = nvals * (BASE_W + 2 * GAP) + 2 * GAP
    hh = round(Int, 2 * ww / 3)
    rdr = Renderer(p, ww, hh)
    ymax = 10 * ceil(Int, (maximum(counts) * 0.11))
    set_plot_area(rdr, 0.15, 0.95, 0.15, 0.95)
    set_plot_range(rdr, 0.5, nvals + 0.5, 0, ymax)

    set_text_align(rdr, CentreHor, TopAlign)
    set_source_rgb(rdr.ctx, 0, 0, 0)
    drawrectangle(rdr, rdr.hMin, rdr.vMin, rdr.hMax - rdr.hMin, rdr.vMax - rdr.vMin)
    x, y = world_to_pixel(rdr, 0, 0)
    select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD)
    set_font_size(rdr.ctx, 15)
    drawtext(rdr, (rdr.hMax + rdr.hMin) / 2, y + 30, "Bit pattern")
    select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)
    set_font_size(rdr.ctx, 12)
    v = ticdist(ymax)
    set_text_align(rdr, RightAlign, CentreVer)
    set_line_width(rdr.ctx, 0.2)
    if v > 5
        for yy = 0:(v÷5):ymax
            x, y = world_to_pixel(rdr, rdr.xMin, yy)
            set_source_rgb(rdr.ctx, 0.2, 0.2, 0.2)
            drawline(rdr, rdr.hMin, y, rdr.hMax, y)
        end
    end
    set_line_width(rdr.ctx, 1)
    for yy = 0:v:ymax
        x, y = world_to_pixel(rdr, rdr.xMin, yy)
        set_source_rgb(rdr.ctx, 0, 0, 0)
        drawline(rdr, x, y, x - 5, y)
        drawtext(rdr, x - 7, y, yy)
        set_source_rgb(rdr.ctx, 0.5, 0.5, 0.5)
        drawline(rdr, rdr.hMin, y, rdr.hMax, y)
    end
    x, y = world_to_pixel(rdr, 0, ymax/2)

    set_source_rgb(rdr.ctx, 0, 0, 0)
    set_text_align(rdr, CentreHor, CentreVer)
    set_text_angle(rdr, 90)
    select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD)
    set_font_size(rdr.ctx, 15)
    drawtext(rdr, 30, y, "Count")
    select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)
    set_font_size(rdr.ctx, 12)
    set_text_angle(rdr, 0)

    labels = makelabels(nq)
    for i = 1:nvals
        set_source_rgb(rdr.ctx, 1, 0.5, 0)
        plotrectangle(rdr, i - rdr.basew / 2, 0, rdr.basew, counts[i], true)
        set_source_rgb(rdr.ctx, 0, 0, 0)
        plotrectangle(rdr, i - rdr.basew / 2, 0, rdr.basew, counts[i])
        x, y = world_to_pixel(rdr, i, 0)
        drawtext(rdr, x, y + 15, labels[i])
    end
    return permutedims(rdr.img)
end

const types = [(8, UInt8), (16, UInt16), (32, UInt32), (64, UInt64), (128, UInt128), (Inf, BigInt)]

function toNumber(qubits::Vector{Qubit})
    i = 1
    l = length(qubits)
    while types[i][1] < l
        i += 1
    end
    n = zero(types[i][2])
    for q in reverse(qubits)
        n = measure(q) + (n << 1)
    end
    return n
end

function makelabels(nbits)
    nl = 2^nbits
    return [string(i - 1, base = 2, pad = nbits) for i = 1:nl]
end
