(*
   Quantum Game of Life - F# Implementation
   
   A functional implementation of the quantum Game of Life where cells exist
   in superpositions of alive and dead states, represented by complex probability
   amplitudes.
   
   This implementation leverages F#'s type system, immutability, and functional
   composition to create a mathematically elegant quantum cellular automaton.
*)

module QuantumGameOfLife

open System
open System.Numerics

// ============================================================================
// Domain Types
// ============================================================================

/// Complex amplitude representing quantum state
type Amplitude = Complex

/// Quantum phase in radians
type Phase = float

/// Probability value between 0 and 1
type Probability = float

/// A quantum cell can be in a superposition of alive and dead states
type QuantumCell = {
    /// Complex amplitude for |alive⟩ state
    /// The |dead⟩ amplitude is implicitly sqrt(1 - |alive|²)
    AliveAmplitude: Amplitude
    
    /// Accumulated phase for quantum dynamics
    Phase: Phase
} with
    /// Get the probability of the cell being alive
    member this.AliveProbability : Probability =
        this.AliveAmplitude.Magnitude * this.AliveAmplitude.Magnitude
    
    /// Get the magnitude of the amplitude
    member this.Magnitude : float =
        this.AliveAmplitude.Magnitude
    
    /// Create a normalized cell from magnitude and phase
    static member Create(magnitude: float, phase: Phase) : QuantumCell =
        let clampedMag = max 0.0 (min 1.0 magnitude)
        { AliveAmplitude = Complex.FromPolarCoordinates(clampedMag, phase)
          Phase = phase }
    
    /// Create a cell in a classical state
    static member Classical(alive: bool) : QuantumCell =
        { AliveAmplitude = if alive then Complex.One else Complex.Zero
          Phase = 0.0 }
    
    /// Create a cell in superposition
    static member Superposition(aliveProbability: Probability, phase: Phase) : QuantumCell =
        let magnitude = sqrt aliveProbability
        QuantumCell.Create(magnitude, phase)

/// Grid configuration
type GridConfig = {
    Rows: int
    Cols: int
    Periodic: bool  // Whether to use periodic boundary conditions
}

/// Quantum Game of Life grid
type QuantumGrid = {
    Config: GridConfig
    Cells: QuantumCell[,]
} with
    /// Get a cell at position (i, j)
    member this.Item
        with get(i: int, j: int) : QuantumCell =
            this.Cells.[i, j]
    
    /// Get grid dimensions
    member this.Rows = this.Config.Rows
    member this.Cols = this.Config.Cols

// ============================================================================
// Grid Creation and Initialization
// ============================================================================

/// Create an empty quantum grid
let createGrid (config: GridConfig) : QuantumGrid =
    { Config = config
      Cells = Array2D.create config.Rows config.Cols (QuantumCell.Classical false) }

/// Set a cell in the grid (functional update)
let setCell (i: int) (j: int) (cell: QuantumCell) (grid: QuantumGrid) : QuantumGrid =
    let newCells = Array2D.copy grid.Cells
    newCells.[i, j] <- cell
    { grid with Cells = newCells }

/// Initialize grid from a classical pattern
let fromClassicalPattern (pattern: bool[,]) (config: GridConfig) : QuantumGrid =
    let cells = Array2D.init config.Rows config.Cols (fun i j ->
        if i < Array2D.length1 pattern && j < Array2D.length2 pattern then
            QuantumCell.Classical pattern.[i, j]
        else
            QuantumCell.Classical false
    )
    { Config = config; Cells = cells }

/// Add superposition to a specific cell
let addSuperposition (i: int) (j: int) (prob: Probability) (phase: Phase) (grid: QuantumGrid) : QuantumGrid =
    setCell i j (QuantumCell.Superposition(prob, phase)) grid

// ============================================================================
// Neighbor Operations
// ============================================================================

/// Get neighbor coordinates with boundary handling
let getNeighborCoords (i: int) (j: int) (config: GridConfig) : (int * int) list =
    [-1..1]
    |> List.collect (fun di ->
        [-1..1]
        |> List.choose (fun dj ->
            if di = 0 && dj = 0 then
                None
            else
                let ni, nj = i + di, j + dj
                if config.Periodic then
                    Some ((ni + config.Rows) % config.Rows, 
                          (nj + config.Cols) % config.Cols)
                else if ni >= 0 && ni < config.Rows && nj >= 0 && nj < config.Cols then
                    Some (ni, nj)
                else
                    None
        )
    )

/// Get the quantum cells of all neighbors
let getNeighbors (i: int) (j: int) (grid: QuantumGrid) : QuantumCell list =
    getNeighborCoords i j grid.Config
    |> List.map (fun (ni, nj) -> grid.Cells.[ni, nj])

/// Sum the amplitudes of neighbors
let sumNeighborAmplitudes (neighbors: QuantumCell list) : Amplitude =
    neighbors
    |> List.map (fun cell -> cell.AliveAmplitude)
    |> List.fold (+) Complex.Zero

// ============================================================================
// Quantum Evolution Rules
// ============================================================================

/// Gaussian function for smooth rule application
let gaussian (x: float) (center: float) (width: float) : float =
    exp (-((x - center) ** 2.0) / (2.0 * width * width))

/// Apply quantum Game of Life rules
let applyQuantumRules (cell: QuantumCell) (neighborSum: Amplitude) : QuantumCell =
    let aliveProbability = cell.AliveProbability
    let neighborProbability = neighborSum.Magnitude * neighborSum.Magnitude / 8.0
    let neighborPhase = neighborSum.Phase
    let neighborCount = neighborProbability * 8.0
    
    // Quantum version of Conway's rules with smooth transitions
    let newAmplitude =
        if aliveProbability > 0.5 then
            // Cell is more alive - apply survival rule (optimal at 2-3 neighbors)
            let survivalFactor = gaussian neighborCount 2.5 1.0
            cell.AliveAmplitude * Complex(0.3 + 0.7 * survivalFactor, 0.0)
        else
            // Cell is more dead - apply birth rule (optimal at 3 neighbors)
            let birthFactor = gaussian neighborCount 3.0 1.0
            Complex.FromPolarCoordinates(birthFactor, neighborPhase)
    
    // Phase coupling for quantum interference
    let phaseCoupling = 0.1
    let newPhase = cell.Phase + phaseCoupling * neighborPhase
    
    // Reconstruct with new phase
    let magnitude = min newAmplitude.Magnitude 1.0
    QuantumCell.Create(magnitude, newPhase)

/// Evolve a single cell based on its neighbors
let evolveCell (i: int) (j: int) (grid: QuantumGrid) : QuantumCell =
    let cell = grid.Cells.[i, j]
    let neighbors = getNeighbors i j grid
    let neighborSum = sumNeighborAmplitudes neighbors
    applyQuantumRules cell neighborSum

/// Evolve the entire grid by one time step
let evolveGrid (grid: QuantumGrid) : QuantumGrid =
    let newCells = Array2D.init grid.Rows grid.Cols (fun i j ->
        evolveCell i j grid
    )
    { grid with Cells = newCells }

/// Evolve the grid for multiple steps
let evolveSteps (steps: int) (grid: QuantumGrid) : QuantumGrid =
    [1..steps]
    |> List.fold (fun g _ -> evolveGrid g) grid

// ============================================================================
// Measurement and Analysis
// ============================================================================

/// Measure the grid, collapsing to classical states
let measure (threshold: Probability) (grid: QuantumGrid) : bool[,] =
    Array2D.init grid.Rows grid.Cols (fun i j ->
        grid.Cells.[i, j].AliveProbability > threshold
    )

/// Get probability distribution of the grid
let getProbabilities (grid: QuantumGrid) : float[,] =
    Array2D.map (fun cell -> cell.AliveProbability) grid.Cells

/// Get phase distribution of the grid
let getPhases (grid: QuantumGrid) : float[,] =
    Array2D.map (fun cell -> cell.AliveAmplitude.Phase) grid.Cells

/// Calculate total probability (should be conserved in unitary evolution)
let totalProbability (grid: QuantumGrid) : float =
    grid.Cells
    |> Seq.cast<QuantumCell>
    |> Seq.sumBy (fun cell -> cell.AliveProbability)

/// Calculate quantum entropy of the grid
let quantumEntropy (grid: QuantumGrid) : float =
    grid.Cells
    |> Seq.cast<QuantumCell>
    |> Seq.map (fun cell ->
        let p = cell.AliveProbability
        if p > 0.0 && p < 1.0 then
            -p * log p - (1.0 - p) * log (1.0 - p)
        else
            0.0
    )
    |> Seq.sum

// ============================================================================
// Pattern Creation
// ============================================================================

/// Create a classical glider pattern
let createGlider (rows: int) (cols: int) : bool[,] =
    let pattern = Array2D.create rows cols false
    pattern.[1, 2] <- true
    pattern.[2, 3] <- true
    pattern.[3, 1] <- true
    pattern.[3, 2] <- true
    pattern.[3, 3] <- true
    pattern

/// Create a quantum glider with superposition
let createQuantumGlider (config: GridConfig) : QuantumGrid =
    let classicalGlider = createGlider config.Rows config.Cols
    let grid = fromClassicalPattern classicalGlider config
    
    // Add quantum superposition to some cells
    grid
    |> addSuperposition 2 2 0.7 (Math.PI / 4.0)
    |> addSuperposition 3 2 0.6 (Math.PI / 3.0)

/// Add random quantum noise to a region
let addQuantumNoise (startRow: int) (endRow: int) 
                    (startCol: int) (endCol: int)
                    (noiseLevel: float) (grid: QuantumGrid) : QuantumGrid =
    let rng = Random()
    
    [startRow .. endRow - 1]
    |> List.collect (fun i ->
        [startCol .. endCol - 1]
        |> List.map (fun j -> (i, j))
    )
    |> List.filter (fun _ -> rng.NextDouble() < 0.3)
    |> List.fold (fun g (i, j) ->
        let prob = noiseLevel * rng.NextDouble()
        let phase = 2.0 * Math.PI * rng.NextDouble()
        addSuperposition i j prob phase g
    ) grid

// ============================================================================
// Visualization Helpers (output for external plotting)
// ============================================================================

/// Export grid state to CSV format
let exportToCsv (filename: string) (grid: QuantumGrid) : unit =
    use writer = new System.IO.StreamWriter(filename)
    
    for i in 0 .. grid.Rows - 1 do
        let row = 
            [0 .. grid.Cols - 1]
            |> List.map (fun j -> sprintf "%.6f" grid.Cells.[i, j].AliveProbability)
            |> String.concat ","
        writer.WriteLine(row)

/// Print grid statistics
let printStatistics (step: int) (grid: QuantumGrid) : unit =
    printfn "Step %d:" step
    printfn "  Total Probability: %.4f" (totalProbability grid)
    printfn "  Quantum Entropy: %.4f" (quantumEntropy grid)
    
    let probs = getProbabilities grid
    let avgProb = 
        probs 
        |> Seq.cast<float> 
        |> Seq.average
    printfn "  Average Cell Probability: %.4f" avgProb

// ============================================================================
// Demo and Testing
// ============================================================================

module Demo =
    
    /// Run a simple demonstration
    let runDemo () =
        printfn "Quantum Game of Life - F# Implementation"
        printfn "=========================================="
        printfn ""
        
        // Create configuration
        let config = { Rows = 50; Cols = 50; Periodic = true }
        
        // Initialize with quantum glider
        printfn "Initializing quantum glider..."
        let initialGrid = 
            createQuantumGlider config
            |> addQuantumNoise 5 15 5 15 0.1
        
        printfn "Grid size: %dx%d" config.Rows config.Cols
        printfn "Total quantum states: %d" (config.Rows * config.Cols)
        printfn ""
        
        // Print initial statistics
        printStatistics 0 initialGrid
        printfn ""
        
        // Evolve the system
        printfn "Evolving quantum system..."
        let steps = [0; 10; 20; 30; 40; 50]
        
        steps
        |> List.fold (fun (grid, prevStep) step ->
            let stepsToEvolve = step - prevStep
            let evolved = evolveSteps stepsToEvolve grid
            
            // Export state
            let filename = sprintf "/mnt/user-data/outputs/quantum_state_step_%03d.csv" step
            exportToCsv filename evolved
            printfn "Exported step %d to %s" step filename
            
            // Print statistics
            printStatistics step evolved
            printfn ""
            
            (evolved, step)
        ) (initialGrid, 0)
        |> ignore
        
        printfn "Demonstration complete!"
        printfn ""
        printfn "The quantum states have been exported as CSV files."
        printfn "You can visualize them using Python's matplotlib or any plotting tool."

// ============================================================================
// Main Entry Point
// ============================================================================

[<EntryPoint>]
let main argv =
    Demo.runDemo()
    0
