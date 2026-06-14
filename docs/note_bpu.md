# Horizon OpenExplorer & BPU Setup Notes

This document captures the setup process, Docker configurations, and the general model compilation workflow for Horizon Robotics BPU (specifically targeting the X5 CPU/BPU platform).

---

## 💻 Environment Overview
- **Host OS:** macOS (Apple Silicon M1/M2/M3/M4)
- **Container Architecture:** `linux/amd64` (Running via Rosetta 2 emulation)
- **Docker Toolchain Image:** `registry.d-robotics.cc/deliver/ai_toolchain_ubuntu_20_x5_cpu:v1.2.8`

---

## 🛠️ Step 1: Docker Registry Authentication & Pull
Before the image can be pulled, authenticate with the D-Robotics/Horizon container registry using developer community credentials:

```bash
# Log in to the registry
docker login -u "ccr\$deliver-ronly" registry.d-robotics.cc -p 'VLaeatrjF9yGf6I44trT74zKhUpZSVlr'

# Pull the specific X5 toolchain image (linux/amd64 platform required on Mac)
docker pull --platform linux/amd64 registry.d-robotics.cc/deliver/ai_toolchain_ubuntu_20_x5_cpu:v1.2.8
```

> [!TIP]
> The backslash `\` before the `$` in the username `ccr\$deliver-ronly` is critical to escape the character in most shells (Zsh/Bash).

---

## 🚀 Step 2: Running the Container
A helper script [run_openexplorer.sh](file:///Users/hengnguan/sandbox/bpu_setup/scripts/run_openexplorer.sh) has been created to easily launch the toolchain container with directory mounts.

### Startup Script Details
The script executes:
```bash
docker run -it --rm \
    --platform linux/amd64 \
    -v "$SCRIPT_DIR":/workspace \
    -w /workspace \
    registry.d-robotics.cc/deliver/ai_toolchain_ubuntu_20_x5_cpu:v1.2.8 \
    /bin/bash
```

### Key Parameters:
* `--platform linux/amd64`: Forces Docker to run the container using x86_64 emulation via Rosetta 2.
* `-v "$SCRIPT_DIR":/workspace`: Mounts this local folder (`bpu_setup`) into `/workspace` inside the container. Anything placed in this folder is visible inside Docker.
* `-w /workspace`: Sets the default working directory inside the container to `/workspace`.

### Launching:
From your host terminal, run:
```bash
chmod +x scripts/run_openexplorer.sh
./scripts/run_openexplorer.sh
```

---

## 🔄 Step 3: OpenExplorer Model Conversion Workflow (Inside Docker)
Once inside the container, you can convert floating-point models (e.g., ONNX) into BPU-optimized fixed-point models (`.bin`).

### 📦 Typical OpenExplorer Folder Structure:
When using OpenExplorer, it is recommended to set up your workspace as follows:
```text
bpu_setup/
├── bpu_setup.code-workspace # IDE workspace configuration
├── readme.md              # Performance report and instructions
├── configs/               # BPU compiler configuration files
│   ├── config.yaml
│   └── ...
├── scripts/               # Python & Shell scripts
│   ├── generate_model.py
│   ├── run_comparisons.py
│   ├── run_openexplorer.sh
│   └── open_devcontainer.command
├── docs/                  # Documentation and development skills
│   ├── note_bpu.md
│   ├── model_convert.md
│   └── skills.md
├── models/                # Input float32 ONNX models
├── data/                  # Calibration datasets
├── logs/                  # Compilation and perf logs (ignored by git)
└── workspace/             # Compiler outputs and performance profiling results
```

### 📋 Model Compilation Stages:

1. **Verify the ONNX Model**
   Use the toolchain checker to verify whether the nodes in your ONNX model are supported by the BPU hardware:
   ```bash
   hb_mapper checker --model-type onnx --model models/your_model.onnx --march x5
   ```

2. **Prepare Configuration file (`config.yaml`)**
   Create a configuration YAML file defining:
   - **Model Info:** Input/output node names, shapes, and layout (NHWC/NCHW).
   - **Quantization Parameters:** Calibration data path, quantization algorithm (KL/Max), target precision (int8/int16).
   - **Build Target:** Chip architecture (`x5`).

3. **Perform Calibration & Compilation**
   Compile the model using `hb_mapper`:
   ```bash
   hb_mapper compile --config config.yaml
   ```
   This generates the optimized binary file (`your_model.bin`) and diagnostic files showing mapping status and quantization loss.

4. **Run Simulation Inference**
   Test and profile the compiled model on the host using the emulator:
   ```bash
   hb_perf your_model.bin
   ```

---

## 🐳 Dev Container (Remote Development in IDE)
To directly open and edit files in your workspace while running inside the toolchain container, we have configured a **Dev Container** under `.devcontainer/`.

### How to use:
1. Open the `/Users/hengnguan/sandbox/bpu_setup` folder in **Antigravity IDE** or VS Code.
2. The IDE will automatically detect the `.devcontainer` configuration and show a pop-up: 
   > "Reopen in Container"
3. Alternatively, open the Command Palette (`Cmd+Shift+P` on macOS) and run:
   > `Dev Containers: Reopen in Container`
4. The IDE will build the container from the local `.devcontainer/Dockerfile`, install recommended extension configurations (C++, Python, YAML), and connect your terminal and editor session directly into `/workspace` inside the container.

