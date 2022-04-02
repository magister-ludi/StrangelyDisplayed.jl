
using StrangelyDisplayed
using StrangelyQuantum
using FileIO

function main()
    simulator = SimpleQuantumExecutionEnvironment()
    program = Program(3)

    step1 = Step()
    addGate(step1, Hadamard(2))
    step2 = Step()
    addGate(step2, Cnot(2, 3))
    step3 = Step()
    addGate(step3, Cnot(1, 2))
    step4 = Step()
    addGate(step4, Hadamard(1))
    step5 = Step()
    addGate(step5, Measurement(1))
    addGate(step5, Measurement(2))
    step6 = Step()
    addGate(step6, Cnot(2, 3))
    step7 = Step()
    addGate(step7, Cz(1, 3))
    addStep(program, step1)
    addStep(program, step2)
    addStep(program, step3)
    addStep(program, step4)
    addStep(program, step5)
    addStep(program, step6)
    addStep(program, step7)
    #initializeQubit(program, 1, 0.4)
    result = runProgram(simulator, program)
    qubits = getQubits(result)

    @show measure.(qubits)
    @show getProbability.(qubits)
    op = drawProgram(program)
    save("test0.png", op)
    op = drawTrialHistogram(program, 1000)
    save("test1.png", op)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
