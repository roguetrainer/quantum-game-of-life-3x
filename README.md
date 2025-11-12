# Quantum Game of Life - F# Implementation

A functional programming implementation of the quantum Game of Life using F#.

## Overview

This implementation leverages F#'s strengths:
- **Immutability**: Quantum states don't mutate; transformations create new states
- **Type Safety**: Domain types ensure quantum mechanics constraints at compile time
- **Functional Composition**: Quantum operations compose naturally
- **Mathematical Elegance**: Syntax mirrors mathematical notation

## Features

### Domain-Driven Design

```fsharp
type QuantumCell = {
    AliveAmplitude: Complex
    Phase: float
}

type QuantumGrid = {
    Config: GridConfig
    Cells: QuantumCell[,]
}
```

### Pure Functional Evolution

```fsharp
let evolveCell (i: int) (j: int) (grid: QuantumGrid) : QuantumCell =
    grid
    |> getNeighbors i j
    |> sumNeighborAmplitudes
    |> applyQuantumRules grid.Cells.[i, j]
```

### Quantum Operations

- **State Preparation**: Classical patterns, superpositions, quantum noise
- **Unitary Evolution**: Smooth quantum rules with interference
- **Measurement**: Collapse to classical states
- **Analysis**: Entropy, total probability, phase distributions

## Key Advantages Over Python

1. **Type Safety**: Invalid quantum states caught at compile time
2. **Immutability**: No accidental state mutations
3. **Performance**: JIT-compiled, can use SIMD
4. **Composability**: Functions naturally compose
5. **Conciseness**: Less boilerplate, clearer intent

## Running the Code

### Prerequisites

- .NET 8.0 SDK or later
- F# installed

### Build and Run

```bash
# Restore dependencies
dotnet restore

# Build the project
dotnet build

# Run the simulation
dotnet run

# Or build and run in one command
dotnet run --project QuantumGameOfLife.fsproj
```

### Output

The program will:
1. Initialize a quantum glider with superposition states
2. Add quantum noise to a region
3. Evolve the system for 50 steps
4. Export quantum states as CSV files at steps: 0, 10, 20, 30, 40, 50
5. Print statistics (total probability, entropy) at each step

### Visualization

After running the F# program, use the Python visualization script:

```bash
python visualize_fsharp.py
```

This will create:
- `fsharp_quantum_evolution.png`: Evolution over time
- `fsharp_quantum_comparison.png`: Initial vs final states

## Code Structure

### Core Types (`Domain Types`)
- `QuantumCell`: Represents a single quantum cell
- `QuantumGrid`: 2D grid of quantum cells
- `GridConfig`: Configuration for grid dimensions and boundaries

### Grid Operations (`Grid Creation and Initialization`)
- `createGrid`: Create empty grid
- `fromClassicalPattern`: Initialize from binary pattern
- `addSuperposition`: Add quantum superposition to cells

### Quantum Mechanics (`Neighbor Operations` & `Quantum Evolution Rules`)
- `getNeighbors`: Retrieve neighboring cells
- `sumNeighborAmplitudes`: Quantum superposition of neighbors
- `applyQuantumRules`: Conway's rules with quantum smoothing
- `evolveGrid`: Single time step evolution
- `evolveSteps`: Multiple step evolution

### Measurement and Analysis
- `measure`: Collapse to classical state
- `getProbabilities`: Extract probability distribution
- `getPhases`: Extract phase distribution
- `quantumEntropy`: Calculate von Neumann entropy
- `totalProbability`: Verify conservation

### Pattern Creation
- `createGlider`: Classical glider pattern
- `createQuantumGlider`: Glider with superposition
- `addQuantumNoise`: Random quantum fluctuations

## Comparison: F# vs Python

### F# Advantages

**Type Safety**
```fsharp
// Compile-time guarantee of valid quantum state
let cell = QuantumCell.Create(magnitude, phase)  // Clamped to [0,1]
```

**Immutability**
```fsharp
// New grid created, original unchanged
let evolved = evolveGrid grid
```

**Pipeline Clarity**
```fsharp
grid
|> getNeighbors i j
|> sumNeighborAmplitudes
|> applyQuantumRules cell
```

**Pattern Matching**
```fsharp
match cell.AliveProbability with
| p when p > 0.5 -> applySurvivalRule cell neighbors
| _ -> applyBirthRule cell neighbors
```

### Python Advantages

**Ecosystem**: NumPy, SciPy, matplotlib built-in
**Interactive**: Jupyter notebooks for exploration
**Visualization**: Rich plotting libraries
**Learning Curve**: More familiar to scientists

## Mathematical Formulation

Each cell is in state:
```
|ψ⟩ = α|dead⟩ + β|alive⟩
```

where |α|² + |β|² = 1 (normalization)

**Evolution operator** U:
```
|ψ(t+1)⟩ = U(neighbors)|ψ(t)⟩
```

**Measurement** collapses to:
```
P(alive) = |β|²
```

## Quantum Rules

The implementation uses smooth Gaussian transitions instead of hard thresholds:

**Survival** (cell alive):
```
S(n) = exp(-((n - 2.5)² / 2))
```

**Birth** (cell dead):
```
B(n) = exp(-((n - 3)² / 2))
```

where n is the effective number of living neighbors.

**Phase Coupling**:
```
φ(t+1) = φ(t) + κ·arg(Σ neighbors)
```

where κ = 0.1 is the coupling strength.

## Extensions and Future Work

1. **Quantum Entanglement**: Correlate distant cells
2. **Decoherence**: Model environmental interaction
3. **Multi-qubit Cells**: Richer quantum states
4. **Measurement Operators**: Different observables
5. **Parallel Evolution**: Leverage F# async for performance
6. **Type Providers**: Generate quantum operators from specifications
7. **Units of Measure**: Enforce physical dimensions

## Performance Notes

F# performance is comparable to Python with NumPy for this problem:
- Array operations are optimized by .NET JIT
- Complex number operations use hardware instructions
- Immutable collections have structural sharing
- Can parallelize with `Array.Parallel` for large grids

For serious quantum simulation, consider:
- Using `Span<T>` for zero-copy array slices
- SIMD intrinsics for vectorization
- GPU compute via ILGPU or similar

## Resources

- [F# Documentation](https://fsharp.org/)
- [.NET Complex Numbers](https://docs.microsoft.com/en-us/dotnet/api/system.numerics.complex)
- [Quantum Cellular Automata](https://arxiv.org/abs/quant-ph/0405174)
- [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)

## License

This code is provided as an educational example for quantum computing and functional programming concepts.
