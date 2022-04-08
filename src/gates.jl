
function draw(rdr::Renderer, step, num_steps, gate::ProbabilitiesGate)
    result = getResult(rdr.p)
    ip = getIntermediateProbability(result, step)
    if ip === nothing
        error("Can not retrieve probabilities for step ", step)
    end
    nq = getNumberQubits(rdr.p)
    nn = 1 << nq

    offsetY = 1 - rdr.base_h / 2
    deltaY = (nq - 1 + rdr.base_h) / nn

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
