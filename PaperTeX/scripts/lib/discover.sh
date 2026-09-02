#!/usr/bin/env bash
# Toolchain discovery shared by setup.sh and preflight_toolchain.sh.
# Sourced, not executed. Sets DISCOVERED_* variables; never writes files.

detect_platform() {
	# Echoes one of: wsl | linux | macos | windows | unknown
	case "$(uname -s 2>/dev/null)" in
		Linux*)
			if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
				echo wsl
			else
				echo linux
			fi
			;;
		Darwin*) echo macos ;;
		MINGW*|MSYS*|CYGWIN*) echo windows ;;
		*) echo unknown ;;
	esac
}

discover_tex() {
	# Sets DISCOVERED_TEX_BIN and DISCOVERED_TEX_KIND (texlive|miktex|override).
	# Honors an existing TEX_BIN_PATH override before probing.
	DISCOVERED_TEX_BIN=""
	DISCOVERED_TEX_KIND=""

	if [[ -n "${TEX_BIN_PATH:-}" ]]; then
		DISCOVERED_TEX_BIN="$TEX_BIN_PATH"
		DISCOVERED_TEX_KIND="override"
		return 0
	fi

	# 1. Native TeX on PATH (Linux TeX Live, macOS MacTeX, WSL TeX Live).
	local found
	if found="$(command -v latexmk 2>/dev/null)" || found="$(command -v pdflatex 2>/dev/null)"; then
		DISCOVERED_TEX_BIN="$(dirname "$found")"
		DISCOVERED_TEX_KIND="texlive"
		return 0
	fi

	# 2. MiKTeX reachable from WSL through Windows interop.
	if [[ "$(detect_platform)" == "wsl" ]]; then
		local candidate
		for candidate in \
			/mnt/*/Users/*/AppData/Local/Programs/MiKTeX/miktex/bin/x64 \
			/mnt/*/Program\ Files/MiKTeX/miktex/bin/x64 \
			/mnt/*/texlive/*/bin/windows
		do
			if [[ -x "$candidate/pdflatex.exe" ]]; then
				DISCOVERED_TEX_BIN="$candidate"
				DISCOVERED_TEX_KIND="miktex"
				return 0
			fi
		done
	fi

	return 1
}

discover_docker() {
	# Sets DISCOVERED_DOCKER to the docker binary path, or empty.
	DISCOVERED_DOCKER=""
	if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
		DISCOVERED_DOCKER="$(command -v docker)"
		return 0
	fi
	return 1
}

tex_version_string() {
	# tex_version_string <bin-dir> [kind]
	# Probes both names so an overridden TEX_BIN_PATH works on any platform.
	local bin="$1" exe
	for exe in pdflatex pdflatex.exe; do
		if [[ -x "$bin/$exe" ]]; then
			"$bin/$exe" --version 2>/dev/null | head -1
			return 0
		fi
	done
	return 1
}
