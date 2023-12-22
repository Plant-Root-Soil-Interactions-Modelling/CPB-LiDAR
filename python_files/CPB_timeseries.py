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
dx = 10
N_row = 12
N_col = 6
N_plots = 2
dist_col = 25
dist_row = 25
dist_plot = 190

N_iter = round(simtime/dx)

# ================================================================
# Make Field
for iter in range(1, N_iter+1):
    age_i = iter*dx
    print(age_i)
    
    Plants = make_field(param, N_row, N_col, N_plots, age_i, dist_row, dist_col, dist_plot)
    
    # Make assembly
    assembly, tube_plot_actor = make_assembly(Plants, age_i)

    ana = pb.SegmentAnalyser()  # see example 3b
    for i, plant in enumerate(Plants):
      ana.addSegments(plant)  # collect all
    
    # Export file
    export_name = 'test/Test_'+str(age_i)+'.vtp' 
    ana.write(export_name)
    plot_field(assembly, tube_plot_actor)
