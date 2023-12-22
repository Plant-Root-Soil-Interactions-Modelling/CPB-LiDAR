# =================================================================================
# Create directory
date <- paste0(Sys.Date())
suffix <- 1
dir_name <- paste0("results/",date, "_", suffix)

#If directory already exist, add 1 as suffix
while (dir.exists(dir_name)) {
  suffix <- suffix + 1
  dir_name <- paste0("results/",date, "_", suffix)
}

dir.create(dir_name)
dir.create(paste0(dir_name, "/Results"))
dir.create(paste0(dir_name, "/GF_layers"))
dir.create(paste0(dir_name, "/Results_plot"))
dir.create(paste0(dir_name, "/Simulations"))
dir.create(paste0(dir_name, "/csv"))

PS$id <- seq(1, length(PS[,1]))
write.csv(file = paste0(dir_name, "/Parametric_Space.csv"), x = PS, row.names = F)

#==================================================================================
# STEP 1 : RUN CPB THROUGH PARAMETRIC SPACE
#==================================================================================

Simulations <- data.frame()

iter_count <- 1
mean_it_time <- 10/60
time_start <- Sys.time()

print("Begin of CPlantBox loop...")

for(iter_id in PS$id){
  
  simulationID <- iter_id
  
  params_i <- PS%>%filter(id==iter_id)
  
  print(paste0("Iteration ", iter_count, " / ", length(PS$id)))
  print(paste0("Estimated time left : ", mean_it_time*(length(PS$id) + 1 - iter_count), " min"))
  print(params_i)
  
  # ============================================================================
  # Change params of interest
  # ============================================================================
  assign(param_name, params_i[1])
  # ============================================================================

  # Modify Wheat.xml
  Param_ID <- read.csv("data/Param_ID.csv")
  Params <- CPB_read_params("Wheat.xml")
  Params <- CPB_updateParams(Params)
  CPB_write_param(Params, "Wheat.xml")

  Params <- join(Params, Param_ID)
  Params <- Params[c("paramID", "param_value")]
  Params$simulationID <- simulationID

  # Save simulation
  write_csv(x = Params, file = paste0(dir_name,"/Simulations/", simulationID, ".csv"))
  Simulations <- rbind(Simulations, Params)

  # Writing CPB
  Write_CPB(type = "field", 
            param_filename = "Wheat.xml", 
            CPB_filename = CPB_filename,
            params_df = Params, 
            export_path = paste0(dir_name, "/csv/"),
            sim_name = iter_id,
            plot = F,
            vtp = F) # You can save VTP files, but it will take a lot of space
  # CPB_writeCPB_TS(Pfilename = "Wheat.xml", Params = Params, export_path = paste0(dir_name, "/csv/"), name = iter_id, plot = F, vtp = F)
  
  # ============================================================================
  # ============================================================================
  # Run CPB
  CPlantBox(path_python3 = path_python3, CPB_file = CPB_filename)
  # ============================================================================
  # ============================================================================
  
  time_end <- Sys.time()
  mean_it_time <- round((as.numeric(time_end) - as.numeric(time_start))/(60*iter_count), 1)
  iter_count <- iter_count+1
  
}

write_csv(file = paste0(dir_name,"/Simulations.csv"), x = Simulations)

print("End of CPlantBox loop.")
print("Loading csv files and computing LiDAR metrics...")

#==================================================================================
# STEP 2 : LOAD csv FILES AND MAKE GRIDS
#==================================================================================

# Loop for csv folder :
Results <- data.frame()
GF_layers_all <- data.frame()
csv_path <- paste0(dir_name, "/csv/")

mean_it_time2 <- 15/60
time_start2 <- Sys.time()
iter_count2 <- 1

# Loop through simulations
for(file in list.files(csv_path, pattern = ".csv")){
  
  #Load Simulation
  simu <- strsplit(file, ".csv")[[1]]
  simuID <- strsplit(simu, "_")[[1]][1]
  # simtimeID <- strsplit(simu, "_")[[1]][2]
  simtimeID <- simtime
  
  print(paste0("Importing simulation ", iter_count2, " / ", length(PS$id)))
  print(paste0("Estimated time left : ", mean_it_time2*(length(PS$id) + 1 - iter_count2), " min"))
  
  # csv_i <- read_fascicles(paste0(csv_path,file))[,c("X", "Y", "Z")] # read csv files
  csv_i <- read.csv(paste0(csv_path,file))
  
  #=============================================================================
  #=============================================================================
  print("Making CH and GF grid...")
  Metrics_i <- Extract_Metrics(vtp = csv_i, gridsize = grid_size, verbose = F, DT = 1, method = "mean")
  Metrics_i$simulationID <- simuID
  Metrics_i$simtime <- simtimeID
  #=============================================================================
  print("Making GF_layers grid...")
  GF_layers_i <- Extract_GF_layers(vtp = csv_i, gridsize = grid_size, DT = 1, method = "mean", layer_size = 20, n_layers = 6, verbose = F)
  GF_layers_i$simulationID <- simuID
  GF_layers_i$simtime <- simtimeID
  #=============================================================================
  # Save grids
  write_csv(x = Metrics_i, file = paste0(dir_name,"/Results/", simuID,"_", simtimeID,".csv"))
  write_csv(x = GF_layers_i, file = paste0(dir_name,"/GF_layers/", simuID,"_", simtimeID,".csv"))
  #=============================================================================
  #=============================================================================
  # hist(Metrics_i$Density)

  Grid_density <- ggplot(data = Metrics_i) +
    geom_tile(aes(x = X, y = Y, fill = Density)) +
    scale_color_viridis() +
    scale_fill_viridis() +
    coord_fixed() +
    theme_test()

  Grid_GF <- ggplot(data = Metrics_i) +
    geom_tile(aes(x = X, y = Y, fill = GF)) +
    scale_color_viridis() +
    scale_fill_viridis() +
    coord_fixed() +
    theme_test()

  Grid_CH <- ggplot(data = Metrics_i) +
    geom_tile(aes(x = X, y = Y, fill = CH)) +
    scale_color_viridis() +
    scale_fill_viridis() +
    coord_fixed() +
    theme_test()

  svg(paste0(dir_name, "/Results_plot/grid_", simuID, "_", simtimeID, ".svg"))
  GA <- grid.arrange(Grid_density, Grid_GF, Grid_CH)
  dev.off()

  Results <- rbind(Results, Metrics_i)
  GF_layers_all <- rbind(GF_layers_all, GF_layers_i)
  
  time_end2 <- Sys.time()
  mean_it_time2 <- round((as.numeric(time_end2) - as.numeric(time_start2))/(60*iter_count2), 1)
  iter_count2 <- iter_count2+1
  
  
  #===========================================================================
  # Implement here the extraction of features
  #===========================================================================
  
  #===========================================================================
  # Implement here the extraction of BBCH, DB and LAI
  #===========================================================================
}

write_csv(x = Results, file = paste0(dir_name, "/Results.csv"))
write_csv(x = GF_layers_all, file = paste0(dir_name, "/GF_layers_all.csv"))


