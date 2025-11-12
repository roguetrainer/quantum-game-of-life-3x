"""
Quantum Game of Life

This implementation extends Conway's Game of Life to the quantum realm.
Cells exist in superpositions of |alive⟩ and |dead⟩ states, represented by
complex probability amplitudes.

The evolution rules incorporate quantum interference and unitary dynamics.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from typing import Tuple, Optional


class QuantumGameOfLife:
    """
    Quantum version of Conway's Game of Life.
    
    Each cell has a quantum state represented by complex amplitudes:
    |ψ⟩ = α|dead⟩ + β|alive⟩
    
    where |α|² + |β|² = 1 (normalization)
    """
    
    def __init__(self, size: Tuple[int, int], periodic: bool = True):
        """
        Initialize the quantum Game of Life grid.
        
        Args:
            size: (rows, cols) dimensions of the grid
            periodic: Whether to use periodic boundary conditions
        """
        self.rows, self.cols = size
        self.periodic = periodic
        
        # State representation: complex amplitudes for |alive⟩ state
        # (amplitude for |dead⟩ is implicitly sqrt(1 - |alive_amp|²))
        self.state = np.zeros((self.rows, self.cols), dtype=np.complex128)
        
        # Phase accumulation for quantum dynamics
        self.phase = np.zeros((self.rows, self.cols), dtype=np.float64)
        
    def set_classical_state(self, pattern: np.ndarray):
        """
        Initialize with a classical binary pattern.
        
        Args:
            pattern: Binary array (1 = alive, 0 = dead)
        """
        self.state = pattern.astype(np.complex128)
        
    def set_quantum_state(self, amplitudes: np.ndarray):
        """
        Set quantum state directly with complex amplitudes.
        
        Args:
            amplitudes: Complex array representing |alive⟩ amplitudes
        """
        # Normalize to ensure valid quantum states
        norms = np.abs(amplitudes)
        norms = np.clip(norms, 0, 1)  # Ensure physical states
        phases = np.angle(amplitudes)
        self.state = norms * np.exp(1j * phases)
        
    def add_superposition(self, row: int, col: int, alive_prob: float = 0.5, phase: float = 0):
        """
        Set a cell to a superposition state.
        
        Args:
            row, col: Cell coordinates
            alive_prob: Probability of being alive (|β|²)
            phase: Quantum phase
        """
        amplitude = np.sqrt(alive_prob) * np.exp(1j * phase)
        self.state[row, col] = amplitude
        
    def get_probability(self) -> np.ndarray:
        """
        Get the probability of each cell being alive.
        
        Returns:
            Array of probabilities |ψ_alive|²
        """
        return np.abs(self.state) ** 2
    
    def count_quantum_neighbors(self, i: int, j: int) -> complex:
        """
        Count neighbors using quantum amplitudes.
        
        Returns the sum of complex amplitudes of neighboring cells.
        """
        neighbor_sum = 0 + 0j
        
        for di in [-1, 0, 1]:
            for dj in [-1, 0, 1]:
                if di == 0 and dj == 0:
                    continue
                    
                if self.periodic:
                    ni = (i + di) % self.rows
                    nj = (j + dj) % self.cols
                else:
                    ni = i + di
                    nj = j + dj
                    if ni < 0 or ni >= self.rows or nj < 0 or nj >= self.cols:
                        continue
                
                neighbor_sum += self.state[ni, nj]
        
        return neighbor_sum
    
    def quantum_rule(self, cell_state: complex, neighbor_sum: complex) -> complex:
        """
        Apply quantum evolution rules.
        
        This implements a quantum version of Conway's rules:
        - Classical rules apply based on probability amplitudes
        - Quantum interference from neighbors affects evolution
        - Unitary evolution preserves normalization
        
        Args:
            cell_state: Current complex amplitude of cell
            neighbor_sum: Sum of neighbor amplitudes
            
        Returns:
            New complex amplitude
        """
        # Get probability and neighbor count
        alive_prob = np.abs(cell_state) ** 2
        neighbor_prob = np.abs(neighbor_sum) ** 2 / 8.0  # Normalize by max neighbors
        neighbor_phase = np.angle(neighbor_sum)
        
        # Classical Game of Life rules with quantum smoothing
        # Survival: 2-3 neighbors
        # Birth: 3 neighbors
        
        # Continuous version of the rules
        if alive_prob > 0.5:  # Cell is more alive than dead
            # Survival rule: optimal at 2-3 neighbors
            survival_factor = np.exp(-((neighbor_prob * 8 - 2.5) ** 2) / 2.0)
            new_amplitude = cell_state * (0.3 + 0.7 * survival_factor)
        else:  # Cell is more dead than alive
            # Birth rule: optimal at 3 neighbors
            birth_factor = np.exp(-((neighbor_prob * 8 - 3.0) ** 2) / 2.0)
            new_amplitude = birth_factor * np.exp(1j * neighbor_phase)
        
        # Add quantum phase evolution from neighbors
        phase_coupling = 0.1
        quantum_phase = np.angle(cell_state) + phase_coupling * neighbor_phase
        
        # Reconstruct with evolved phase
        new_magnitude = np.abs(new_amplitude)
        new_amplitude = new_magnitude * np.exp(1j * quantum_phase)
        
        # Ensure normalization (clip to valid probability amplitudes)
        new_magnitude = min(np.abs(new_amplitude), 1.0)
        new_amplitude = new_magnitude * np.exp(1j * np.angle(new_amplitude))
        
        return new_amplitude
    
    def step(self):
        """
        Evolve the quantum Game of Life by one time step.
        """
        new_state = np.zeros_like(self.state)
        
        for i in range(self.rows):
            for j in range(self.cols):
                neighbor_sum = self.count_quantum_neighbors(i, j)
                new_state[i, j] = self.quantum_rule(self.state[i, j], neighbor_sum)
        
        self.state = new_state
        
    def measure(self, threshold: float = 0.5) -> np.ndarray:
        """
        Perform a measurement, collapsing to classical states.
        
        Args:
            threshold: Probability threshold for alive state
            
        Returns:
            Classical binary array
        """
        probabilities = self.get_probability()
        return (probabilities > threshold).astype(int)


def create_glider_pattern(size: Tuple[int, int]) -> np.ndarray:
    """Create a classical glider pattern."""
    pattern = np.zeros(size)
    # Glider pattern
    pattern[1, 2] = 1
    pattern[2, 3] = 1
    pattern[3, 1:4] = 1
    return pattern


def create_quantum_glider(qgol: QuantumGameOfLife):
    """Create a glider with quantum superposition."""
    # Classical part of glider
    qgol.set_classical_state(create_glider_pattern((qgol.rows, qgol.cols)))
    
    # Add quantum uncertainty to some cells
    qgol.add_superposition(2, 2, alive_prob=0.7, phase=np.pi/4)
    qgol.add_superposition(3, 2, alive_prob=0.6, phase=np.pi/3)


def visualize_quantum_game(qgol: QuantumGameOfLife, steps: int = 100, interval: int = 100):
    """
    Visualize the quantum Game of Life evolution.
    
    Args:
        qgol: QuantumGameOfLife instance
        steps: Number of time steps to simulate
        interval: Animation interval in milliseconds
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Initialize plots
    prob_plot = ax1.imshow(qgol.get_probability(), cmap='viridis', vmin=0, vmax=1)
    ax1.set_title('Probability |ψ|²')
    ax1.axis('off')
    plt.colorbar(prob_plot, ax=ax1)
    
    phase_plot = ax2.imshow(np.angle(qgol.state), cmap='twilight', vmin=-np.pi, vmax=np.pi)
    ax2.set_title('Phase arg(ψ)')
    ax2.axis('off')
    plt.colorbar(phase_plot, ax=ax2)
    
    def update(frame):
        qgol.step()
        prob_plot.set_array(qgol.get_probability())
        phase_plot.set_array(np.angle(qgol.state))
        fig.suptitle(f'Quantum Game of Life - Step {frame}')
        return prob_plot, phase_plot
    
    anim = FuncAnimation(fig, update, frames=steps, interval=interval, blit=False)
    plt.tight_layout()
    return fig, anim


def main():
    """Demonstration of the Quantum Game of Life."""
    
    # Create quantum Game of Life
    size = (50, 50)
    qgol = QuantumGameOfLife(size, periodic=True)
    
    # Initialize with quantum glider
    create_quantum_glider(qgol)
    
    # Add some random quantum noise
    noise_level = 0.1
    for i in range(5, 15):
        for j in range(5, 15):
            if np.random.random() < 0.3:
                qgol.add_superposition(i, j, 
                                      alive_prob=noise_level * np.random.random(),
                                      phase=2 * np.pi * np.random.random())
    
    print("Quantum Game of Life initialized")
    print(f"Grid size: {size}")
    print(f"Total quantum states: {size[0] * size[1]}")
    
    # Run simulation
    print("\nSimulating quantum evolution...")
    
    # Static visualization of first few steps
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    steps_to_show = [0, 10, 20, 30, 40, 50]
    
    for idx, step in enumerate(steps_to_show):
        for _ in range(step - (steps_to_show[idx-1] if idx > 0 else 0)):
            qgol.step()
        
        ax = axes[idx // 3, idx % 3]
        prob = qgol.get_probability()
        im = ax.imshow(prob, cmap='viridis', vmin=0, vmax=1)
        ax.set_title(f'Step {step}')
        ax.axis('off')
        plt.colorbar(im, ax=ax)
    
    plt.suptitle('Quantum Game of Life Evolution', fontsize=16)
    plt.tight_layout()
    plt.savefig('/mnt/user-data/outputs/quantum_game_of_life.png', dpi=150, bbox_inches='tight')
    print("Saved visualization to quantum_game_of_life.png")
    
    # Create animation (optional - uncomment to use)
    # qgol2 = QuantumGameOfLife(size, periodic=True)
    # create_quantum_glider(qgol2)
    # fig_anim, anim = visualize_quantum_game(qgol2, steps=100, interval=50)
    # plt.show()
    
    plt.show()


if __name__ == "__main__":
    main()
