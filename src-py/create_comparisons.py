"""
Create a visual comparison chart of Python vs F# for Quantum Game of Life
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import numpy as np

def create_comparison_chart():
    """Create a visual comparison of Python vs F# features."""
    
    fig, ax = plt.subplots(figsize=(14, 10))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Title
    ax.text(5, 11.5, 'Python vs F# for Quantum Game of Life', 
            ha='center', va='top', fontsize=20, fontweight='bold')
    
    # Categories and scores (out of 10)
    categories = [
        'Type Safety',
        'Immutability',
        'Performance',
        'Visualization',
        'Ecosystem',
        'Learning Curve',
        'Mathematical Elegance',
        'Concurrency',
        'Memory Safety',
        'Composability'
    ]
    
    python_scores = [4, 5, 8, 10, 10, 9, 7, 5, 6, 7]
    fsharp_scores = [10, 10, 8, 5, 6, 6, 10, 9, 10, 10]
    
    # Draw comparison bars
    bar_height = 0.35
    y_positions = np.linspace(10, 1, len(categories))
    
    for i, (category, py_score, fs_score, y_pos) in enumerate(
        zip(categories, python_scores, fsharp_scores, y_positions)):
        
        # Category label
        ax.text(0.5, y_pos, category, ha='right', va='center', 
                fontsize=11, fontweight='bold')
        
        # Python bar
        python_bar = FancyBboxPatch((1, y_pos - bar_height/2), 
                                   py_score * 0.35, bar_height,
                                   boxstyle="round,pad=0.05",
                                   edgecolor='#3776ab', 
                                   facecolor='#3776ab',
                                   alpha=0.7)
        ax.add_patch(python_bar)
        ax.text(1 + py_score * 0.35 + 0.1, y_pos, f'{py_score}/10',
                va='center', fontsize=9, color='#3776ab', fontweight='bold')
        
        # F# bar
        fsharp_bar = FancyBboxPatch((5, y_pos - bar_height/2), 
                                    fs_score * 0.35, bar_height,
                                    boxstyle="round,pad=0.05",
                                    edgecolor='#378bba',
                                    facecolor='#378bba',
                                    alpha=0.7)
        ax.add_patch(fsharp_bar)
        ax.text(5 + fs_score * 0.35 + 0.1, y_pos, f'{fs_score}/10',
                va='center', fontsize=9, color='#378bba', fontweight='bold')
    
    # Column headers
    ax.text(2.75, 10.8, 'Python', ha='center', fontsize=14, 
            fontweight='bold', color='#3776ab')
    ax.text(6.75, 10.8, 'F#', ha='center', fontsize=14,
            fontweight='bold', color='#378bba')
    
    # Overall scores
    python_total = sum(python_scores)
    fsharp_total = sum(fsharp_scores)
    
    # Summary box
    summary_y = 0.3
    summary_box = FancyBboxPatch((1, summary_y - 0.3), 8, 0.6,
                                boxstyle="round,pad=0.1",
                                edgecolor='gray',
                                facecolor='lightgray',
                                alpha=0.3)
    ax.add_patch(summary_box)
    
    ax.text(5, summary_y + 0.15, 'Overall Scores', ha='center', 
            fontsize=12, fontweight='bold')
    ax.text(3, summary_y - 0.1, f'Python: {python_total}/100', 
            ha='center', fontsize=11, color='#3776ab', fontweight='bold')
    ax.text(7, summary_y - 0.1, f'F#: {fsharp_total}/100',
            ha='center', fontsize=11, color='#378bba', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('/mnt/user-data/outputs/python_vs_fsharp_comparison.png', 
                dpi=150, bbox_inches='tight', facecolor='white')
    print("Saved comparison chart")

def create_architecture_diagram():
    """Create architecture comparison diagram."""
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))
    
    # Python Architecture
    ax1.set_xlim(0, 10)
    ax1.set_ylim(0, 10)
    ax1.axis('off')
    ax1.set_title('Python Architecture', fontsize=16, fontweight='bold', 
                  color='#3776ab', pad=20)
    
    # Python boxes
    boxes_py = [
        ('NumPy Arrays', 5, 8.5, '#ffd43b'),
        ('Mutable State', 5, 7, '#ff6b6b'),
        ('Class Methods', 5, 5.5, '#4ecdc4'),
        ('Imperative Loops', 5, 4, '#95e1d3'),
        ('Runtime Type Checks', 5, 2.5, '#f38181'),
        ('matplotlib', 5, 1, '#aa96da'),
    ]
    
    for label, x, y, color in boxes_py:
        box = FancyBboxPatch((x-1.5, y-0.3), 3, 0.6,
                            boxstyle="round,pad=0.1",
                            edgecolor='black',
                            facecolor=color,
                            alpha=0.7)
        ax1.add_patch(box)
        ax1.text(x, y, label, ha='center', va='center', 
                fontsize=10, fontweight='bold')
        
        # Draw arrows
        if y > 1:
            ax1.arrow(x, y-0.4, 0, -0.5, head_width=0.2, 
                     head_length=0.1, fc='gray', ec='gray')
    
    # F# Architecture
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 10)
    ax2.axis('off')
    ax2.set_title('F# Architecture', fontsize=16, fontweight='bold',
                  color='#378bba', pad=20)
    
    # F# boxes
    boxes_fs = [
        ('Immutable Records', 5, 8.5, '#ffd43b'),
        ('Pure Functions', 5, 7, '#51cf66'),
        ('Type-Safe Domain', 5, 5.5, '#4ecdc4'),
        ('Functional Pipelines', 5, 4, '#95e1d3'),
        ('Compile-Time Checks', 5, 2.5, '#51cf66'),
        ('CSV Export → Python', 5, 1, '#aa96da'),
    ]
    
    for label, x, y, color in boxes_fs:
        box = FancyBboxPatch((x-1.5, y-0.3), 3, 0.6,
                            boxstyle="round,pad=0.1",
                            edgecolor='black',
                            facecolor=color,
                            alpha=0.7)
        ax2.add_patch(box)
        ax2.text(x, y, label, ha='center', va='center',
                fontsize=10, fontweight='bold')
        
        # Draw arrows
        if y > 1:
            ax2.arrow(x, y-0.4, 0, -0.5, head_width=0.2,
                     head_length=0.1, fc='gray', ec='gray')
    
    plt.tight_layout()
    plt.savefig('/mnt/user-data/outputs/architecture_comparison.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    print("Saved architecture diagram")

def create_use_case_matrix():
    """Create a use case recommendation matrix."""
    
    fig, ax = plt.subplots(figsize=(12, 10))
    ax.axis('tight')
    ax.axis('off')
    
    # Title
    fig.suptitle('When to Use Python vs F# for Quantum Computing',
                fontsize=16, fontweight='bold', y=0.98)
    
    # Table data
    scenarios = [
        ['Scenario', 'Python', 'F#', 'Recommendation'],
        ['Research & Exploration', '⭐⭐⭐⭐⭐', '⭐⭐⭐', 'Python'],
        ['Production Code', '⭐⭐⭐', '⭐⭐⭐⭐⭐', 'F#'],
        ['Quick Prototype', '⭐⭐⭐⭐⭐', '⭐⭐⭐', 'Python'],
        ['Type Safety Critical', '⭐⭐', '⭐⭐⭐⭐⭐', 'F#'],
        ['Teaching/Education', '⭐⭐⭐⭐⭐', '⭐⭐⭐', 'Python'],
        ['Long-term Maintenance', '⭐⭐⭐', '⭐⭐⭐⭐⭐', 'F#'],
        ['Visualization Heavy', '⭐⭐⭐⭐⭐', '⭐⭐', 'Python'],
        ['Mathematical Proof', '⭐⭐⭐', '⭐⭐⭐⭐⭐', 'F#'],
        ['Team Collaboration', '⭐⭐⭐⭐', '⭐⭐⭐⭐', 'Both'],
        ['Integration with Qiskit', '⭐⭐⭐⭐⭐', '⭐⭐', 'Python'],
        ['Azure Quantum', '⭐⭐⭐', '⭐⭐⭐⭐⭐', 'F#'],
        ['Parallel Computing', '⭐⭐⭐', '⭐⭐⭐⭐⭐', 'F#'],
    ]
    
    # Color mapping
    colors = []
    for row in scenarios:
        if row[0] == 'Scenario':
            colors.append(['lightgray'] * 4)
        elif row[3] == 'Python':
            colors.append(['white', '#e3f2fd', 'white', '#bbdefb'])
        elif row[3] == 'F#':
            colors.append(['white', 'white', '#e1f5fe', '#b3e5fc'])
        else:
            colors.append(['white', '#f3e5f5', '#f3e5f5', '#e1bee7'])
    
    table = ax.table(cellText=scenarios,
                    cellLoc='center',
                    loc='center',
                    cellColours=colors,
                    colWidths=[0.3, 0.2, 0.2, 0.2])
    
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1, 2)
    
    # Style header row
    for i in range(4):
        cell = table[(0, i)]
        cell.set_text_props(weight='bold', size=11)
        cell.set_facecolor('lightgray')
    
    plt.tight_layout()
    plt.savefig('/mnt/user-data/outputs/use_case_matrix.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    print("Saved use case matrix")

if __name__ == "__main__":
    create_comparison_chart()
    create_architecture_diagram()
    create_use_case_matrix()
    print("\nAll comparison visualizations created!")
