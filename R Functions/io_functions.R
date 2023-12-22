my_libraries <- function(){install = F
  if(install == T){
    
  }
}

# ==============================================================================
# ==============================================================================

CPB_writeCPB_solo <- function(param_filename = "Wheat.xml", CPB_filename, plot = T, simtime){
  text = paste0("import sys ;sys.path.append('../'); sys.path.append('../src/python_modules'); sys.path.append('python_files/') \n
import numpy as np; 
import plantbox as pb
import vtk_plot as vp
import vtk
from vtk_tools import *
from Field_Functions import *
import csv



param = '", as.character(param_filename), 
                "'\nsimtime = ", as.character(simtime),"

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
vp.plot_plant(plant, 'type') "
                
  )
  writeLines(text, CPB_filename)
}

CPB_writeCPB <- function(param_filename = "Wheat.xml", CPB_filename, params_df, export_path, sim_name, plot = T, vtp = F){
  
  plot_text <- " "
  if(plot == T){
    plot_text <- "plot_field(assembly, tube_plot_actor)"
  }
  
  vtp_text <- " "
  if(vtp == T){
    vtp_text <- paste0("
ana = pb.SegmentAnalyser()  # see example 3b
for i, plant in enumerate(Plants):
    ana.addSegments(plant)  # collect all
# Export file
export_name = '",export_path, sim_name, ".vtp'
ana.write(export_name)")
  }
  
  
  simtime <- params_df$param_value[params_df$paramID == "field_field_simtime"]
  N_row <- params_df$param_value[params_df$paramID == "field_field_N_row"]
  N_col <- params_df$param_value[params_df$paramID == "field_field_N_col"]
  N_plots <- params_df$param_value[params_df$paramID == "field_field_N_plots"]
  dist_col<- params_df$param_value[params_df$paramID == "field_field_dist_col"]
  dist_row<- params_df$param_value[params_df$paramID == "field_field_dist_row"]
  dist_plot<- params_df$param_value[params_df$paramID == "field_field_dist_plot"]
  
  text = paste0("import sys ;sys.path.append('../'); sys.path.append('../src/python_modules'); sys.path.append('python_files/') \n
import numpy as np; 
import plantbox as pb
import vtk_plot as vp
import vtk
from vtk_tools import *
from Field_Functions import *
import csv

param = '", as.character(param_filename), 
"'\nsimtime = ", as.character(simtime), 
"\nN_row = ", as.character(N_row), 
"\nN_col = ", as.character(N_col),

"\nN_plots = ",  as.character(N_plots),
"\ndist_col = ", as.character(dist_col), 
"\ndist_row = ", as.character(dist_row),
"\ndist_plot = ", as.character(dist_plot),
"

# Make Field
Plants = make_field(param, N_row, N_col, N_plots, simtime, dist_row, dist_col, dist_plot)

# Make assembly
assembly, tube_plot_actor = make_assembly(Plants, simtime)",
vtp_text,
"
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
csv_file_path = '", export_path, sim_name,"' + '.csv'

# Open the CSV file for writing
with open(csv_file_path, mode='w', newline='') as file:
    writer = csv.writer(file)

    # Write the header row with column names
    writer.writerow(['X', 'Y', 'Z'])

    # Write the coordinates to the CSV file
    for x, y, z in coordinates:
        writer.writerow([x, y, z])

print(f'Coordinates have been exported to {csv_file_path}')

", plot_text
  
)
 writeLines(text, CPB_filename)
}

CPB_writeCPB_TS <- function(param_filename = "Wheat.xml", CPB_filename, params_df, export_path, sim_name, plot = F, vtp = F){
  
  plot_text <- " "
  if(plot == T){
    plot_text <- "plot_field(assembly, tube_plot_actor)"
  }
  
  text_vtp <- " "
  if(vtp == T){
    text_vtp <- paste0("
    # Export file
    export_name = '",export_path,sim_name,"_'+str(age_i)+'.vtp' 
    ana.write(export_name)
    " )
  }
    
  
  simtime <- params_df$param_value[params_df$paramID == "field_field_simtime"]
  N_row <- params_df$param_value[params_df$paramID == "field_field_N_row"]
  N_col <- params_df$param_value[params_df$paramID == "field_field_N_col"]
  N_plots <- params_df$param_value[params_df$paramID == "field_field_N_plots"]
  dist_col<- params_df$param_value[params_df$paramID == "field_field_dist_col"]
  dist_row<- params_df$param_value[params_df$paramID == "field_field_dist_row"]
  dist_plot<- params_df$param_value[params_df$paramID == "field_field_dist_plot"]
  
  text = paste0("import sys ;sys.path.append('../'); sys.path.append('../src/python_modules'); sys.path.append('python_files/') \n
import numpy as np; 
import plantbox as pb
import vtk_plot as vp
import vtk
from vtk_tools import *
from Field_Functions import *
import csv

param = '", as.character(param_filename), 
"'\nsimtime = ", as.character(simtime),
"\ndx = ", as.character(dx),
"\nN_row = ", as.character(N_row), 
"\nN_col = ", as.character(N_col),
"\nN_plots = ",  as.character(N_plots),
"\ndist_col = ", as.character(dist_col), 
"\ndist_row = ", as.character(dist_row),
"\ndist_plot = ", as.character(dist_plot),
"

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
    ", text_vtp, plot_text
)
  writeLines(text, CPB_filename)
  
}

# ==============================================================================
# ==============================================================================

RMSE = function(t, y){
  if(length(t) != length(y)){
    print("Error, t length should be equal to y length")
  }
  RMSE = sqrt(sum((y - t)^2)/length(t))
  return(RMSE)
}

# ==============================================================================
# ==============================================================================

SSE = function(t, y){
  if(length(t) != length(y)){
    print("Error, t length should be equal to y length")
  }
  SSE = 0.5*sum((y - t)^2)
  return(SSE)
}

# =============================================================================
# =============================================================================

Make_Results <- function(results, simulation, PS){
  results$ID <- NaN
  for(i in seq(1, length(results[,1]))){
    results$ID[i] <- paste0(results$simulationID[i], "_", results$simtime[i])
  }
  # =============================================================================
  results2 <- data.frame()
  for(id in unique(results$ID)){
    # print(id)
    subset <- results %>% filter(ID == id)
    temp <- data.frame(ID = unique(subset$ID),
                       simulationID = unique(subset$simulationID),
                       simtime = unique(subset$simtime),
                       Mean_CH = mean(subset$CH),
                       Mean_GF = mean(subset$GF),
                       GFR1 = sum(subset$GF >= 0 & subset$GF < 0.25),
                       GFR2 = sum(subset$GF >= 0.25 & subset$GF < 0.50),
                       GFR3 = sum(subset$GF >= 0.5 & subset$GF < 0.75),
                       GFR4 = sum(subset$GF >= 0.75),
                       CHR1 = sum(subset$CH >= 0 & subset$GF < 0.25*max(subset$CH)),
                       CHR2 = sum(subset$CH >= 0.25*max(subset$CH) & subset$GF < 0.50*max(subset$CH)),
                       CHR3 = sum(subset$CH >= 0.5*max(subset$CH) & subset$GF < 0.75*max(subset$CH)),
                       CHR4 = sum(subset$CH >= 0.75*max(subset$CH)),
                       Mean_Density = mean(subset$Density))
    results2 <- rbind(results2, temp)
  }
  results2 <- results2 %>%filter(simulationID != 0)
  # ==============================================================================
  results3 <- join(results2, PS)
  return(results3)
}

Make_GF_features <- function(GF_layers_all, simulation, PS){
  
  GF_layers_all$ID <- NaN
  for(i in seq(1, length(GF_layers_all[,1]))){
    GF_layers_all$ID[i] <- paste0(GF_layers_all$simulationID[i], "_", GF_layers_all$simtime[i])
  }
  # =============================================================================
  results2 <- data.frame()
  for(id in unique(GF_layers_all$ID)){
    # print(id)
    # for(layer_i in unique(GF_layers_all$layer))
      subset <- GF_layers_all %>% filter(ID == id)
      temp <- data.frame(ID = unique(subset$ID),
                         simulationID = unique(subset$simulationID),
                         simtime = unique(subset$simtime),
                         GF_layer1 = mean(subset$GF[subset$layer=="1"]),
                         GF_layer2 = mean(subset$GF[subset$layer=="2"]),
                         GF_layer3 = mean(subset$GF[subset$layer=="3"]),
                         GF_layer4 = mean(subset$GF[subset$layer=="4"]),
                         GF_layer5 = mean(subset$GF[subset$layer=="5"]),
                         GF_layer6 = mean(subset$GF[subset$layer=="6"]))
      results2 <- rbind(results2, temp)
  }
  
  return(results2)
}

# =============================================================================
# =============================================================================

As_Database <- function(results_clean){
  features <- data.frame(features = colnames(results_clean)[c(4,5,6,7,8,9,10,11,12,13,14)]) # To optimize !!!
  Pparams <- data.frame(Pparams = colnames(results_clean)[c(15)])
  
  results4 <- data.frame()
  
  for(id in results_clean$ID){
    subset <- results_clean %>% filter(ID == id)
    export <- data.frame(ID = id,
                         simulationID = unique(subset$simulationID),
                         simtime = unique(subset$simtime))
    export <- merge(export, features)
    export <- merge(export, Pparams)
    results4 <- rbind(results4, export)
  }
  # ==============================================================================
  results4$features_values <- NaN
  results4$Pparams_values <- NaN
  for (ID_i in results_clean$ID) {
    for(feature_i in features$features){
      results4$features_values[results4$ID == ID_i & results4$features == feature_i] <- results_clean[results_clean$ID == ID_i, feature_i]
    }
    for(Pparam_i in Pparams$Pparams){
      results4$Pparams_values[results4$ID == ID_i & results4$Pparams == Pparam_i] <- results_clean[results_clean$ID == ID_i, Pparam_i]
    }
  }
  
  return(results4)
}

As_Database2 <- function(results_clean){
  features <- data.frame(features = c("Mean_CH", "Mean_GF", "Mean_Density",
                                      "GFR1", "GFR2", "GFR3", "GFR4", 
                                      "CHR1", "CHR2", "CHR3", "CHR4",
                                      "GF_layer1", "GF_layer2", "GF_layer3", "GF_layer4", "GF_layer5", "GF_layer6")) # To optimize !!!
  Pparams <- data.frame(Pparams = colnames(results_clean)[c(15)])
  
  results4 <- data.frame()
  
  for(id in results_clean$ID){
    # print(id)
    subset <- results_clean %>% filter(ID == id)
    export <- data.frame(ID = id,
                         simulationID = unique(subset$simulationID),
                         simtime = unique(subset$simtime))
    export <- merge(export, features)
    export <- merge(export, Pparams)
    results4 <- rbind(results4, export)
  }
  # ==============================================================================
  results4$features_values <- NaN
  results4$Pparams_values <- NaN
  
  for (ID_i in results_clean$ID) {
    # print(ID_i)
    for(feature_i in features$features){
      # print(feature_i)
      results4$features_values[results4$ID == ID_i & results4$features == feature_i] <- results_clean[results_clean$ID == ID_i, feature_i]
    }
    for(Pparam_i in Pparams$Pparams){
      # print(Pparam_i)
      results4$Pparams_values[results4$ID == ID_i & results4$Pparams == Pparam_i] <- results_clean[results_clean$ID == ID_i, Pparam_i]
    }
  }
  
  return(results4)
}

# =============================================================================
# =============================================================================

CPB_GF_features <- function(MyGrid2){
  
  GF_features <- data.frame(layer = unique(MyGrid2$layer))
  GF_features$Mean_GF <- 1
  
  for(layer_i in MyGrid2$layer){
    GF_features$Mean_GF[GF_features$layer == layer_i] <- mean(MyGrid2$GF[MyGrid2$layer == layer_i])
  }
  return(GF_features)
}

# =============================================================================
# =============================================================================

CPlantBox <- function(path_python3, CPB_file){
  system(paste0("wsl ", path_python3, " ", CPB_file))
}
