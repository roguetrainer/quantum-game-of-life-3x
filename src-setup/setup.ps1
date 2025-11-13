# Quantum Game of Life - Windows Setup Script
# =============================================
#
# This PowerShell script sets up the complete environment for running both 
# Python and F# implementations of the Quantum Game of Life on Windows.
#
# Usage:
#   .\setup.ps1
#
# Options:
#   .\setup.ps1 -PythonOnly    # Install only Python dependencies
#   .\setup.ps1 -FSharpOnly    # Install only F#/.NET dependencies
#   .\setup.ps1 -Help          # Show help message
#

param(
    [switch]$PythonOnly = $false,
    [switch]$FSharpOnly = $false,
    [switch]$NoVenv = $false,
    [switch]$SkipTest = $false,
    [switch]$VerifyOnly = $false,
    [switch]$Help = $false
)

# Configuration
$DotNetVersion = "8.0"
$PythonMinVersion = [version]"3.8.0"

################################################################################
# Helper Functions
################################################################################

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

################################################################################
# Python Setup
################################################################################

function Test-Python {
    Write-Header "Checking Python Installation"
    
    if (Test-CommandExists "python") {
        $pythonVersion = python --version 2>&1
        Write-Success "Python found: $pythonVersion"
        
        # Check version
        $versionMatch = $pythonVersion -match "Python (\d+\.\d+\.\d+)"
        if ($versionMatch) {
            $currentVersion = [version]$matches[1]
            if ($currentVersion -ge $PythonMinVersion) {
                Write-Success "Python version is sufficient (>= $PythonMinVersion)"
                return $true
            }
            else {
                Write-Warning-Custom "Python version $currentVersion is below recommended $PythonMinVersion"
                return $false
            }
        }
    }
    else {
        Write-Error-Custom "Python not found"
        return $false
    }
    
    return $false
}

function Install-Python {
    Write-Header "Installing Python"
    
    Write-Info "Please install Python manually:"
    Write-Info "1. Download from: https://www.python.org/downloads/"
    Write-Info "2. Run the installer"
    Write-Info "3. IMPORTANT: Check 'Add Python to PATH' during installation"
    Write-Info "4. After installation, restart PowerShell and run this script again"
    
    $response = Read-Host "Open Python download page? (Y/n)"
    if ($response -eq "" -or $response -eq "Y" -or $response -eq "y") {
        Start-Process "https://www.python.org/downloads/"
    }
    
    return $false
}

function New-PythonVenv {
    Write-Header "Setting Up Python Virtual Environment"
    
    if (Test-Path "venv") {
        Write-Warning-Custom "Virtual environment already exists"
        $response = Read-Host "Do you want to recreate it? (y/N)"
        if ($response -eq "Y" -or $response -eq "y") {
            Remove-Item -Recurse -Force "venv"
        }
        else {
            Write-Info "Using existing virtual environment"
            return $true
        }
    }
    
    Write-Info "Creating virtual environment..."
    python -m venv venv
    
    Write-Success "Virtual environment created"
    return $true
}

function Install-PythonDependencies {
    Write-Header "Installing Python Dependencies"
    
    # Activate virtual environment if it exists
    if (Test-Path "venv\Scripts\Activate.ps1") {
        Write-Info "Activating virtual environment..."
        & ".\venv\Scripts\Activate.ps1"
    }
    
    # Upgrade pip
    Write-Info "Upgrading pip..."
    python -m pip install --upgrade pip setuptools wheel
    
    # Install requirements
    if (Test-Path "requirements.txt") {
        Write-Info "Installing packages from requirements.txt..."
        pip install -r requirements.txt
        Write-Success "Python dependencies installed"
    }
    else {
        Write-Warning-Custom "requirements.txt not found, installing core packages..."
        pip install numpy matplotlib scipy pandas jupyter
        Write-Success "Core Python packages installed"
    }
    
    return $true
}

################################################################################
# .NET/F# Setup
################################################################################

function Test-DotNet {
    Write-Header "Checking .NET Installation"
    
    if (Test-CommandExists "dotnet") {
        $dotnetVersion = dotnet --version
        Write-Success ".NET SDK found: $dotnetVersion"
        
        # Check version
        $majorVersion = [int]($dotnetVersion -split '\.')[0]
        if ($majorVersion -ge 8) {
            Write-Success ".NET version is sufficient (>= 8.0)"
            return $true
        }
        else {
            Write-Warning-Custom ".NET version $dotnetVersion is below recommended 8.0"
            return $false
        }
    }
    else {
        Write-Error-Custom ".NET SDK not found"
        return $false
    }
}

function Install-DotNet {
    Write-Header "Installing .NET SDK"
    
    Write-Info "Please install .NET SDK manually:"
    Write-Info "1. Download from: https://dotnet.microsoft.com/download"
    Write-Info "2. Choose .NET 8.0 SDK"
    Write-Info "3. Run the installer"
    Write-Info "4. After installation, restart PowerShell and run this script again"
    
    $response = Read-Host "Open .NET download page? (Y/n)"
    if ($response -eq "" -or $response -eq "Y" -or $response -eq "y") {
        Start-Process "https://dotnet.microsoft.com/download"
    }
    
    return $false
}

function Build-FSharpProject {
    Write-Header "Building F# Project"
    
    if (Test-Path "QuantumGameOfLife.fsproj") {
        Write-Info "Restoring .NET packages..."
        dotnet restore QuantumGameOfLife.fsproj
        
        Write-Info "Building project..."
        dotnet build QuantumGameOfLife.fsproj
        
        Write-Success "F# project built successfully"
        return $true
    }
    else {
        Write-Warning-Custom "QuantumGameOfLife.fsproj not found in current directory"
        Write-Info "Make sure you're in the project directory"
        return $false
    }
}

################################################################################
# Verification
################################################################################

function Test-Installation {
    Write-Header "Verifying Installation"
    
    $allGood = $true
    
    # Check Python
    if (Test-CommandExists "python") {
        Write-Success "Python is available"
        
        # Check key packages
        $testScript = @"
import numpy
import matplotlib
import scipy
print("OK")
"@
        $result = python -c $testScript 2>&1
        if ($result -eq "OK") {
            Write-Success "Python packages (numpy, matplotlib, scipy) are installed"
        }
        else {
            Write-Error-Custom "Some Python packages are missing"
            $allGood = $false
        }
    }
    else {
        Write-Error-Custom "Python is not available"
        $allGood = $false
    }
    
    # Check .NET
    if (Test-CommandExists "dotnet") {
        Write-Success ".NET SDK is available"
        
        # Try to run a simple F# command
        $result = dotnet fsi --help 2>&1
        if ($?) {
            Write-Success "F# Interactive is available"
        }
        else {
            Write-Warning-Custom "F# Interactive might not be properly configured"
        }
    }
    else {
        Write-Error-Custom ".NET SDK is not available"
        $allGood = $false
    }
    
    if ($allGood) {
        Write-Success "All verifications passed!"
        return $true
    }
    else {
        Write-Warning-Custom "Some verifications failed. Please review the errors above."
        return $false
    }
}

################################################################################
# Test Run
################################################################################

function Invoke-TestRun {
    Write-Header "Testing Installation"
    
    # Test Python
    Write-Info "Testing Python implementation..."
    if (Test-Path "quantum_game_of_life.py") {
        python quantum_game_of_life.py
        if ($?) {
            Write-Success "Python implementation runs successfully"
        }
        else {
            Write-Warning-Custom "Python implementation encountered errors"
        }
    }
    else {
        Write-Info "quantum_game_of_life.py not found, skipping Python test"
    }
    
    # Test F#
    Write-Info "Testing F# implementation..."
    if (Test-Path "QuantumGameOfLife.fsproj") {
        dotnet run --project QuantumGameOfLife.fsproj
        if ($?) {
            Write-Success "F# implementation runs successfully"
        }
        else {
            Write-Warning-Custom "F# implementation encountered errors"
        }
    }
    else {
        Write-Info "QuantumGameOfLife.fsproj not found, skipping F# test"
    }
}

################################################################################
# Usage Information
################################################################################

function Show-Usage {
    @"
Quantum Game of Life - Windows Setup Script
===========================================

Usage: .\setup.ps1 [OPTIONS]

OPTIONS:
    -Help              Show this help message
    -PythonOnly        Install only Python dependencies
    -FSharpOnly        Install only F#/.NET dependencies
    -NoVenv            Don't create Python virtual environment
    -SkipTest          Skip test run after installation
    -VerifyOnly        Only verify existing installation

EXAMPLES:
    .\setup.ps1                  # Full setup (Python + F#)
    .\setup.ps1 -PythonOnly      # Setup Python only
    .\setup.ps1 -FSharpOnly      # Setup F# only
    .\setup.ps1 -VerifyOnly      # Check what's installed

REQUIREMENTS:
    - Windows 10 or later
    - Internet connection for downloading packages
    - Administrator access (for some installations)

NOTES:
    - You may need to enable script execution:
      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
"@
}

################################################################################
# Main Script
################################################################################

function Main {
    # Show help if requested
    if ($Help) {
        Show-Usage
        return
    }
    
    # Print header
    Clear-Host
    Write-Host ""
    Write-Header "Quantum Game of Life - Windows Setup Script"
    
    # Verify-only mode
    if ($VerifyOnly) {
        Test-Installation
        return
    }
    
    # Python setup
    if (-not $FSharpOnly) {
        if (-not (Test-Python)) {
            $response = Read-Host "Python not found or outdated. Install/upgrade? (Y/n)"
            if ($response -eq "" -or $response -eq "Y" -or $response -eq "y") {
                Install-Python
                Write-Info "Please restart PowerShell after Python installation and run this script again."
                return
            }
        }
        
        if (-not $NoVenv) {
            New-PythonVenv
        }
        
        Install-PythonDependencies
    }
    
    # F# setup
    if (-not $PythonOnly) {
        if (-not (Test-DotNet)) {
            $response = Read-Host ".NET SDK not found or outdated. Install/upgrade? (Y/n)"
            if ($response -eq "" -or $response -eq "Y" -or $response -eq "y") {
                Install-DotNet
                Write-Info "Please restart PowerShell after .NET installation and run this script again."
                return
            }
        }
        
        Build-FSharpProject
    }
    
    # Verification
    Test-Installation
    
    # Test run
    if (-not $SkipTest) {
        $response = Read-Host "Do you want to run a test? (Y/n)"
        if ($response -eq "" -or $response -eq "Y" -or $response -eq "y") {
            Invoke-TestRun
        }
    }
    
    # Final message
    Write-Host ""
    Write-Header "Setup Complete!"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "  1. Activate Python virtual environment: .\venv\Scripts\Activate.ps1"
    Write-Host "  2. Run Python version: python quantum_game_of_life.py"
    Write-Host "  3. Run F# version: dotnet run --project QuantumGameOfLife.fsproj"
    Write-Host "  4. Visualize results: python visualize_fsharp.py"
    Write-Host ""
    Write-Info "For more information, see:"
    Write-Host "  - QUICKSTART.md for detailed instructions"
    Write-Host "  - README.md for technical documentation"
    Write-Host "  - INDEX.md for complete overview"
    Write-Host ""
}

# Run main function
Main
