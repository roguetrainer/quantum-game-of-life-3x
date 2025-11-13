# Quantum Game of Life - Makefile
# =================================
#
# Convenient commands for building, running, and testing the Quantum Game of Life
#
# Usage:
#   make setup       # Full setup (Python + F#)
#   make run-python  # Run Python implementation
#   make run-fsharp  # Run F# implementation
#   make help        # Show all available commands

.PHONY: help setup install-python install-fsharp build test clean run-python run-fsharp visualize all

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

################################################################################
# Help
################################################################################

help: ## Show this help message
	@echo ""
	@echo "$(BLUE)Quantum Game of Life - Available Commands$(NC)"
	@echo "$(BLUE)===========================================$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

################################################################################
# Setup and Installation
################################################################################

setup: ## Complete setup (Python + F#)
	@echo "$(BLUE)Running complete setup...$(NC)"
	@chmod +x setup.sh
	@./setup.sh

setup-python: ## Setup Python only
	@echo "$(BLUE)Setting up Python environment...$(NC)"
	@chmod +x setup.sh
	@./setup.sh --python-only

setup-fsharp: ## Setup F# only
	@echo "$(BLUE)Setting up F# environment...$(NC)"
	@chmod +x setup.sh
	@./setup.sh --fsharp-only

install-deps: ## Install all dependencies
	@echo "$(BLUE)Installing Python dependencies...$(NC)"
	@pip install -r requirements.txt
	@echo "$(BLUE)Restoring .NET packages...$(NC)"
	@dotnet restore QuantumGameOfLife.fsproj

################################################################################
# Python Commands
################################################################################

venv: ## Create Python virtual environment
	@echo "$(BLUE)Creating virtual environment...$(NC)"
	@python3 -m venv venv
	@echo "$(GREEN)Virtual environment created. Activate with: source venv/bin/activate$(NC)"

install-python: venv ## Install Python dependencies
	@echo "$(BLUE)Installing Python packages...$(NC)"
	@. venv/bin/activate && pip install --upgrade pip
	@. venv/bin/activate && pip install -r requirements.txt
	@echo "$(GREEN)Python dependencies installed$(NC)"

run-python: ## Run Python implementation
	@echo "$(BLUE)Running Python Quantum Game of Life...$(NC)"
	@python3 quantum_game_of_life.py

test-python: ## Test Python implementation
	@echo "$(BLUE)Testing Python implementation...$(NC)"
	@python3 -m pytest tests/ -v || echo "$(YELLOW)Tests not found or failed$(NC)"

################################################################################
# F# Commands
################################################################################

install-fsharp: ## Install F#/.NET dependencies
	@echo "$(BLUE)Restoring .NET packages...$(NC)"
	@dotnet restore QuantumGameOfLife.fsproj

build: ## Build F# project
	@echo "$(BLUE)Building F# project...$(NC)"
	@dotnet build QuantumGameOfLife.fsproj
	@echo "$(GREEN)Build complete$(NC)"

build-release: ## Build F# project in release mode
	@echo "$(BLUE)Building F# project (Release)...$(NC)"
	@dotnet build -c Release QuantumGameOfLife.fsproj
	@echo "$(GREEN)Release build complete$(NC)"

run-fsharp: ## Run F# implementation
	@echo "$(BLUE)Running F# Quantum Game of Life...$(NC)"
	@dotnet run --project QuantumGameOfLife.fsproj

run-fsharp-release: build-release ## Run F# implementation (optimized)
	@echo "$(BLUE)Running F# Quantum Game of Life (Release)...$(NC)"
	@dotnet run -c Release --project QuantumGameOfLife.fsproj

fsi: ## Start F# Interactive
	@echo "$(BLUE)Starting F# Interactive...$(NC)"
	@echo "$(YELLOW)Load the project with: #load \"QuantumGameOfLife.fs\";;$(NC)"
	@dotnet fsi

test-fsharp: ## Test F# implementation
	@echo "$(BLUE)Testing F# implementation...$(NC)"
	@dotnet test || echo "$(YELLOW)No tests found$(NC)"

################################################################################
# Visualization and Analysis
################################################################################

visualize: ## Visualize F# results with Python
	@echo "$(BLUE)Creating visualizations...$(NC)"
	@python3 visualize_fsharp.py

compare: ## Generate comparison charts
	@echo "$(BLUE)Generating comparison charts...$(NC)"
	@python3 create_comparisons.py

################################################################################
# Run All
################################################################################

all: run-python run-fsharp visualize ## Run everything (Python, F#, visualize)
	@echo "$(GREEN)All tasks completed!$(NC)"

################################################################################
# Testing and Verification
################################################################################

verify: ## Verify installation
	@echo "$(BLUE)Verifying installation...$(NC)"
	@chmod +x setup.sh
	@./setup.sh --verify-only

test: test-python test-fsharp ## Run all tests

benchmark: ## Run performance benchmarks
	@echo "$(BLUE)Running benchmarks...$(NC)"
	@echo "Python:"
	@time python3 quantum_game_of_life.py > /dev/null 2>&1
	@echo "F#:"
	@time dotnet run --project QuantumGameOfLife.fsproj > /dev/null 2>&1

################################################################################
# Documentation
################################################################################

docs: ## Open documentation in browser
	@echo "$(BLUE)Opening documentation...$(NC)"
	@if command -v xdg-open > /dev/null; then \
		xdg-open INDEX.md; \
	elif command -v open > /dev/null; then \
		open INDEX.md; \
	else \
		echo "$(YELLOW)Please open INDEX.md manually$(NC)"; \
	fi

readme: ## View README
	@cat README.md

quickstart: ## View Quick Start guide
	@cat QUICKSTART.md

################################################################################
# Cleaning
################################################################################

clean: ## Clean build artifacts and cache
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	@rm -rf bin obj
	@rm -rf __pycache__ *.pyc
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)Clean complete$(NC)"

clean-all: clean ## Clean everything including venv and outputs
	@echo "$(BLUE)Cleaning everything...$(NC)"
	@rm -rf venv
	@rm -f quantum_state_step_*.csv
	@rm -f *.png
	@echo "$(GREEN)Deep clean complete$(NC)"

################################################################################
# Development
################################################################################

format: ## Format code (if formatters installed)
	@echo "$(BLUE)Formatting code...$(NC)"
	@if command -v black > /dev/null; then \
		black *.py; \
	else \
		echo "$(YELLOW)black not installed, skipping Python formatting$(NC)"; \
	fi
	@if command -v fantomas > /dev/null; then \
		fantomas QuantumGameOfLife.fs; \
	else \
		echo "$(YELLOW)fantomas not installed, skipping F# formatting$(NC)"; \
	fi

lint: ## Lint code (if linters installed)
	@echo "$(BLUE)Linting code...$(NC)"
	@if command -v pylint > /dev/null; then \
		pylint *.py || true; \
	else \
		echo "$(YELLOW)pylint not installed, skipping Python linting$(NC)"; \
	fi

watch-fsharp: ## Watch F# files and rebuild on change
	@echo "$(BLUE)Watching F# files...$(NC)"
	@dotnet watch --project QuantumGameOfLife.fsproj run

################################################################################
# Distribution
################################################################################

package: build-release ## Create distribution package
	@echo "$(BLUE)Creating distribution package...$(NC)"
	@mkdir -p dist
	@cp QuantumGameOfLife.fs dist/
	@cp QuantumGameOfLife.fsproj dist/
	@cp quantum_game_of_life.py dist/
	@cp requirements.txt dist/
	@cp setup.sh dist/
	@cp setup.ps1 dist/
	@cp Makefile dist/
	@cp *.md dist/
	@tar -czf quantum-game-of-life.tar.gz dist/
	@echo "$(GREEN)Package created: quantum-game-of-life.tar.gz$(NC)"

################################################################################
# Interactive
################################################################################

demo: ## Run interactive demo
	@echo "$(BLUE)Running interactive demo...$(NC)"
	@echo "1. Running Python implementation..."
	@python3 quantum_game_of_life.py
	@echo ""
	@echo "2. Running F# implementation..."
	@dotnet run --project QuantumGameOfLife.fsproj
	@echo ""
	@echo "3. Creating visualizations..."
	@python3 visualize_fsharp.py
	@echo ""
	@echo "$(GREEN)Demo complete! Check the generated PNG files.$(NC)"

info: ## Show project information
	@echo ""
	@echo "$(BLUE)Quantum Game of Life - Project Information$(NC)"
	@echo "$(BLUE)===========================================$(NC)"
	@echo ""
	@echo "Python implementation:    quantum_game_of_life.py"
	@echo "F# implementation:        QuantumGameOfLife.fs"
	@echo "Project file:             QuantumGameOfLife.fsproj"
	@echo ""
	@echo "Dependencies:"
	@echo "  Python packages:        requirements.txt"
	@echo "  .NET SDK:              >= 8.0"
	@echo ""
	@echo "Documentation:"
	@echo "  Getting started:        00_START_HERE.txt"
	@echo "  Overview:              INDEX.md"
	@echo "  Quick start:           QUICKSTART.md"
	@echo "  Technical docs:        README.md"
	@echo "  Comparison:            COMPARISON.md"
	@echo ""
	@echo "Setup scripts:"
	@echo "  Linux/macOS:           setup.sh"
	@echo "  Windows:               setup.ps1"
	@echo "  Build automation:      Makefile (this file)"
	@echo ""
