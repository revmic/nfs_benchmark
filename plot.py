import pandas as pd
import matplotlib.pyplot as plt
import argparse

# Argument parsing
parser = argparse.ArgumentParser(description='Plot load average and system metrics from CSV.')
parser.add_argument('csv_file', type=str, help='Path to the CSV file')
parser.add_argument('--save', type=str, help='Path to save the plot image instead of showing it')
args = parser.parse_args()

# Read CSV file
df = pd.read_csv(args.csv_file, parse_dates=['timestamp'])
df.set_index('timestamp', inplace=True)

# Plot
plt.figure(figsize=(12, 8))

# Subplot 1: Load averages
plt.subplot(2, 1, 1)
plt.plot(df.index, df['loadavg_1'], marker='o', label='Load Average 1 min')
plt.plot(df.index, df['loadavg_5'], marker='o', label='Load Average 5 min')
plt.plot(df.index, df['loadavg_15'], marker='o', label='Load Average 15 min')
plt.ylabel('Load Average')
plt.legend()
plt.grid(True)

# Subplot 2: Find and rsync metrics
plt.subplot(2, 1, 2)
plt.plot(df.index, df['find_d1'], marker='o', label='Find Depth 1')
plt.plot(df.index, df['find_all'], marker='o', label='Find All Files')
plt.plot(df.index, df['rsync_1'], marker='o', label='Rsync Directory')
plt.plot(df.index, df['rsync_5'], marker='o', label='Rsync 5 Directories')
plt.ylabel('Find & Rsync Metrics')
plt.legend()
plt.grid(True)

# Beautify the x-axis
plt.xticks(rotation=45)
plt.tight_layout()

# Save or show the plot
if args.save:
    plt.savefig(args.save)
else:
    plt.show()
