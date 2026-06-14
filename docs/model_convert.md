# Horizon BPU Model Conversion Experiment Report

This document records the design, execution steps, and results of a small experiment converting a PyTorch Convolutional Neural Network into a BPU-optimized binary (`.bin`) file targeting the **Horizon X5 BPU** architecture.

---

## 🔬 Experiment Design

### 1. Model Architecture (`SimpleNet`)
We defined and exported a simple visual feature-extraction model:
- **Input:** `input` (Shape: `[1, 3, 224, 224]`, Type: `float32`)
- **Operations:**
  - `Conv2d` (3 channels ➡️ 16 channels, 3x3 kernel, padding=1)
  - `ReLU` activation
  - `GlobalAveragePool2d` (Pooling spatial dimensions `224x224` to `1x1`)
  - `Reshape` (Flattening tensor from `[1, 16, 1, 1]` to `[1, 16]`)
  - `Gemm` (Fully Connected layer mapping 16 features ➡️ 2 output classes)
- **Output:** `output` (Shape: `[1, 2]`, Type: `float32`)

### 2. Dataset Generation
For quantization calibration, we generated:
- **Samples:** 20 random normal noise images (shape `[1, 3, 224, 224]`).
- **Format:** Saved as raw `float32` byte files (`sample_i.bin`) under `data/calibration_data/`.
- **List File:** A list file `data/calibration_list.txt` referencing the paths to the calibration files.

---

## 🏃 Execution Steps

### Step 1: Export the ONNX model & Calibration Data
We ran the script [generate_model.py](file:///Users/hengnguan/sandbox/bpu_setup/scripts/generate_model.py) inside the Docker container to produce the assets:
```bash
docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace \
    --platform linux/amd64 \
    registry.d-robotics.cc/deliver/ai_toolchain_ubuntu_20_x5_cpu:v1.2.8 \
    python3 scripts/generate_model.py
```

### Step 2: Validate Compatibility with BPU Checker
We ran `hb_mapper checker` to ensure all operators in the exported ONNX model are compatible with the `bayes-e` (X5 BPU) architecture:
```bash
docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace \
    --platform linux/amd64 \
    registry.d-robotics.cc/deliver/ai_toolchain_ubuntu_20_x5_cpu:v1.2.8 \
    hb_mapper checker \
    --model-type onnx \
    --model models/simple_net.onnx \
    --march bayes-e
```
*Result: All nodes mapped successfully, showing compatibility.*

### Step 3: Configure Compilation YAML
We defined [config.yaml](file:///Users/hengnguan/sandbox/bpu_setup/configs/config.yaml) to map the model to `int8` quantization using our calibration folder:
- **March:** `bayes-e` (X5 BPU)
- **Input Type:** `featuremap` / `NCHW`
- **Calibration Type:** `default` (uses KL-divergence method with the dummy bin inputs)

### Step 4: Compile Model
We ran `hb_mapper makertbin` to perform the actual quantization calibration and compile the BPU `.bin` file:
```bash
docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace \
    --platform linux/amd64 \
    registry.d-robotics.cc/deliver/ai_toolchain_ubuntu_20_x5_cpu:v1.2.8 \
    hb_mapper makertbin \
    --config configs/config.yaml \
    --model-type onnx
```

---

## 📊 Findings & Quantization Results

The compilation completed successfully, generating the compiled binary at [workspace/model_output/simple_net.bin](file:///Users/hengnguan/sandbox/bpu_setup/workspace/model_output/simple_net.bin).

### 1. BPU Operator Mapping (Node Summary)
The model compiler successfully mapped all computation-heavy nodes directly to the BPU. Only the final output flatten/reshape is deferred to the CPU:

| Node Name | Operator Type | Target Hardware | Quantized Type | Cosine Similarity |
| :--- | :--- | :--- | :--- | :--- |
| `/conv/Conv` | Conv2d | **BPU** | `HzSQuantizedConv` (int8) | `0.999936` |
| `/pool/GlobalAveragePool` | GlobalAveragePool | **BPU** | `HzSQuantizedGlobalAveragePool` (int8) | `0.999994` |
| `/fc/Gemm` | Linear / Gemm | **BPU** | `HzSQuantizedConv` (int8) | `0.999997` |
| `/fc/Gemm_transpose_output_reshape` | Reshape | **CPU** | `Reshape` (float) | *N/A (CPU)* |

> [!NOTE]
> **Cosine Similarity:** The overall output cosine similarity is **`0.999997`**, meaning the BPU `int8` quantized model behaves almost identically to the original `float32` PyTorch model (near-zero quantization loss).

---

## ⚡ Performance Simulation Results (`hb_perf`)
Using the `hb_perf` profiling tool, we simulated execution on the X5 BPU:

- **Frame Rate (throughput):** **`10,787.72 FPS`**
- **Latency (execution time):** **`92.7 us`** (micro-seconds)
- **DDR Memory Bandwidth:** **`173,264 bytes`** (~173 KB)

Detailed visual report generated at: [workspace/model_output/hb_perf_result/simple_net/simple_net.html](file:///Users/hengnguan/sandbox/bpu_setup/workspace/model_output/hb_perf_result/simple_net/simple_net.html)
