
@enum HorAlign LeftAlign CentreHor RightAlign
@enum VerAlign BottomAlign CentreVer TopAlign

const BASE_W = 40
const BASE_H = 40
const GAP = 10
const BACKGROUND = ARGB32(1, 1, 0.9)

mutable struct Renderer
    ctx::CairoContext
    img::Matrix{ARGB32}
    p::Program
    tc::Float64
    ts::Float64
    tjh::HorAlign
    tjv::VerAlign
    # plot area (image coords)
    hMin::Int
    hMax::Int
    vMin::Int
    vMax::Int
    # plot extrema (world coords)
    xMin::Float64
    xMax::Float64
    yMin::Float64
    yMax::Float64
    # World values for BASE/GAP
    basew::Float64
    baseh::Float64
    gapw::Float64
    gaph::Float64
    function Renderer(p, ww, hh)
        img = fill(BACKGROUND, ww, hh)
        surf = CairoImageSurface(img)
        ctx = CairoContext(surf)
        rdr = new(ctx, img, p)
        set_text_angle(rdr, 0)
        set_plot_range(rdr, -1, 1, -1, 1)
        set_text_align(rdr, LeftAlign, BottomAlign)

        set_source_rgb(rdr.ctx, 0, 0, 0)
        set_line_width(rdr.ctx, 1)
        set_plot_area(rdr, 0.1, 0.9, 0.1, 0.9)
        select_font_face(rdr.ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)
        set_font_size(rdr.ctx, 12)
        #set_antialias(rdr.ctx, true)
        return rdr
    end
end

struct TextExtent
    x_bearing::Float64
    y_bearing::Float64
    width::Float64
    height::Float64
    x_advance::Float64
    y_advance::Float64
    TextExtent(values::Matrix{<:Real}) = new(values...)
end

set_text_align(rdr::Renderer, h::HorAlign, v::VerAlign) = rdr.tjh, rdr.tjv = h, v

function set_text_angle(rdr::Renderer, degrees)
    rdr.ts, rdr.tc = sincosd(-degrees)
end

textextent(rdr::Renderer, s::AbstractString) = TextExtent(text_extents(rdr.ctx, s))

function set_plot_area(rdr::Renderer, x0, x1, y0, y1)
    rdr.hMin = round(Int, x0 * width(rdr.ctx))
    rdr.hMax = round(Int, x1 * width(rdr.ctx))
    rdr.vMax = round(Int, (1 - y1) * height(rdr.ctx))
    rdr.vMin = round(Int, (1 - y0) * height(rdr.ctx))
    set_world_values(rdr)
end

function set_plot_range(rdr::Renderer, x0, x1, y0, y1)
    rdr.xMin = x0
    rdr.xMax = x1
    rdr.yMin = y0
    rdr.yMax = y1
    set_world_values(rdr)
end

function set_world_values(rdr::Renderer)
    rdr.basew, rdr.baseh = pixel_to_world(rdr, BASE_W, BASE_H) .- pixel_to_world(rdr, 0, 0)
    rdr.gapw, rdr.gaph = pixel_to_world(rdr, GAP, GAP) .- pixel_to_world(rdr, 0, 0)
end

"""Return the drawing position of plot coordinates `x`, `y`."""
function world_to_pixel(rdr::Renderer, x, y)
    round(Int, rdr.hMin + (rdr.hMax - rdr.hMin) * (x - rdr.xMin) / (rdr.xMax - rdr.xMin)),
    round(Int, rdr.vMin + (rdr.vMax - rdr.vMin) * (y - rdr.yMin) / (rdr.yMax - rdr.yMin))
end

"""Return the plot coordinates of drawing position `x`, `y`."""
function pixel_to_world(rdr::Renderer, x, y)
    rdr.xMin + (x - rdr.hMin) * (rdr.xMax - rdr.xMin) / (rdr.hMax - rdr.hMin),
    rdr.yMin + (y - rdr.vMin) * (rdr.yMax - rdr.yMin) / (rdr.vMax - rdr.vMin)
end

function drawline(rdr::Renderer, x1, y1, x2, y2)
    move_to(rdr.ctx, x1, y1)
    line_to(rdr.ctx, x2, y2)
    stroke(rdr.ctx)
end

function plotline(rdr::Renderer, x1, y1, x2, y2)
    xx1, yy1 = world_to_pixel(rdr, x1, y1)
    xx2, yy2 = world_to_pixel(rdr, x2, y2)
    drawline(rdr, xx1, yy1, xx2, yy2)
end

function drawrectangle(rdr::Renderer, x, y, w, h, fill = false)
    move_to(rdr.ctx, x, y)
    line_to(rdr.ctx, x + w - 1, y)
    line_to(rdr.ctx, x + w - 1, y + h - 1)
    line_to(rdr.ctx, x, y + h - 1)
    close_path(rdr.ctx)
    if fill
        fill_preserve(rdr.ctx)
    end
    stroke(rdr.ctx)
end

function plotrectangle(rdr::Renderer, x, y, w, h, fill = false)
    x1, y1 = world_to_pixel(rdr, x, y + h)
    x2, y2 = world_to_pixel(rdr, x + w, y)
    drawrectangle(rdr, x1, y1, x2 - x1, y2 - y1, fill)
end

function drawcircle(rdr::Renderer, xc, yc, r, fill = false)
    arc(rdr.ctx, xc, yc, r, 0, 2 * π)
    if fill
        fill_preserve(rdr.ctx)
    end
    stroke(rdr.ctx)
end

function drawtext(rdr::Renderer, x, y, s::AbstractString)
    Cairo.save(rdr.ctx)
    m = CairoMatrix(rdr.tc, rdr.ts, -rdr.ts, rdr.tc, x, y)
    set_matrix(rdr.ctx, m)
    xtnt = textextent(rdr, s)
    x0, y0 = 0, 0
    if rdr.tjh == CentreHor
        x0 -= xtnt.width / 2
    elseif rdr.tjh == RightAlign
        x0 -= xtnt.width
    end
    if rdr.tjv == CentreVer
        y0 += xtnt.height / 3
    elseif rdr.tjv == TopAlign
        y0 += 2 * xtnt.height / 3
    end
    move_to(rdr.ctx, x0, y0)
    show_text(rdr.ctx, s)
    stroke(rdr.ctx)
    Cairo.restore(rdr.ctx)
end

drawtext(rdr::Renderer, x, y, args...) = drawtext(rdr, x, y, string.(args...))

plottext(rdr::Renderer, x, y, args...) = drawtext(rdr, world_to_pixel(rdr, x, y)..., args...)
