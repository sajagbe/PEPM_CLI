import numpy as np
import sys




# Starting coordinates
start_x, start_y, start_z = float(sys.argv[1]), float(sys.argv[2]), float(sys.argv[3])

# Grid dimensions
grid_size = int(sys.argv[4])

# Assuming a grid spacing of 0.1 (you can adjust this as needed)
delta = float(sys.argv[5])

counter = 1


# print (start_x, start_y, start_z, grid_size, delta)
# Create the grid

for x in range(grid_size):
    for y in range(grid_size):
        for z in range(grid_size):
            # Calculate the current coordinates
            current_x = start_x + x * delta
            current_y = start_y + y * delta
            current_z = start_z + z * delta
            
            # Print the coordinates
            print(f"{counter:7d}  C  {current_x:.3f}  {current_y:.3f}  {current_z:.3f} C3 1 XXX129")

            # Increment the counter
            counter += 1


