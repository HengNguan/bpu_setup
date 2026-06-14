# Git Version Control & Deployment Guide

This document captures the Git workflow, staging configurations, and remote deployment guidelines developed for the **Horizon Robotics BPU Setup** project.

---

## 🚀 1. Repository Initialization & Remote Setup

To initialize a new BPU model compiler workspace and connect it to a GitHub remote:

```bash
# 1. Initialize local repository
git init

# 2. Rename default branch to 'main'
git branch -m main

# 3. Add GitHub SSH remote target
git remote add origin git@github.com:HengNguan/bpu_setup.git

# 4. Verify remote endpoints
git remote -v
```

---

## 📄 2. Gitignore Strategy for BPU & Deep Learning Artifacts

Deep learning and hardware compilation projects often generate a large volume of temporary build caches, intermediate files, and massive datasets. It is critical to maintain a targeted `.gitignore` to prevent repository bloat while ensuring critical artifacts are versioned.

### Recommended `.gitignore` Configuration
Create `.gitignore` in the project root:

```text
# Logs
*.log

# OS-specific files
.DS_Store
```

### 🔍 Strategy: What to Track vs. What to Ignore

| Artifact Type | Path / Extension | Action | Rationale |
| :--- | :--- | :--- | :--- |
| **Model Compiler Logs** | `*.log`, `hb_mapper_checker.log` | **Ignore** | Generated dynamically per build; contains transient stdout logs. |
| **Compiled Binaries** | `workspace/**/*.bin` | **Track** | These are the final production artifacts (`.bin` files) deployed to the BPU. |
| **Quantization Reports** | `.hb_check/`, `hb_perf_result/` | **Track** | Contains profiling stats (HTML, PNG, JSON) and cosine similarity checks critical to model regression tracing. |
| **Calibration Data** | `data/calibration_data/` | **Track (with caution)** | Small representative calibration batches (e.g. < 50MB) should be tracked to ensure reproducible quantization. Large datasets (> 100MB) must be ignored or managed via Git LFS. |

---

## 🏃 3. Essential Git Cheat Sheet

Here are the standard commands to manage, stage, and push changes in this repository:

### A. Stage and Commit Changes
Always inspect the size and status of your workspace before committing:
```bash
# Check size of untracked directories
du -sh workspace/ hb_perf_result/

# Review unstaged changes
git status

# Stage all files (respecting .gitignore)
git add .

# Commit with a clear, descriptive message
git commit -m "feat: compile simple_net configurations and save profiling results"
```

### B. Push to GitHub
Push the local commits to the remote tracking branch on GitHub:
```bash
# Push and set upstream tracking for main
git push -u origin main

# Subsequent simple pushes
git push
```

### C. Troubleshooting SSH Connection
To test if your terminal is authenticated and can successfully talk to GitHub via SSH:
```bash
ssh -T git@github.com
```
*Expected Output:*
> `Hi HengNguan! You've successfully authenticated, but GitHub does not provide shell access.`
