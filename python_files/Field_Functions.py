# This file contains function to loop CPlantBox to generate field, and to plot it.

import plantbox as pb
from vtk_tools import *
import time
import numpy as np
import vtk
from vtk_plot import *

def make_field(param, N_row, N_col, N_plots, simtime, dist_row, dist_col, dist_plot):
    # Loop CPlantBox and return a list of all simulated plants

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

def make_assembly(allP, simtime):
    # Join all plant simulations together in one assembly and a tube plot actor

    assembly = vtk.vtkAssembly()
    # assembly_s = vtk.vtkAssembly()

    for plant in allP:

        polyData_i = vtk.vtkPolyData() # define vtk file

        plant.simulate(simtime, False)  # Simulate plants

        # Creates vtkPolydata from a RootSystem or Plant using vtkLines to represent the root segments
        pd = segs_to_polydata(plant, 1., ["radius", "organType", "creationTime", "type"]) 

        # Plot root system and return a vtkActor
        tube_plot_actor, color_bar = plot_roots(pd, 'type', "", render = False)
        
        # Initialize leaves as polygons
        leaf_points = vtk.vtkPoints()    # define vtkPoint object
        leaf_polys = vtk.vtkCellArray()  # describing the leaf surface area

        # Iterate through the leaves 
        leafes = plant.getOrgans(pb.leaf)
        for l in leafes:
            create_leaf(l, leaf_points, leaf_polys)  # add leaf points and polygons to leaf_points and leaf_poly

        # Add points to vtk
        polyData_i.SetPoints(leaf_points)
        polyData_i.SetPolys(leaf_polys)

        colors = vtk.vtkNamedColors()
        mapper_i = vtk.vtkPolyDataMapper()
        mapper_i.SetInputData(polyData_i)
        actor_i = vtk.vtkActor()
        actor_i.SetMapper(mapper_i);
        actor_i.GetProperty().SetColor(colors.GetColor3d("Green"))
        # render_window([tube_plot_actor, actor], "plot_plant", color_bar, tube_plot_actor.GetBounds()).Start()

        assembly.AddPart(actor_i)
        assembly.AddPart(tube_plot_actor)

    return assembly, tube_plot_actor

def plot_field(assembly, tube_plot_actor, png = False):
    # Plot the whole field (does not work)

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
    #     write_png(renWin, "test/test_png")

    # return iren 