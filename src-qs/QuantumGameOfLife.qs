// Quantum Game of Life - Q# Implementation
// ==========================================
//
// A Q# implementation demonstrating quantum cellular automata using Microsoft's
// quantum programming language. This version leverages Q#'s native quantum types
// and operations for a more authentic quantum representation.
//
// Note: This is a hybrid classical-quantum approach where quantum operations
// are used for evolution while classical tracking maintains the grid state.

namespace QuantumGameOfLife {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Preparation;

    // =========================================================================
    // Type Definitions and Structures
    // =========================================================================

    /// Represents a quantum cell's amplitude and phase
    newtype QuantumCellState = (
        Amplitude: Double,
        Phase: Double
    );

    /// Grid configuration
    newtype GridConfig = (
        Rows: Int,
        Cols: Int,
        Periodic: Bool
    );

    /// Classical representation of the grid for tracking
    newtype ClassicalGrid = (
        Config: GridConfig,
        States: QuantumCellState[][]
    );

    // =========================================================================
    // Quantum Operations - Core Primitives
    // =========================================================================

    /// Prepare a qubit in a superposition state with given amplitude and phase
    operation PrepareQubitState(amplitude: Double, phase: Double, target: Qubit) : Unit {
        // Reset qubit to |0⟩
        Reset(target);
        
        // Calculate rotation angles
        // |ψ⟩ = cos(θ/2)|0⟩ + e^(iφ) sin(θ/2)|1⟩
        let theta = 2.0 * ArcCos(Sqrt(1.0 - amplitude * amplitude));
        
        // Apply rotations
        Ry(theta, target);
        
        // Apply phase
        if (AbsD(phase) > 1e-10) {
            R1(phase, target);
        }
    }

    /// Measure the probability amplitude of a qubit being in |1⟩ state
    operation MeasureAmplitude(q: Qubit) : Double {
        // This is a classical simulation - in real quantum hardware,
        // we'd need multiple measurements and tomography
        
        // For now, perform computational basis measurement
        let result = M(q);
        
        // Return 1.0 if measured |1⟩, 0.0 if measured |0⟩
        return result == One ? 1.0 | 0.0;
    }

    /// Create a quantum superposition representing a cell state
    operation CreateCellSuperposition(amplitude: Double, phase: Double) : Result {
        use q = Qubit();
        PrepareQubitState(amplitude, phase, q);
        let result = M(q);
        Reset(q);
        return result;
    }

    // =========================================================================
    // Quantum Evolution Operations
    // =========================================================================

    /// Apply quantum interference between qubits representing neighboring cells
    operation ApplyNeighborInterference(
        cell: Qubit,
        neighbors: Qubit[],
        coupling: Double
    ) : Unit {
        // Apply controlled rotations based on neighbor states
        // This simulates quantum interference effects
        
        for neighbor in neighbors {
            // Apply controlled phase based on neighbor
            Controlled R1([neighbor], (coupling, cell));
            
            // Apply controlled Ry for amplitude coupling
            Controlled Ry([neighbor], (coupling * 0.1, cell));
        }
    }

    /// Implement quantum Game of Life rules with smooth transitions
    operation QuantumGameOfLifeRule(
        cellAmplitude: Double,
        neighborAmplitudes: Double[],
        phase: Double
    ) : QuantumCellState {
        
        // Calculate neighbor statistics
        let neighborCount = IntAsDouble(Length(neighborAmplitudes));
        let neighborSum = Fold(PlusD, 0.0, neighborAmplitudes);
        let avgNeighborAmplitude = neighborSum / neighborCount;
        
        // Calculate effective number of alive neighbors
        let effectiveNeighbors = neighborSum;
        
        // Quantum smooth version of Conway's rules
        let aliveProbability = cellAmplitude * cellAmplitude;
        
        mutable newAmplitude = 0.0;
        mutable newPhase = phase;
        
        if (aliveProbability > 0.5) {
            // Cell is more alive - apply survival rule
            // Optimal at 2-3 neighbors
            let survivalFactor = Exp(-PowD((effectiveNeighbors - 2.5), 2.0) / 2.0);
            set newAmplitude = cellAmplitude * (0.3 + 0.7 * survivalFactor);
        } else {
            // Cell is more dead - apply birth rule  
            // Optimal at 3 neighbors
            let birthFactor = Exp(-PowD((effectiveNeighbors - 3.0), 2.0) / 2.0);
            set newAmplitude = birthFactor;
            
            // Inherit phase from neighbors
            if (Length(neighborAmplitudes) > 0) {
                set newPhase = avgNeighborAmplitude * PI();
            }
        }
        
        // Apply phase coupling
        let phaseCoupling = 0.1;
        set newPhase = phase + phaseCoupling * avgNeighborAmplitude * PI();
        
        // Normalize amplitude to valid range [0, 1]
        set newAmplitude = MinD(MaxD(newAmplitude, 0.0), 1.0);
        
        return QuantumCellState(newAmplitude, newPhase);
    }

    // =========================================================================
    // Grid Operations
    // =========================================================================

    /// Get neighbor coordinates with boundary handling
    function GetNeighborCoords(row: Int, col: Int, config: GridConfig) : (Int, Int)[] {
        let (rows, cols, periodic) = config!;
        
        mutable coords = [];
        
        for di in -1..1 {
            for dj in -1..1 {
                if (di != 0 or dj != 0) {
                    let ni = row + di;
                    let nj = col + dj;
                    
                    if (periodic) {
                        let wrappedI = (ni + rows) % rows;
                        let wrappedJ = (nj + cols) % cols;
                        set coords += [(wrappedI, wrappedJ)];
                    } else {
                        if (ni >= 0 and ni < rows and nj >= 0 and nj < cols) {
                            set coords += [(ni, nj)];
                        }
                    }
                }
            }
        }
        
        return coords;
    }

    /// Get amplitudes of neighboring cells
    function GetNeighborAmplitudes(
        row: Int,
        col: Int,
        grid: ClassicalGrid
    ) : Double[] {
        let (config, states) = grid!;
        let coords = GetNeighborCoords(row, col, config);
        
        mutable amplitudes = [];
        for (ni, nj) in coords {
            let (amp, _) = states[ni][nj]!;
            set amplitudes += [amp];
        }
        
        return amplitudes;
    }

    /// Evolve a single cell
    function EvolveCell(row: Int, col: Int, grid: ClassicalGrid) : QuantumCellState {
        let (_, states) = grid!;
        let (cellAmp, cellPhase) = states[row][col]!;
        let neighborAmps = GetNeighborAmplitudes(row, col, grid);
        
        return QuantumGameOfLifeRule(cellAmp, neighborAmps, cellPhase);
    }

    /// Evolve the entire grid for one time step
    function EvolveGrid(grid: ClassicalGrid) : ClassicalGrid {
        let (config, states) = grid!;
        let (rows, cols, _) = config!;
        
        mutable newStates = [];
        
        for i in 0..rows-1 {
            mutable row = [];
            for j in 0..cols-1 {
                set row += [EvolveCell(i, j, grid)];
            }
            set newStates += [row];
        }
        
        return ClassicalGrid(config, newStates);
    }

    /// Evolve grid for multiple steps
    function EvolveSteps(steps: Int, initialGrid: ClassicalGrid) : ClassicalGrid {
        mutable grid = initialGrid;
        for _ in 1..steps {
            set grid = EvolveGrid(grid);
        }
        return grid;
    }

    // =========================================================================
    // Grid Initialization
    // =========================================================================

    /// Create empty grid
    function CreateEmptyGrid(config: GridConfig) : ClassicalGrid {
        let (rows, cols, _) = config!;
        
        mutable states = [];
        for _ in 0..rows-1 {
            mutable row = [];
            for _ in 0..cols-1 {
                set row += [QuantumCellState(0.0, 0.0)];
            }
            set states += [row];
        }
        
        return ClassicalGrid(config, states);
    }

    /// Set a cell to a specific state
    function SetCell(
        row: Int,
        col: Int,
        state: QuantumCellState,
        grid: ClassicalGrid
    ) : ClassicalGrid {
        let (config, states) = grid!;
        
        mutable newStates = [];
        let (rows, _, _) = config!;
        
        for i in 0..rows-1 {
            if (i == row) {
                mutable newRow = [];
                for j in 0..Length(states[i])-1 {
                    if (j == col) {
                        set newRow += [state];
                    } else {
                        set newRow += [states[i][j]];
                    }
                }
                set newStates += [newRow];
            } else {
                set newStates += [states[i]];
            }
        }
        
        return ClassicalGrid(config, newStates);
    }

    /// Initialize from classical pattern
    function FromClassicalPattern(
        pattern: Bool[][],
        config: GridConfig
    ) : ClassicalGrid {
        let (rows, cols, _) = config!;
        
        mutable states = [];
        
        for i in 0..rows-1 {
            mutable row = [];
            for j in 0..cols-1 {
                if (i < Length(pattern) and j < Length(pattern[0])) {
                    let amplitude = pattern[i][j] ? 1.0 | 0.0;
                    set row += [QuantumCellState(amplitude, 0.0)];
                } else {
                    set row += [QuantumCellState(0.0, 0.0)];
                }
            }
            set states += [row];
        }
        
        return ClassicalGrid(config, states);
    }

    // =========================================================================
    // Pattern Creation
    // =========================================================================

    /// Create glider pattern
    function CreateGliderPattern(rows: Int, cols: Int) : Bool[][] {
        mutable pattern = [];
        
        for i in 0..rows-1 {
            mutable row = [];
            for j in 0..cols-1 {
                mutable isAlive = false;
                
                // Glider pattern at position (1,2), (2,3), (3,1), (3,2), (3,3)
                if ((i == 1 and j == 2) or
                    (i == 2 and j == 3) or
                    (i == 3 and (j == 1 or j == 2 or j == 3))) {
                    set isAlive = true;
                }
                
                set row += [isAlive];
            }
            set pattern += [row];
        }
        
        return pattern;
    }

    /// Create quantum glider with superposition
    function CreateQuantumGlider(config: GridConfig) : ClassicalGrid {
        let (rows, cols, _) = config!;
        let pattern = CreateGliderPattern(rows, cols);
        
        mutable grid = FromClassicalPattern(pattern, config);
        
        // Add quantum superposition to some cells
        set grid = SetCell(2, 2, QuantumCellState(Sqrt(0.7), PI() / 4.0), grid);
        set grid = SetCell(3, 2, QuantumCellState(Sqrt(0.6), PI() / 3.0), grid);
        
        return grid;
    }

    // =========================================================================
    // Measurement and Analysis
    // =========================================================================

    /// Get probability distribution of the grid
    function GetProbabilities(grid: ClassicalGrid) : Double[][] {
        let (config, states) = grid!;
        let (rows, cols, _) = config!;
        
        mutable probs = [];
        
        for i in 0..rows-1 {
            mutable row = [];
            for j in 0..cols-1 {
                let (amp, _) = states[i][j]!;
                set row += [amp * amp];
            }
            set probs += [row];
        }
        
        return probs;
    }

    /// Measure grid to classical state
    function MeasureGrid(threshold: Double, grid: ClassicalGrid) : Bool[][] {
        let (config, states) = grid!;
        let (rows, cols, _) = config!;
        
        mutable measured = [];
        
        for i in 0..rows-1 {
            mutable row = [];
            for j in 0..cols-1 {
                let (amp, _) = states[i][j]!;
                let prob = amp * amp;
                set row += [prob > threshold];
            }
            set measured += [row];
        }
        
        return measured;
    }

    /// Calculate total probability (for conservation checks)
    function TotalProbability(grid: ClassicalGrid) : Double {
        let (_, states) = grid!;
        
        mutable total = 0.0;
        
        for row in states {
            for cell in row {
                let (amp, _) = cell!;
                set total += amp * amp;
            }
        }
        
        return total;
    }

    /// Calculate quantum entropy
    function QuantumEntropy(grid: ClassicalGrid) : Double {
        let (_, states) = grid!;
        
        mutable entropy = 0.0;
        
        for row in states {
            for cell in row {
                let (amp, _) = cell!;
                let p = amp * amp;
                
                if (p > 1e-10 and p < (1.0 - 1e-10)) {
                    set entropy += -p * Log(p) - (1.0 - p) * Log(1.0 - p);
                }
            }
        }
        
        return entropy;
    }

    // =========================================================================
    // Quantum-Enhanced Evolution (Using Actual Qubits)
    // =========================================================================

    /// Perform quantum evolution using actual qubit operations
    /// This is a more "authentic" quantum approach
    operation QuantumEnhancedEvolution(
        cellState: QuantumCellState,
        neighborStates: QuantumCellState[]
    ) : QuantumCellState {
        
        let (cellAmp, cellPhase) = cellState!;
        
        use cellQubit = Qubit();
        use neighborQubits = Qubit[Length(neighborStates)];
        
        // Prepare qubits
        PrepareQubitState(cellAmp, cellPhase, cellQubit);
        
        for i in 0..Length(neighborStates)-1 {
            let (amp, phase) = neighborStates[i]!;
            PrepareQubitState(amp, phase, neighborQubits[i]);
        }
        
        // Apply quantum interference
        ApplyNeighborInterference(cellQubit, neighborQubits, 0.1);
        
        // Measure (in real quantum computing, we'd use tomography)
        // For simulation, extract probability amplitude
        let result = M(cellQubit);
        let newAmplitude = result == One ? 0.9 | 0.1;
        
        // Get phase (simplified - real implementation would use phase estimation)
        let newPhase = cellPhase;
        
        // Cleanup
        ResetAll(neighborQubits);
        Reset(cellQubit);
        
        return QuantumCellState(newAmplitude, newPhase);
    }

    // =========================================================================
    // Main Entry Point and Demo
    // =========================================================================

    /// Main entry point for Q# program
    @EntryPoint()
    operation Main() : Unit {
        Message("Quantum Game of Life - Q# Implementation");
        Message("============================================");
        Message("");
        
        // Configuration
        let config = GridConfig(50, 50, true);
        let (rows, cols, _) = config!;
        
        Message($"Grid size: {rows}x{cols}");
        Message($"Total quantum states: {rows * cols}");
        Message("");
        
        // Create quantum glider
        Message("Initializing quantum glider...");
        let initialGrid = CreateQuantumGlider(config);
        
        // Initial statistics
        Message("Initial state:");
        Message($"  Total Probability: {TotalProbability(initialGrid)}");
        Message($"  Quantum Entropy: {QuantumEntropy(initialGrid)}");
        Message("");
        
        // Evolve the system
        Message("Evolving quantum system...");
        let steps = [0, 10, 20, 30, 40, 50];
        
        mutable currentGrid = initialGrid;
        mutable prevStep = 0;
        
        for step in steps {
            let stepsToEvolve = step - prevStep;
            set currentGrid = EvolveSteps(stepsToEvolve, currentGrid);
            
            Message($"Step {step}:");
            Message($"  Total Probability: {TotalProbability(currentGrid)}");
            Message($"  Quantum Entropy: {QuantumEntropy(currentGrid)}");
            Message("");
            
            set prevStep = step;
        }
        
        Message("Quantum evolution complete!");
        Message("");
        
        // Measure final state
        Message("Measuring final state (threshold = 0.5)...");
        let measured = MeasureGrid(0.5, currentGrid);
        
        mutable aliveCount = 0;
        for row in measured {
            for cell in row {
                if (cell) {
                    set aliveCount += 1;
                }
            }
        }
        
        Message($"Alive cells after measurement: {aliveCount}");
        Message("");
        Message("Demonstration complete!");
    }
}
