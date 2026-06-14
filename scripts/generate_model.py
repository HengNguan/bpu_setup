import os
import torch
import torch.nn as nn

class SimpleNet(nn.Module):
    def __init__(self):
        super(SimpleNet, self).__init__()
        self.conv = nn.Conv2d(3, 16, kernel_size=3, stride=1, padding=1)
        self.relu = nn.ReLU()
        self.pool = nn.AdaptiveAvgPool2d((1, 1))
        self.fc = nn.Linear(16, 2)

    def forward(self, x):
        x = self.conv(x)
        x = self.relu(x)
        x = self.pool(x)
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        return x

def main():
    os.makedirs("models", exist_ok=True)
    os.makedirs("workspace", exist_ok=True)
    os.makedirs("data", exist_ok=True)

    model = SimpleNet()
    model.eval()

    # Create dummy input of shape [1, 3, 224, 224]
    dummy_input = torch.randn(1, 3, 224, 224)
    
    # Export the model
    torch.onnx.export(
        model,
        dummy_input,
        "models/simple_net.onnx",
        input_names=["input"],
        output_names=["output"],
        opset_version=11,
        verbose=True
    )
    print("Model simple_net.onnx generated successfully under models/ directory.")

    # Let's also generate a dummy calibration data file
    # We will generate a list of dummy numpy inputs and save them as binary files or npy files
    print("Generating dummy calibration dataset...")
    cal_data_dir = "data/calibration_data"
    os.makedirs(cal_data_dir, exist_ok=True)
    
    # We'll generate 20 calibration samples
    for i in range(20):
        # Generate random float32 tensor representing an image
        sample = torch.randn(1, 3, 224, 224)
        # Transpose/save as raw bytes or NumPy array. Typically raw float32 bytes is easiest.
        sample_path = os.path.join(cal_data_dir, f"sample_{i}.bin")
        with open(sample_path, "wb") as f:
            f.write(sample.numpy().tobytes())
            
    # Write a list file containing paths of all calibration files
    list_file_path = "data/calibration_list.txt"
    with open(list_file_path, "w") as f:
        for i in range(20):
            f.write(f"data/calibration_data/sample_{i}.bin\n")
            
    print(f"Calibration list file created at: {list_file_path}")

if __name__ == "__main__":
    main()
