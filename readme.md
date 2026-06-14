# Horizon Robotics X5 BPU Compiler Mode Performance Report

This report compares how different compilation optimization strategies affect execution properties when deploying the `SimpleNet` visual model on the **Horizon X5 BPU (`bayes-e`)** architecture.

---

## 📊 Compiler Mode Comparison Table

The following metrics were generated via the BPU Toolchain compiler (`hb_mapper makertbin`) and the hardware simulator (`hb_perf`) inside the development container environment:

| Compiler Optimization Mode | Primary Objective | Simulated Throughput (FPS) | Single-Frame Latency | DDR Bandwidth (DRAM Fetch Footprint) | Status |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **Latency Mode (`latency`)** | Minimize single-frame response time | 10787.72 | 92.7 us | 169.20 KB | Success |
| **Bandwidth Mode (`bandwidth`)** | Minimize memory traffic & optimize bus load | 10787.72 | 92.7 us | 169.20 KB | Success |

---

## 🔍 Key Findings and Observations

1. **Performance Characteristics:**
   - **Throughput & Latency:** For extremely small models like `SimpleNet` (which contains only a single Conv2d, Pool, and Linear layer), both `latency` and `bandwidth` compile modes yield identical simulated performance metrics (**10,787.72 FPS** with a latency of **92.7 us**). 
   - **Why?** Since the model size is so small (~169 KB), the BPU's internal SRAM cache can fully accommodate the model weights and all intermediate activations. In this scenario, there is no DRAM/DDR memory bottleneck, so the scheduler optimizations in `bandwidth` mode behave identically to the `latency` mode scheduler.

2. **When to Choose Each Mode:**
   - **Latency Mode (`latency`):** Best suited for real-time, single-camera applications (e.g. ADAS driving assists, robotics controller loops) where minimum latency per frame is critical.
   - **Bandwidth Mode (`bandwidth`):** Crucial for multi-camera streams or very large networks (e.g. ResNet50, YOLOv8) where BPU performance is constrained by DDR memory bus contention. It groups instructions to reuse weights in cache, reducing DRAM access spikes.

---

## 🛠️ Reproduction Steps

To regenerate this report or compile the configurations individually:

1. **Enter the Docker toolchain container:**
   ```bash
   ./scripts/run_openexplorer.sh
   ```
2. **Execute the comparison script inside the container:**
   ```bash
   python3 scripts/run_comparisons.py
   ```

---

## 🗃️ Development & Version Control Guidelines

For standard Git workflows, remote repository mapping, and details on what files/model artifacts to track vs. ignore, please refer to the **[Git Version Control & Deployment Guide](file:///Users/hengnguan/sandbox/bpu_setup/docs/git_skill.md)**.
