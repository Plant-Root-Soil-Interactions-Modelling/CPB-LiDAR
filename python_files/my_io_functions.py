import numpy as np
import vtk 
import pandas as pd
import xml.etree.ElementTree as ET
from vtk.util.numpy_support import vtk_to_numpy
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from tqdm import tqdm
import textwrap
import subprocess

def import_VTP(filename):
    # Load the VTP file
    reader = vtk.vtkXMLPolyDataReader()
    #=================================================
    reader.SetFileName(filename)
    #=================================================
    reader.Update()
    polydata = reader.GetOutput()

    # Get the points from the polydata
    points = polydata.GetPoints()

    # Convert the vtkPoints to a Pandas DataFrame
    temp = []
    for i in range(points.GetNumberOfPoints()):
        point = points.GetPoint(i)
        temp.append([point[0], point[1], point[2]])

    point_cloud = pd.DataFrame(temp, columns=["x", "y", "z"])
    point_cloud2 = point_cloud.loc[point_cloud['z'] > 0]
    return(point_cloud2)
    

def make_grid(filename, grid_size):

    # Load the VTP file
    reader = vtk.vtkXMLPolyDataReader()
    #=================================================
    reader.SetFileName(filename)
    #=================================================
    reader.Update()
    polydata = reader.GetOutput()

    # Get the points from the polydata
    points = polydata.GetPoints()

    # Convert the vtkPoints to a Pandas DataFrame
    temp = []
    for i in range(points.GetNumberOfPoints()):
        point = points.GetPoint(i)
        temp.append([point[0], point[1], point[2]])

    point_cloud = pd.DataFrame(temp, columns=["x", "y", "z"])
    point_cloud2 = point_cloud.loc[point_cloud['z'] > 0]

    #=================================================
    # Create a scatter plot of the data
    plt.scatter(point_cloud2['x'], point_cloud2['y'], c=point_cloud2['z'])
    plt.xlabel('x')
    plt.ylabel('y')
    plt.colorbar()
    plt.axis('equal')
    plt.show()

    #=================================================
    # Grid definition

    GS = grid_size  # grid size
    x_min = np.min(point_cloud2['x'])
    x_max = np.max(point_cloud2['x'])
    y_min = np.min(point_cloud2['y'])
    y_max = np.max(point_cloud2['y'])

    x = np.arange(x_min, x_max, GS)
    y = np.arange(y_min, y_max, GS)
    X, Y = np.meshgrid(x,y)
    MyGrid = pd.DataFrame({'x': X.flatten(), 'y': Y.flatten(), 'z': np.zeros(X.size)})

    #=================================================
    # Algorithm to superpose the data and the grid

    PC = point_cloud2

    # Loop for grid nodes
    for index, row in MyGrid.iterrows() :
            x_i = row['x']
            y_i = row['y']
            # print(x_i, y_i)

            # Make a local PC in the grid plot
            PC_local = PC.loc[(PC['x'] >= x_i - GS/2) & (PC['x'] < x_i + GS/2) & (PC['y'] >= y_i - GS/2) & (PC['y'] < y_i + GS/2)]
          
            # Extract z
            if PC_local.empty :
                mean_z = 0
            else :
                mean_z = np.max(PC_local['z'])         # max or mean?
            
            # Update z of the grid
            MyGrid.loc[(MyGrid['x'] == x_i) & (MyGrid['y'] == y_i), 'z'] = mean_z 

    # Plot final render
    z_matrix = MyGrid['z'].values.reshape(len(y), len(x))
    fig, ax = plt.subplots()
    plt.imshow(z_matrix, cmap='Greens', extent=[x.min(), x.max(), y.min(), y.max()], aspect='auto', origin='lower')
    plt.colorbar()
    plt.axis('equal')
    plt.show()

    return(MyGrid)


def plot_CH(lidar):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')

    x = lidar['x']
    y = lidar['y']
    z = lidar['Height']
    c = lidar['Height']

    ax.scatter(x, y, z, c=c, cmap='viridis')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_zlabel('Height')
    ax.set_title('Lidar Data')
    plt.show()

    # Find the minimum and maximum values of x and y
    xmin, xmax = lidar['x'].min(), lidar['x'].max()
    ymin, ymax = lidar['y'].min(), lidar['y'].max()

    # Create a grid of points
    xgrid = np.unique(lidar['x'])
    ygrid = np.unique(lidar['y'])
    xv, yv = np.meshgrid(xgrid, ygrid)

    # Create a new dataframe with the grid points
    CH = pd.DataFrame({
        'x': xv.ravel(),
        'y': yv.ravel(),
        'Height': 0
    })

    # Add Height values from lidar to CH
    for i, row in lidar.iterrows():
        x = row['x']
        y = row['y']
        height = row['Height']
        # Update the Height value in the CH dataframe
        CH.loc[(CH['x'] == x) & (CH['y'] == y), 'Height'] = height

    # Standardize x and y
    CH['x'] -= xmin
    CH['y'] -= ymin

    x = np.unique(CH['x'])
    y = np.unique(CH['y'])
    z_matrix = CH['Height'].values.reshape(len(y), len(x))
    fig, ax = plt.subplots()
    plt.imshow(z_matrix, cmap='Greens', extent=[x.min(), x.max(), y.min(), y.max()], aspect='auto', origin='lower')
    plt.colorbar()
    plt.axis('equal')
    plt.show()

    return CH


def plot_GF(lidar):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')

    x = lidar['x']
    y = lidar['y']
    z = lidar['GF']
    c = lidar['GF']

    ax.scatter(x, y, z, c=c, cmap='viridis')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_zlabel('GF')
    ax.set_title('Lidar Data')
    plt.show()

    # Find the minimum and maximum values of x and y
    xmin, xmax = lidar['x'].min(), lidar['x'].max()
    ymin, ymax = lidar['y'].min(), lidar['y'].max()

    # Create a grid of points
    xgrid = np.unique(lidar['x'])
    ygrid = np.unique(lidar['y'])
    xv, yv = np.meshgrid(xgrid, ygrid)

    # Create a new dataframe with the grid points
    GF = pd.DataFrame({
        'x': xv.ravel(),
        'y': yv.ravel(),
        'GF': 0
    })

    # Add GF values from lidar to GF
    for i, row in lidar.iterrows():
        x = row['x']
        y = row['y']
        # GapF = row['GF']
        # Update the GF value in the dataframe
        GF.loc[(GF['x'] == x) & (GF['y'] == y), 'GF'] = row['GF']

    # Standardize x and y
    GF['x'] -= xmin
    GF['y'] -= ymin

    x = np.unique(GF['x'])
    y = np.unique(GF['y'])
    z_matrix = GF['GF'].values.reshape(len(y), len(x))
    fig, ax = plt.subplots()
    plt.imshow(z_matrix, cmap='Greens', extent=[x.min(), x.max(), y.min(), y.max()], aspect='auto', origin='lower')
    plt.colorbar()
    plt.axis('equal')
    plt.show()

    return GF


def write_CPB(param, N_row, N_col, N_plots, simtime, dist_row, dist_col, dist_plot):

    text = """import sys ;sys.path.append("../"); sys.path.append("../src/python_modules") \n
import numpy as np; 
import plantbox as pb
import vtk_plot as vp

param = '"""+    str(param)+"""'
simtime = """+  str(simtime)+"""
N_row = """+    str(N_row)+""" 
N_col = """+    str(N_col)+"""
N_plots = """+  str(N_plots)+"""
dist_col = """+ str(dist_col)+"""
dist_row = """+ str(dist_row)+"""
dist_plot = """+str(dist_plot)+"""


# =============================================================================
def make_field(param, N_row, N_col, N_plots, simtime, dist_row, dist_col, dist_plot):
    allP = []
    for p in range(0, N_plots):
        for i in range(0, N_col):
            for j in range(0, N_row):
                print("plot = ", p," | row = ", i, " | col = ", j)
                plant = pb.MappedPlant()
                plant.readParameters(param)

                # Change seed location
                plant.getOrganRandomParameter(pb.seed)[0].seedPos = pb.Vector3d(dist_plot*p + (dist_col * i), 
                                                                                (dist_row * j),
                                                                                -3.)  # cm

                # Change leaf parametrisation type
                plant.getOrganRandomParameter(pb.leaf)[0].parametrisationType = 1
                print(plant.getOrganRandomParameter(pb.leaf)[0].parametrisationType)

                plant.initialize()  # verbose = False
                allP.append(plant)      
    # =======================
    return(allP)
# ================================================================
# Make Field
allP = make_field(param, N_row, N_col, N_plots, simtime, dist_row, dist_col, dist_plot)
# Simulate plants
for plant in allP:
    plant.simulate(simtime, False)  # verbose = False
# Compile plants into one file
ana = pb.SegmentAnalyser()  # see example 3b
for i, plant in enumerate(allP):
    ana.addSegments(plant)  # collect all
# Export file
export_name = "results/Multiple_t" + str(simtime) + "_r" + str(N_row) + "_c" + str(N_col) +  "_p" + str(N_plots) + "_dc" + str(dist_col) + "_dr" + str(dist_row) + "_dp" + str(dist_plot) + ".vtp" 
ana.write(export_name)
# Plot, using vtk
# vp.plot_roots(ana, "creationTime")
vp.plot_plant(allP[0], "type") """
    text2 = textwrap.dedent(text)
    CPB = "CPB.py"
    with open(CPB, "w") as f:
        f.write(text2)


def read_params(file_name) :
    # parse the XML file
    tree = ET.parse(file_name)
    root = tree.getroot()

    # create a dataframe
    params_df = pd.DataFrame(columns=['organ_type', 'organ_name', 'param_name', 'subType', 'param_value'])

    # loop over all the 'organ' elements in the XML
    for organ in root.findall('organ'):
        # print(organ)
        organ_type = organ.get('type')
        organ_name = organ.get('name')
        subType = organ.get('subType')
        
        # loop over all the 'parameter' elements in the organ
        for param in organ.findall('parameter'):
            param_name = param.get('name')
            param_value = param.get('value')

            # Save values
            temp = [organ_type, organ_name, param_name, subType, param_value]
            params_df.loc[len(params_df)] = temp
    return(params_df)


def change_param(filename, 
                 organ_type, 
                 organ_name, 
                 param_name, 
                 new_value):
    # Open the xml param file, change the values of the param and save the file 
    tree = ET.parse(filename)
    root = tree.getroot()
    param = root.find(f"./organ[@type='{organ_type}'][@name='{organ_name}']/parameter[@name='{param_name}']")
    # print(param)
    param.set('value', str(new_value))
    tree.write(filename)


# ==================================================================================================

# def pipeline(param_df = None, 
#              param_file = "Wheat.xml", 
#              grid_size = 20):

#     # Update Leaf parameters in the XML file
#     param_leaf = param_df.loc[param_df['organ_type'] == 'leaf']
#     for temp_param in list(param_leaf['param_name']):
#         if temp_param != "leafGeometry":  # because it returns a None temp_value
#             temp_value = param_leaf.loc[param_leaf['param_name'] == temp_param, 'param_value']
#             # print(temp_param)
#             # print(temp_value)
#             change_param(filename=param_file,
#                         organ_type = 'leaf', 
#                         organ_name = 'lateral1',
#                         param_name = temp_param,
#                         new_value = float(temp_value))
            
#     print("Extract field params")
#     simtime = int(param_df.loc[param_df['param_name'] == "simtime", "param_value"])
#     N_row = int(param_df.loc[param_df['param_name'] == "N_row", "param_value"] )
#     N_col = int(param_df.loc[param_df['param_name'] == "N_col", "param_value"])
#     N_plots = int(param_df.loc[param_df['param_name'] == "N_plots", "param_value"])
#     dist_col = int(param_df.loc[param_df['param_name'] == "dist_col", "param_value"])
#     dist_row = int(param_df.loc[param_df['param_name'] == "dist_row", "param_value"])
#     dist_plot = int(param_df.loc[param_df['param_name'] == "dist_plot", "param_value"])
                
#     # Check is there a CPB2.py file
#     print("Writing python file")
#     write_CPB(param_file, N_row, N_col, N_plots, simtime, dist_row, dist_col, dist_plot)

#     # Run python
#     print("Unleashing CPlantBox")

#     command = "!wsl python3 CPB.py"
#     subprocess.run(command, shell=True)

#     # Analysing results
#     print("Analysing results")
#     result_name = "results/Multiple_t" + str(simtime) + "_r" + str(N_row) + "_c" + str(N_col) +  "_p" + str(N_plots) + "_dc" + str(dist_col) + "_dr" + str(dist_row) + "_dp" + str(dist_plot) + ".vtp" 

#     MyGrid = make_grid(filename = result_name, grid_size=grid_size)

#     return(MyGrid)
        
            
