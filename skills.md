# Horizon BPU / OpenExplorer Development Skills & Best Practices

This document compiles technical insights, key commands, configuration guidelines, and troubleshooting tips for working with the Horizon Robotics BPU (OpenExplorer) toolchain.

---

## 🐋 1. Docker & Emulation Tips (macOS)
- **Apple Silicon Compatibility:** The OpenExplorer toolchain requires an x86_64 architecture (`linux/amd64`). Always specify the `--platform linux/amd64` flag in Docker run commands or within your `devcontainer.json` configuration so Docker can run the container using macOS's Rosetta 2 emulation.
- **Registry Login Credentials:** The D-Robotics username contains a special character (`$`):
  `ccr$deliver-ronly`
  To prevent your shell from interpreting `$deliver-ronly` as an empty environment variable, you must escape it with a backslash:
  ```bash
  docker login -u "ccr\$deliver-ronly" registry.d-robotics.cc -p '<password>'
  ```

---

## 🛠️ 2. Core Toolchain CLI Commands
Horizon provides several utilities in `/usr/local/bin/` inside the Docker image to compile and analyze models:

### 🔍 Model Compatibility Check
Before compiling, verify that all operations in your model are BPU-supported:
```bash
hb_mapper checker --model-type onnx --model <path_to_model.onnx> --march bayes-e
```
*Note: Target march architecture for X5 is `bayes-e`, J5 is `bayes`, and XJ3/X3 is `bernoulli2`.*

### 🔄 Model Compilation
Compile and quantize your model into the Horizon `.bin` format using a configuration file:
```bash
hb_mapper makertbin --config <config.yaml> --model-type onnx
```

### ⚡ Performance Profiling & Simulation
Run a simulated benchmark of the compiled `.bin` model on the BPU emulator to analyze latency, FPS, and DDR memory bandwidth:
```bash
hb_perf <path_to_model.bin>
```
*The output reports overall latency and exports a detailed visualization directory (`hb_perf_result/`).*

---

## 📄 3. Config YAML Schema Reference
When defining the configuration file for `hb_mapper makertbin`, ensure these essential keys are present:

### A. `model_parameters`
- **`onnx_model`:** Path to the float32 ONNX model file.
- **`output_model_file_prefix`:** Base name of the compiled BPU binary output.
- **`march`:** The target BPU architecture (e.g., `bayes-e` for X5, `bayes` for J5).
- **`working_dir`:** Path where intermediate optimization and final binaries are stored.

### B. `input_parameters`
- **`input_name`:** Name of the input node matching the ONNX file.
- **`input_shape`:** Shape of the input tensor (e.g., `'1x3x224x224'`).
- **`input_layout_train` / `input_layout_rt`:** Data layout for training vs. runtime (e.g., `NCHW` or `NHWC`).
- **`input_type_train` / `input_type_rt`:** Input format (e.g., `featuremap` for raw tensors, `rgb`/`bgr` for images, or `nv12` for camera streams).
- **`norm_type`:** Normalization formula (e.g., `no_preprocess` or custom mean/scale constants).

### C. `calibration_parameters`
- **`calibration_type`:** Quantization threshold calculator method. Use `default` for standard KL-divergence quantization. Use `skip` to skip quantization (compiles in floating point mode).
- **`cal_data_dir`:** Folder containing sample calibration files.
- **`cal_data_type`:** Storage format of calibration files (typically `float32` or `uint8`).

---

## 🗃️ 4. Preparing Calibration Data
- **Sample Count:** A set of 20 to 100 representative samples is generally recommended.
- **Format:** Save inputs as raw binaries. In Python, you can convert a numpy array to bytes and save it:
  ```python
  with open("sample.bin", "wb") as f:
      f.write(numpy_array.tobytes())
  ```
- **Verification:** Monitor the **Cosine Similarity** report printed during compilation. A similarity score close to `1.0` (e.g. `>0.99`) indicates low quantization loss, ensuring the quantized BPU model performs identically to the floating-point original.
