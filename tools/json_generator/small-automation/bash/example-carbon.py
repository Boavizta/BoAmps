from BoAmps_Carbon.tracker import TrackerUtility

tracker = TrackerUtility(project_name="My Experiment")
tracker.start_cracker()


import torch
import torch.nn as nn
import torch.optim as optim

# Generate synthetic data
torch.manual_seed(42)
n_samples = 100
X = torch.rand(n_samples, 1) * 10
true_slope = 2.5
true_intercept = 1.0
noise = torch.randn(n_samples, 1) * 2
y = true_slope * X + true_intercept + noise

# Define the linear regression model
class LinearRegressionModel(nn.Module):
    def __init__(self):
        super(LinearRegressionModel, self).__init__()
        self.linear = nn.Linear(1, 1)

    def forward(self, x):
        return self.linear(x)

# Initialize the model, loss function, and optimizer
model = LinearRegressionModel()
criterion = nn.MSELoss()
optimizer = optim.SGD(model.parameters(), lr=0.01)

# Training loop
num_epochs = 500
for epoch in range(num_epochs):
    y_pred = model(X)
    loss = criterion(y_pred, y)
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()
    if (epoch + 1) % 50 == 0:
        print(f"Epoch [{epoch + 1}/{num_epochs}], Loss: {loss.item():.4f}")

tracker.stop_tracker("tracking_info.csv")
