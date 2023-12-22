import sys ;sys.path.append('../'); sys.path.append('../src/python_modules'); sys.path.append('python_files/') 

import numpy as np; 
import plantbox as pb
import vtk_plot as vp
import vtk
from vtk_tools import *
from Field_Functions import *
import csv

param = 'Wheat.xml'
simtime = 130
N_row = 12
N_col = 6
N_plots = 2
dist_col = 25
dist_row = 25
dist_plot = 190

# Make Field
Plants = make_field(param, N_row, N_col, N_plots, simtime, dist_row, dist_col, dist_plot)

# Make assembly
assembly, tube_plot_actor = make_assembly(Plants, simtime)
ana = pb.SegmentAnalyser()  # see example 3b
for i, plant in enumerate(Plants):
    ana.addSegments(plant)  # collect all
# Export file
export_name = 'test/Test.vtp'
ana.write(export_name)
# ===============================================================

# nodes = Plants.getNodes()
# Extract coordinates from the list of Vector3d objects
coordinates = []
for i, plant in enumerate(Plants) :
    nodes = plant.getNodes()
    for vector3d in nodes:
        x = vector3d.x
        y = vector3d.y
        z = vector3d.z
        coordinates.append((x, y, z))

# Specify the file path where you want to save the CSV file
csv_file_path = 'test/Test' + '.csv'

# Open the CSV file for writing
with open(csv_file_path, mode='w', newline='') as file:
    writer = csv.writer(file)

    # Write the header row with column names
    writer.writerow(['X', 'Y', 'Z'])

    # Write the coordinates to the CSV file
    for x, y, z in coordinates:
        writer.writerow([x, y, z])

print(f'Coordinates have been exported to {csv_file_path}')

plot_field(assembly, tube_plot_actor)
