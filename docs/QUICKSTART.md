# Quick Start Guide: F# Quantum Game of Life

## Installation (One-Time Setup)

### Windows

1. **Install .NET SDK**:
   - Download from: https://dotnet.microsoft.com/download
   - Choose ".NET 8.0 SDK"
   - Run the installer

2. **Verify Installation**:
   ```powershell
   dotnet --version
   # Should show 8.0.x or higher
   ```

### macOS

1. **Install .NET SDK**:
   ```bash
   brew install dotnet-sdk
   ```

2. **Verify**:
   ```bash
   dotnet --version
   ```

### Linux (Ubuntu/Debian)

1. **Install .NET SDK**:
   ```bash
   wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
   chmod +x ./dotnet-install.sh
   ./dotnet-install.sh --channel 8.0
   ```

2. **Add to PATH** (add to ~/.bashrc):
   ```bash
   export DOTNET_ROOT=$HOME/.dotnet
   export PATH=$PATH:$DOTNET_ROOT
   ```

3. **Verify**:
   ```bash
   dotnet --version
   ```

## Running the Quantum Game of Life

### Quick Run (Simplest)

```bash
# Navigate to the project directory
cd /path/to/quantum-game-of-life

# Run directly
dotnet run

# This will:
# 1. Restore dependencies
# 2. Build the project
# 3. Execute the simulation
# 4. Generate CSV files in outputs/
```

### Step-by-Step Execution

```bash
# 1. Restore NuGet packages (first time only)
dotnet restore

# 2. Build the project
dotnet build

# 3. Run the compiled executable
dotnet run --project QuantumGameOfLife.fsproj
```

### Build for Release (Optimized)

```bash
# Build optimized version
dotnet build -c Release

# Run optimized version
dotnet run -c Release
```

## Expected Output

When you run the program, you'll see:

```
Quantum Game of Life - F# Implementation
==========================================

Initializing quantum glider...
Grid size: 50x50
Total quantum states: 2500

Step 0:
  Total Probability: 5.3000
  Quantum Entropy: 2.1543
  Average Cell Probability: 0.0212
Exported step 0 to /mnt/user-data/outputs/quantum_state_step_000.csv

Step 10:
  Total Probability: 5.4821
  Quantum Entropy: 2.3187
  Average Cell Probability: 0.0219
Exported step 10 to /mnt/user-data/outputs/quantum_state_step_010.csv

...

Demonstration complete!
```

## Visualizing Results

After running the F# code, visualize with Python:

```bash
# Install Python dependencies (one time)
pip install numpy matplotlib

# Run visualization
python visualize_fsharp.py
```

This creates:
- `fsharp_quantum_evolution.png` - Evolution over time
- `fsharp_quantum_comparison.png` - Initial vs final states

## Interactive F# (FSI - F# Interactive)

You can explore the code interactively:

```bash
# Start F# Interactive
dotnet fsi

# Load the file
> #load "QuantumGameOfLife.fs";;
> open QuantumGameOfLife;;

# Create a small grid
> let config = { Rows = 10; Cols = 10; Periodic = true };;
> let grid = createGrid config;;

# Add a glider
> let gliderGrid = createQuantumGlider config;;

# Evolve one step
> let evolved = evolveGrid gliderGrid;;

# Check probability
> let probs = getProbabilities evolved;;

# Measure to classical state
> let classical = measure 0.5 evolved;;
```

## Modifying the Code

### Change Grid Size

In `QuantumGameOfLife.fs`, find:

```fsharp
// Line ~450
let config = { Rows = 50; Cols = 50; Periodic = true }
```

Change to:
```fsharp
let config = { Rows = 100; Cols = 100; Periodic = true }
```

### Change Evolution Steps

Find:

```fsharp
// Line ~465
let steps = [0; 10; 20; 30; 40; 50]
```

Change to:
```fsharp
let steps = [0; 5; 10; 15; 20; 25; 30]  // More frequent snapshots
```

### Add Custom Patterns

Add your own pattern function:

```fsharp
/// Create a blinker pattern
let createBlinker (config: GridConfig) : QuantumGrid =
    let pattern = Array2D.create config.Rows config.Cols false
    pattern.[5, 4] <- true
    pattern.[5, 5] <- true
    pattern.[5, 6] <- true
    fromClassicalPattern pattern config
```

Then use it:

```fsharp
let grid = createBlinker config
```

## Common Issues & Solutions

### Issue: "dotnet: command not found"

**Solution**: .NET SDK not installed or not in PATH
- Reinstall .NET SDK
- Add to PATH (see Installation section)

### Issue: Build fails with "error FS0039"

**Solution**: Type or function not found
- Check spelling of functions
- Ensure all `open` statements are present
- Run `dotnet restore` first

### Issue: Slow execution

**Solutions**:
1. Build in Release mode: `dotnet run -c Release`
2. Reduce grid size
3. Enable parallel processing (modify code to use `Array.Parallel`)

### Issue: Out of memory

**Solutions**:
1. Reduce grid size
2. Reduce number of steps
3. Increase system memory allocation

## Performance Tips

### Optimization 1: Parallel Processing

Replace:
```fsharp
let newCells = Array2D.init grid.Rows grid.Cols (fun i j ->
    evolveCell i j grid
)
```

With:
```fsharp
let newCells = 
    [|0 .. grid.Rows - 1|]
    |> Array.Parallel.map (fun i ->
        [|0 .. grid.Cols - 1|]
        |> Array.map (fun j -> evolveCell i j grid)
    )
    |> array2D
```

### Optimization 2: Memoization

Cache frequently computed values:

```fsharp
let neighborCache = 
    Array2D.init grid.Rows grid.Cols (fun i j ->
        getNeighborCoords i j grid.Config
    )
```

### Optimization 3: SIMD Operations

For advanced users, use `System.Numerics.Vector`:

```fsharp
open System.Numerics

// Vectorize amplitude operations
let vectorizedSum (cells: QuantumCell[]) =
    // Use SIMD for parallel complex number operations
    ...
```

## Integration with Existing Tools

### Export for Qiskit

```fsharp
/// Export quantum state in Qiskit-compatible format
let exportForQiskit (filename: string) (grid: QuantumGrid) : unit =
    // Export as statevector format
    ...
```

### Export for PennyLane

```fsharp
/// Export quantum state for PennyLane
let exportForPennyLane (filename: string) (grid: QuantumGrid) : unit =
    // Export in NumPy-compatible format
    ...
```

### Call from Python

Use Python.NET:

```python
import clr
clr.AddReference("QuantumGameOfLife")
from QuantumGameOfLife import *

# Use F# functions from Python
config = GridConfig(50, 50, True)
grid = createGrid(config)
```

## Next Steps

1. **Experiment**: Try different initial patterns
2. **Visualize**: Create animations with your visualizations
3. **Extend**: Add new quantum rules or measurements
4. **Optimize**: Profile and optimize hot paths
5. **Integrate**: Connect with your quantum workflows

## Resources

- **F# Documentation**: https://fsharp.org/
- **F# for Fun and Profit**: https://fsharpforfunandprofit.com/
- **.NET API Docs**: https://docs.microsoft.com/dotnet/fsharp/
- **F# Slack**: https://fsharp.org/guides/slack/
- **Complex Numbers in .NET**: https://docs.microsoft.com/dotnet/api/system.numerics.complex

## Getting Help

If you encounter issues:

1. **Check the README.md**: Detailed documentation
2. **Read COMPARISON.md**: Understand design decisions
3. **F# Community**: Post on F# Slack or Stack Overflow
4. **GitHub Issues**: Report bugs or request features

## About This Implementation

Created as a demonstration of functional programming principles applied to quantum cellular automata. The code emphasizes:

- **Type Safety**: Compile-time guarantees of quantum mechanics
- **Immutability**: Pure functional transformations
- **Composability**: Functions that naturally combine
- **Mathematical Elegance**: Code that reads like equations

Perfect for:
- Learning F# and functional programming
- Understanding quantum cellular automata
- Building production quantum algorithms
- Teaching quantum computing concepts

Happy quantum computing! 🌌⚛️
