import numpy as np
from scipy.spatial import cKDTree
import sys

file_a = str(sys.argv[1])
file_b = str(sys.argv[2])
output_file = "point_charges.txt"

# print(f" {file_a} {file_b} {output_file}")

data_a = np.loadtxt(file_a)
coords_a = data_a[:, :3]
charges_a = data_a[:, 3]

# Create a KD-tree for efficient nearest neighbor search
tree = cKDTree(coords_a)

# Read file b
coords_b = np.loadtxt(file_b)

# Process each coordinate in b
with open(output_file, 'w') as f_out:
    for coord in coords_b:
        # Find 8 closest coordinates
        distances, indices = tree.query(coord, k=8)
        
        # Calculate average charge of 8 closest points
        avg_pt_charge = np.mean(charges_a[indices])
        
        # Write to output file
        f_out.write(f"{avg_pt_charge:.6f}\n")

