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

plant = pb.MappedPlant()
plant.readParameters(param)

# Change leaf parametrisation type
plant.getOrganRandomParameter(pb.leaf)[0].parametrisationType = 1
print(plant.getOrganRandomParameter(pb.leaf)[0].parametrisationType)

plant.initialize()  # verbose = False

plant.simulate(simtime, False)  # verbose = False

ana = pb.SegmentAnalyser()  # see example 3b

nodes = plant.getNodes()

coordinates = []
for vector3d in nodes:
        x = vector3d.x
        y = vector3d.y
        z = vector3d.z
        coordinates.append((x, y, z))
        
# Specify the file path where you want to save the CSV file
csv_file_path = 'results/Solo_t' + str(simtime) + '.vtp'

# Open the CSV file for writing
with open(csv_file_path, mode='w', newline='') as file:
    writer = csv.writer(file)

    # Write the header row with column names
    writer.writerow(['X', 'Y', 'Z'])

    # Write the coordinates to the CSV file
    for x, y, z in coordinates:
        writer.writerow([x, y, z])

print(f'Coordinates have been exported to {csv_file_path}')



# Export file
# export_name = 'results/Solo_t' + str(simtime) + '.vtp' 
# ana.write(export_name)
# Plot, using vtk
# vp.plot_roots(ana, 'creationTime')
vp.plot_plant(plant, 'type') 
