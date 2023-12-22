import sys ;sys.path.append('../'); sys.path.append('../src/python_modules') 

import numpy as np; 
import plantbox as pb
import vtk_plot as vp
import vtk
from vtk_tools import *
from Marco import *

# =============================================================================
param = 'Wheat.xml'
simtime = 160
N_row = 18
N_col = 6
N_plots = 2
dist_col = 25
dist_row = 25
dist_plot = 190
# =============================================================================
# Make Field
Plants = make_field(param, N_row, N_col, N_plots, simtime, dist_row, dist_col, dist_plot)

# Make assembly
assembly, tube_plot_actor = make_assembly(Plants, simtime)

ana = pb.SegmentAnalyser()  # see example 3b
for i, plant in enumerate(Plants):
    ana.addSegments(plant)  # collect all
# Export file
# export_name = 'results/VTP/Multiple_t' + str(simtime) + '_r' + str(N_row) + '_c' + str(N_col) +  '_p' + str(N_plots) + '_dc' + str(dist_col) + '_dr' + str(dist_row) + '_dp' + str(dist_plot) + '.vtp' 
# ana.write(export_name)
# Plot, using vtk
# vp.plot_roots(ana, 'creationTime')
# vp.plot_plant(allP[0], 'type') 

# Plot field
plot_field(assembly, tube_plot_actor, png = True)



