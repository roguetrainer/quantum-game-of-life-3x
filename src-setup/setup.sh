#!/bin/bash

################################################################################
# Quantum Game of Life - Setup Script
# ====================================
#
# This script sets up the complete environment for running both Python and F#
# implementations of the Quantum Game of Life.
#
# Usage:
#   chmod +x setup.sh
#   ./setup.sh
#
# Options:
#   ./setup.sh --python-only    # Install only Python dependencies
#   ./setup.sh --fsharp-only    # Install only F#/.NET dependencies
#   ./setup.sh --help           # Show help message
#
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTNET_VERSION="8.0"
PYTHON_MIN_VERSION="3.8"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

################################################################################
# OS Detection
################################################################################

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
            OS_VERSION=$VERSION_ID
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
    
    print_info "Detected OS: $OS"
}

################################################################################
# Python Setup
################################################################################

check_python() {
    print_header "Checking Python Installation"
    
    if check_command python3; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        print_success "Python found: $PYTHON_VERSION"
        
        # Check if version is sufficient
        REQUIRED_VERSION=$PYTHON_MIN_VERSION
        if python3 -c "import sys; exit(0 if sys.version_info >= tuple(map(int, '$REQUIRED_VERSION'.split('.'))) else 1)"; then
            print_success "Python version is sufficient (>= $PYTHON_MIN_VERSION)"
            return 0
        else
            print_warning "Python version $PYTHON_VERSION is below recommended $PYTHON_MIN_VERSION"
            return 1
        fi
    elif check_command python; then
        PYTHON_VERSION=$(python --version | cut -d' ' -f2)
        print_warning "Found 'python' but not 'python3'. Version: $PYTHON_VERSION"
        return 1
    else
        print_error "Python not found"
        return 1
    fi
}

install_python() {
    print_header "Installing Python"
    
    case $OS in
        ubuntu|debian)
            print_info "Installing Python via apt..."
            sudo apt update
            sudo apt install -y python3 python3-pip python3-venv
            ;;
        fedora|rhel|centos)
            print_info "Installing Python via dnf/yum..."
            sudo dnf install -y python3 python3-pip || sudo yum install -y python3 python3-pip
            ;;
        macos)
            if check_command brew; then
                print_info "Installing Python via Homebrew..."
                brew install python3
            else
                print_error "Homebrew not found. Please install from https://brew.sh/"
                return 1
            fi
            ;;
        *)
            print_error "Automatic Python installation not supported for $OS"
            print_info "Please install Python manually from https://www.python.org/"
            return 1
            ;;
    esac
    
    print_success "Python installation complete"
}

setup_python_venv() {
    print_header "Setting Up Python Virtual Environment"
    
    if [ -d "venv" ]; then
        print_warning "Virtual environment already exists"
        read -p "Do you want to recreate it? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf venv
        else
            print_info "Using existing virtual environment"
            return 0
        fi
    fi
    
    print_info "Creating virtual environment..."
    python3 -m venv venv
    
    print_success "Virtual environment created"
}

install_python_deps() {
    print_header "Installing Python Dependencies"
    
    # Activate virtual environment if it exists
    if [ -d "venv" ]; then
        print_info "Activating virtual environment..."
        source venv/bin/activate
    fi
    
    # Upgrade pip
    print_info "Upgrading pip..."
    python3 -m pip install --upgrade pip setuptools wheel
    
    # Install requirements
    if [ -f "requirements.txt" ]; then
        print_info "Installing packages from requirements.txt..."
        pip install -r requirements.txt
        print_success "Python dependencies installed"
    else
        print_warning "requirements.txt not found, installing core packages..."
        pip install numpy matplotlib scipy pandas jupyter
        print_success "Core Python packages installed"
    fi
}

################################################################################
# .NET/F# Setup
################################################################################

check_dotnet() {
    print_header "Checking .NET Installation"
    
    if check_command dotnet; then
        DOTNET_VERSION_INSTALLED=$(dotnet --version)
        print_success ".NET SDK found: $DOTNET_VERSION_INSTALLED"
        
        # Check if version is sufficient
        MAJOR_VERSION=$(echo $DOTNET_VERSION_INSTALLED | cut -d'.' -f1)
        if [ "$MAJOR_VERSION" -ge 8 ]; then
            print_success ".NET version is sufficient (>= 8.0)"
            return 0
        else
            print_warning ".NET version $DOTNET_VERSION_INSTALLED is below recommended 8.0"
            return 1
        fi
    else
        print_error ".NET SDK not found"
        return 1
    fi
}

install_dotnet() {
    print_header "Installing .NET SDK"
    
    case $OS in
        ubuntu|debian)
            print_info "Installing .NET SDK via Microsoft package repository..."
            
            # Get Ubuntu version
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                UBUNTU_VERSION=$VERSION_ID
            fi
            
            # Add Microsoft package repository
            wget https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
            sudo dpkg -i packages-microsoft-prod.deb
            rm packages-microsoft-prod.deb
            
            # Install .NET SDK
            sudo apt update
            sudo apt install -y dotnet-sdk-8.0
            ;;
            
        fedora)
            print_info "Installing .NET SDK via dnf..."
            sudo dnf install -y dotnet-sdk-8.0
            ;;
            
        macos)
            if check_command brew; then
                print_info "Installing .NET SDK via Homebrew..."
                brew install --cask dotnet-sdk
            else
                print_error "Homebrew not found. Please install from https://brew.sh/"
                print_info "Or download .NET SDK from https://dotnet.microsoft.com/download"
                return 1
            fi
            ;;
            
        *)
            print_warning "Automatic .NET installation not supported for $OS"
            print_info "Installing .NET SDK via dotnet-install script..."
            
            # Use the official install script
            wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
            chmod +x dotnet-install.sh
            ./dotnet-install.sh --channel 8.0 --install-dir ~/.dotnet
            
            # Add to PATH
            export DOTNET_ROOT=~/.dotnet
            export PATH=$PATH:~/.dotnet
            
            # Add to shell profile
            SHELL_PROFILE=""
            if [ -f ~/.bashrc ]; then
                SHELL_PROFILE=~/.bashrc
            elif [ -f ~/.zshrc ]; then
                SHELL_PROFILE=~/.zshrc
            elif [ -f ~/.profile ]; then
                SHELL_PROFILE=~/.profile
            fi
            
            if [ -n "$SHELL_PROFILE" ]; then
                if ! grep -q "DOTNET_ROOT" "$SHELL_PROFILE"; then
                    echo '' >> "$SHELL_PROFILE"
                    echo '# .NET SDK' >> "$SHELL_PROFILE"
                    echo 'export DOTNET_ROOT=$HOME/.dotnet' >> "$SHELL_PROFILE"
                    echo 'export PATH=$PATH:$DOTNET_ROOT' >> "$SHELL_PROFILE"
                    print_info "Added .NET to $SHELL_PROFILE"
                    print_warning "Please restart your shell or run: source $SHELL_PROFILE"
                fi
            fi
            
            rm dotnet-install.sh
            ;;
    esac
    
    print_success ".NET SDK installation complete"
}

build_fsharp_project() {
    print_header "Building F# Project"
    
    if [ -f "QuantumGameOfLife.fsproj" ]; then
        print_info "Restoring .NET packages..."
        dotnet restore QuantumGameOfLife.fsproj
        
        print_info "Building project..."
        dotnet build QuantumGameOfLife.fsproj
        
        print_success "F# project built successfully"
    else
        print_warning "QuantumGameOfLife.fsproj not found in current directory"
        print_info "Make sure you're in the project directory"
    fi
}

################################################################################
# Verification
################################################################################

verify_installation() {
    print_header "Verifying Installation"
    
    local all_good=true
    
    # Check Python
    if check_command python3; then
        print_success "Python 3 is available"
        
        # Check key packages
        if python3 -c "import numpy, matplotlib, scipy" 2>/dev/null; then
            print_success "Python packages (numpy, matplotlib, scipy) are installed"
        else
            print_error "Some Python packages are missing"
            all_good=false
        fi
    else
        print_error "Python 3 is not available"
        all_good=false
    fi
    
    # Check .NET
    if check_command dotnet; then
        print_success ".NET SDK is available"
        
        # Try to run a simple F# command
        if dotnet fsi --help &>/dev/null; then
            print_success "F# Interactive is available"
        else
            print_warning "F# Interactive might not be properly configured"
        fi
    else
        print_error ".NET SDK is not available"
        all_good=false
    fi
    
    if [ "$all_good" = true ]; then
        print_success "All verifications passed!"
        return 0
    else
        print_warning "Some verifications failed. Please review the errors above."
        return 1
    fi
}

################################################################################
# Test Run
################################################################################

test_installation() {
    print_header "Testing Installation"
    
    # Test Python
    print_info "Testing Python implementation..."
    if [ -f "quantum_game_of_life.py" ]; then
        if python3 quantum_game_of_life.py; then
            print_success "Python implementation runs successfully"
        else
            print_warning "Python implementation encountered errors"
        fi
    else
        print_info "quantum_game_of_life.py not found, skipping Python test"
    fi
    
    # Test F#
    print_info "Testing F# implementation..."
    if [ -f "QuantumGameOfLife.fsproj" ]; then
        if dotnet run --project QuantumGameOfLife.fsproj; then
            print_success "F# implementation runs successfully"
        else
            print_warning "F# implementation encountered errors"
        fi
    else
        print_info "QuantumGameOfLife.fsproj not found, skipping F# test"
    fi
}

################################################################################
# Usage Information
################################################################################

print_usage() {
    cat << EOF
Quantum Game of Life - Setup Script
===================================

Usage: $0 [OPTIONS]

OPTIONS:
    --help              Show this help message
    --python-only       Install only Python dependencies
    --fsharp-only       Install only F#/.NET dependencies
    --no-venv           Don't create Python virtual environment
    --skip-test         Skip test run after installation
    --verify-only       Only verify existing installation

EXAMPLES:
    $0                  # Full setup (Python + F#)
    $0 --python-only    # Setup Python only
    $0 --fsharp-only    # Setup F# only
    $0 --verify-only    # Check what's installed

REQUIREMENTS:
    - Linux, macOS, or Windows with WSL
    - Internet connection for downloading packages
    - sudo access (for some installation methods)

EOF
}

################################################################################
# Main Script
################################################################################

main() {
    # Parse arguments
    PYTHON_ONLY=false
    FSHARP_ONLY=false
    USE_VENV=true
    SKIP_TEST=false
    VERIFY_ONLY=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                print_usage
                exit 0
                ;;
            --python-only)
                PYTHON_ONLY=true
                shift
                ;;
            --fsharp-only)
                FSHARP_ONLY=true
                shift
                ;;
            --no-venv)
                USE_VENV=false
                shift
                ;;
            --skip-test)
                SKIP_TEST=true
                shift
                ;;
            --verify-only)
                VERIFY_ONLY=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
    
    # Print header
    clear
    echo ""
    print_header "Quantum Game of Life - Setup Script"
    echo ""
    
    # Detect OS
    detect_os
    echo ""
    
    # Verify-only mode
    if [ "$VERIFY_ONLY" = true ]; then
        verify_installation
        exit $?
    fi
    
    # Python setup
    if [ "$FSHARP_ONLY" = false ]; then
        if ! check_python; then
            read -p "Python not found or outdated. Install/upgrade? (Y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                install_python
            fi
        fi
        
        if [ "$USE_VENV" = true ]; then
            setup_python_venv
        fi
        
        install_python_deps
        echo ""
    fi
    
    # F# setup
    if [ "$PYTHON_ONLY" = false ]; then
        if ! check_dotnet; then
            read -p ".NET SDK not found or outdated. Install/upgrade? (Y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                install_dotnet
            fi
        fi
        
        build_fsharp_project
        echo ""
    fi
    
    # Verification
    verify_installation
    echo ""
    
    # Test run
    if [ "$SKIP_TEST" = false ]; then
        read -p "Do you want to run a test? (Y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            test_installation
        fi
    fi
    
    # Final message
    echo ""
    print_header "Setup Complete!"
    echo ""
    print_info "Next steps:"
    echo "  1. Activate Python virtual environment: source venv/bin/activate"
    echo "  2. Run Python version: python3 quantum_game_of_life.py"
    echo "  3. Run F# version: dotnet run --project QuantumGameOfLife.fsproj"
    echo "  4. Visualize results: python3 visualize_fsharp.py"
    echo ""
    print_info "For more information, see:"
    echo "  - QUICKSTART.md for detailed instructions"
    echo "  - README.md for technical documentation"
    echo "  - INDEX.md for complete overview"
    echo ""
}

# Run main function
main "$@"
