#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() {
    echo "▶ $1"
}

ok() {
    echo "✅ $1"
}

err() {
    echo "❌ $1" >&2
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

has_working_python() {
    has_cmd "$1" && "$1" -c "import sys" >/dev/null 2>&1
}

run_with_sudo() {
    if has_cmd sudo; then
        sudo "$@"
    else
        "$@"
    fi
}

install_linux_deps() {
    if has_cmd apt-get; then
        log "Installing dependencies with apt-get"
        run_with_sudo apt-get update
        run_with_sudo apt-get install -y python3 python3-pip nodejs npm default-jdk g++
        return
    fi

    if has_cmd dnf; then
        log "Installing dependencies with dnf"
        run_with_sudo dnf install -y python3 python3-pip nodejs java-17-openjdk-devel gcc-c++
        return
    fi

    if has_cmd yum; then
        log "Installing dependencies with yum"
        run_with_sudo yum install -y python3 python3-pip nodejs java-17-openjdk-devel gcc-c++
        return
    fi

    if has_cmd pacman; then
        log "Installing dependencies with pacman"
        run_with_sudo pacman -Sy --noconfirm python python-pip nodejs npm jdk-openjdk gcc
        return
    fi

    err "Unsupported Linux package manager. Install python3, node, javac, and g++ manually."
    exit 1
}

install_macos_deps() {
    if ! has_cmd brew; then
        err "Homebrew not found. Install Homebrew first: https://brew.sh"
        exit 1
    fi
    log "Installing dependencies with Homebrew"
    brew install python node openjdk gcc
}

refresh_windows_path() {
    # After winget/choco installs, binaries may not be in PATH for the current
    # session. Scan well-known install locations and export them.
    local dirs_to_add=""

    # JDK (Eclipse Adoptium / Temurin)
    if ! has_cmd javac; then
        for d in "/c/Program Files/Eclipse Adoptium"/*/bin "/c/Program Files/Java"/*/bin; do
            [ -x "$d/javac.exe" ] || [ -x "$d/javac" ] && { dirs_to_add="$dirs_to_add:$d"; break; }
        done
    fi

    # Node.js
    if ! has_cmd node; then
        for d in "/c/Program Files/nodejs"; do
            [ -x "$d/node.exe" ] || [ -x "$d/node" ] && { dirs_to_add="$dirs_to_add:$d"; break; }
        done
    fi

    # g++ (MSYS2 / MinGW)
    if ! has_cmd g++ && ! has_cmd clang++; then
        for d in "/c/msys64/mingw64/bin" "/c/msys64/ucrt64/bin"; do
            [ -x "$d/g++.exe" ] || [ -x "$d/g++" ] && { dirs_to_add="$dirs_to_add:$d"; break; }
        done
    fi

    if [ -n "$dirs_to_add" ]; then
        export PATH="$PATH$dirs_to_add"
        log "Added to session PATH:$dirs_to_add"
    fi
}

install_windows_deps() {
    if has_cmd winget; then
        log "Installing dependencies with winget"
        winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent || true
        winget install -e --id OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements --silent || true
        winget install -e --id EclipseAdoptium.Temurin.17.JDK --accept-package-agreements --accept-source-agreements --silent || true
        winget install -e --id MSYS2.MSYS2 --accept-package-agreements --accept-source-agreements --silent || true
        refresh_windows_path
        return
    fi

    if has_cmd choco; then
        log "Installing dependencies with Chocolatey"
        choco install -y python nodejs-lts temurin17 mingw
        refresh_windows_path
        return
    fi

    err "No supported Windows package manager found (winget/choco)."
    err "Install python3, node, JDK 17+, and g++ manually."
    exit 1
}

ensure_system_dependencies() {
    local needs_install=false

    if ! has_working_python python3 && ! has_working_python python; then
        needs_install=true
    fi
    if ! has_cmd node; then
        needs_install=true
    fi
    if ! has_cmd javac; then
        needs_install=true
    fi
    if ! has_cmd g++ && ! has_cmd clang++; then
        needs_install=true
    fi

    if [ "$needs_install" = false ]; then
        ok "System dependencies already available"
        return
    fi

    case "$(uname -s)" in
        Linux*) install_linux_deps ;;
        Darwin*) install_macos_deps ;;
        MINGW*|MSYS*|CYGWIN*) install_windows_deps ;;
        *)
            err "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
}

verify_dependencies() {
    if has_working_python python3; then
        ok "python3 found"
    elif has_working_python python; then
        ok "python found"
    else
        err "Python not found"
        exit 1
    fi

    has_cmd node || { err "Node.js not found"; exit 1; }
    ok "node found"

    has_cmd javac || { err "javac not found"; exit 1; }
    ok "javac found"

    if has_cmd g++; then
        ok "g++ found"
    elif has_cmd clang++; then
        ok "clang++ found"
    else
        err "No C++ compiler found"
        exit 1
    fi
}

install_node_dependencies() {
    log "Installing npm dependencies"
    cd "$SCRIPT_DIR"
    npm install
    ok "npm dependencies installed"
}

main() {
    ensure_system_dependencies
    verify_dependencies
    install_node_dependencies
    ok "Setup complete"
}

main "$@"
