import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import sys

from pyvdwsurface import vdwsurface # type: ignore

file = sys.argv[1]

f = open(file, 'r')
data = f.read()
f.close

data = data.split()

data = data[1:]



elements = data[0::4]

x = data[1::4]
y = data[2::4]
z = data[3::4]

x = [float(i) for i in x]
y = [float(i) for i in y]
z = [float(i) for i in z]


coordinates = np.array(list(zip(x, y, z)))

scale_factor = 2.0
density=1


points = vdwsurface(coordinates, elements, scale_factor, density)

pointsXx = [["Xx", point[0], point[1], point[2]] for point in points]
pointsXx = np.array(pointsXx)


# print(points)

np.savetxt("points.txt", points, fmt='%8.4f')


