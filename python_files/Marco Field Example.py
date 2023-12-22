from re import S
import sys ;sys.path.append('../'); sys.path.append('../src/python_modules') 

import numpy as np; 
import plantbox as pb
import vtk_plot as vp
import vtk
from vtk_tools import *
import csv
import time

# ====================================================================================================
# Functions
# ====================================================================================================

# Create a field in the form of a list of plants
def make_field(param, N_row, N_col, N_plots, simtime, dist_row, dist_col, dist_plot):
    allP = []
    for p in range(0, N_plots):
        for i in range(0, N_col):
            for j in range(0, N_row):
                # print('plot = ', p,' | row = ', i, ' | col = ', j)
                plant = pb.MappedPlant()
                plant.readParameters(param)

                # Change seed location
                plant.getOrganRandomParameter(pb.seed)[0].seedPos = pb.Vector3d(dist_plot*p + (dist_col * i), 
                                                                                (dist_row * j),
                                                                                -3.)  # cm

                # Change leaf parametrisation type
                plant.getOrganRandomParameter(pb.leaf)[0].parametrisationType = 1
                # print(plant.getOrganRandomParameter(pb.leaf)[0].parametrisationType)

                plant.initialize()  # verbose = False
                allP.append(plant)      
    # =======================
    return(allP)

# Join plants into one assembly file
def make_assembly(allP, simtime):

    assembly = vtk.vtkAssembly()
    # assembly_s = vtk.vtkAssembly()

    for plant in allP:

        polyData_i = vtk.vtkPolyData() # define vtk file

        plant.simulate(simtime, False)  # Simulate plants

        # Creates vtkPolydata from a RootSystem or Plant using vtkLines to represent the root segments
        pd = vp.segs_to_polydata(plant, 1., ["radius", "organType", "creationTime", "type"]) 

        # Plot root system and return a vtkActor
        tube_plot_actor, color_bar = vp.plot_roots(pd, 'type', "", render = False)
        
        # Initialize leaves as polygons
        leaf_points = vtk.vtkPoints()    # define vtkPoint object
        leaf_polys = vtk.vtkCellArray()  # describing the leaf surface area

        # Iterate through the leaves 
        leafes = plant.getOrgans(pb.leaf)
        for l in leafes:
            vp.create_leaf(l, leaf_points, leaf_polys)  # add leaf points and polygons to leaf_points and leaf_poly

        # Add points to vtk
        polyData_i.SetPoints(leaf_points)
        polyData_i.SetPolys(leaf_polys)

        colors = vtk.vtkNamedColors()
        mapper_i = vtk.vtkPolyDataMapper()
        mapper_i.SetInputData(polyData_i)
        actor_i = vtk.vtkActor()
        actor_i.SetMapper(mapper_i);
        actor_i.GetProperty().SetColor(colors.GetColor3d("Green"))
        # vp.render_window([tube_plot_actor, actor], "plot_plant", color_bar, tube_plot_actor.GetBounds()).Start()

        assembly.AddPart(actor_i)
        assembly.AddPart(tube_plot_actor)

    return assembly, tube_plot_actor

# Rough function to plot the assembly
def plot_field(assembly, tube_plot_actor, png = False):

    bounds = tube_plot_actor.GetBounds()
    # Create a renderer and a render window
    colors = vtk.vtkNamedColors()  # Set the background color
    ren = vtk.vtkRenderer()  # Set up window with interaction
    ren.SetBackground(colors.GetColor3d("Silver"))
    
    axes = vtk.vtkAxesActor()
    axes.AxisLabelsOff()  # because i am too lazy to change font size
    translate = vtk.vtkTransform()
    translate.Translate(bounds[0], bounds[2], bounds[4])  # minx, miny, minz
    axes.SetUserTransform(translate)
    ren.AddActor(axes)
    ren.AddActor(assembly)

    # Camera
    ren.ResetCamera()
    camera = ren.GetActiveCamera()
    camera.ParallelProjectionOn()
    camera.SetFocalPoint([0, 0, 0.5 * (bounds[4] + bounds[5])])
    camera.SetPosition([200, 0, 0.5 * (bounds[4] + bounds[5])])
    camera.SetViewUp(0, 0, 1)
    camera.Azimuth(0)
    camera.Elevation(30)
    camera.OrthogonalizeViewUp()
    camera.SetClippingRange(1, 1000)

    # Render Window
    renWin = vtk.vtkRenderWindow()  # boss
    renWin.SetSize(1200, 1000)
    renWin.AddRenderer(ren)

    iren = vtk.vtkRenderWindowInteractor()
    iren.SetRenderWindow(renWin)
    renWin.Render()
    iren.CreateRepeatingTimer(50)  # [ms] 0.5 s in case a timer event is interested
    iren.AddObserver('KeyPressEvent', lambda obj, ev:keypress_callback_(obj, ev, bounds), 1.0)
    iren.Initialize()  # This allows the interactor to initalize itself. It has to be called before an event loop.
    for a in ren.GetActors():
        a.Modified()  #
    renWin.Render()
    return iren
    
    # if png :
    #     vp.write_png(renWin, "test_png")

    # return 
    # return iren

# ====================================================================================================
# Set plant and field parameters
# ====================================================================================================

param = 'Wheat.xml'
simtime = 140
N_row = 18
N_col = 6
N_plots = 2
dist_col = 25
dist_row = 25
dist_plot = 190

# ====================================================================================================
# Unleash CPB
# ====================================================================================================

Plants = make_field(param, N_row, N_col, N_plots, simtime, dist_row, dist_col, dist_plot)
assembly, tube_plot_actor = make_assembly(Plants, simtime)

# ====================================================================================================
# Plot field
# ====================================================================================================

# ana = pb.SegmentAnalyser()  # see example 3b
# for i, plant in enumerate(Plants):
#     ana.addSegments(plant)  # collect all
# Export file
# export_name = 'test/Test.vtp' 
# ana.write(export_name)
# Plot, using vtk
# vp.plot_roots(ana, 'creationTime')
# vp.plot_plant(allP[0], 'type') 

# ====================================================================================================
# Export nodes as CSV
# ====================================================================================================

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
csv_file_path = 'results/2023-11-06_2/csv/100' + '.csv'

# Open the CSV file for writing
with open(csv_file_path, mode='w', newline='') as file:
    writer = csv.writer(file)

    # Write the header row with column names
    writer.writerow(['X', 'Y', 'Z'])

    # Write the coordinates to the CSV file
    for x, y, z in coordinates:
        writer.writerow([x, y, z])

print(f'Coordinates have been exported to {csv_file_path}')