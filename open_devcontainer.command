#!/bin/bash
# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "--------------------------------------------------------"
echo "Opening BPU Setup Workspace in Dev Container..."
echo "Host Workspace Path: $DIR"
echo "--------------------------------------------------------"

# 1. Try launching using the registered vscode:// URI scheme to open the workspace file
echo "Attempting launch via vscode:// URI scheme..."
if open "vscode://file${DIR}/bpu_setup.code-workspace"; then
    echo "Successfully sent open request to VS Code."
else
    # 2. Fallback to using VS Code CLI 'code' if installed in PATH
    echo "Fallback: Checking for 'code' CLI in PATH..."
    if command -v code >/dev/null 2>&1; then
        code "${DIR}/bpu_setup.code-workspace"
        echo "Launched using 'code' command."
    else
        # 3. Fallback to opening VS Code application bundle directly
        echo "Fallback: Checking for Visual Studio Code App Bundle..."
        if [ -d "/Applications/Visual Studio Code.app" ]; then
            open -b com.microsoft.VSCode --args "${DIR}/bpu_setup.code-workspace"
            echo "Launched using com.microsoft.VSCode Bundle ID."
        else
            echo "Error: Visual Studio Code could not be found or launched."
            echo "Please ensure VS Code is installed."
            read -n 1 -s -r -p "Press any key to exit..."
            exit 1
        fi
    fi
fi

# Pause for 1.5 seconds to display status, then auto-close
sleep 1.5
exit 0
