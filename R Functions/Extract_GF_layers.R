#' Extract Gap Fraction
#' This function takes in input a cloud point (x, y and z coordinates) and return a map of gap fraction per layers
#' @vtp A point cloud in the format of a x,y and z dataframe
#' @gridsize The resolution of the algorithm in cm 
#' @DT Density Treshold : max density used for computing Gap Fraction
#' @layer_size Size in cm of the Gap Fraction layers
#' @n_layers Number of Gap Fraction layers
#' @verbose Prints or not

Extract_GF_layers <- function(vtp, gridsize, DT = 1, method = "max", layer_size = 20, n_layers = 6, verbose = T){
  # This function extract GF at different layers
  
  # Create Layers
  Layers <- data.frame(layer = seq(1,n_layers))
  Layers$h <- Layers$layer* layer_size
  
  # Specificities
  if(DT < 0 | DT > 1){
    stop("Density Treshold must be betwwen 0 and 1")
  }
  
  #Define Grid
  GS <- gridsize
  x_min <- min(vtp$X)
  x_max <- max(vtp$X)
  y_min <- min(vtp$Y)
  y_max <- max(vtp$Y)
  
  x_vec <- data.frame(X = seq(from = x_min, to = x_max, by = GS))
  y_vec <- data.frame(Y = seq(from = y_min, to = y_max, by = GS))
  
  MyGrid <- merge(x_vec, y_vec)
  MyGrid$Z <- 0
  
  MyGrid <- merge(x_vec, y_vec)
  MyGrid$Density <- NaN
  MyGrid$GF <- NaN
  MyGrid$layer <- NaN
  
  MyGridFinal <- data.frame()
  
  # Loop through the layers
  for(layer_i in seq(1, n_layers)){
    if(verbose == T){print(paste0("Layer : ", layer_i))}
    
    # Create PC subset
    PC_subset <- vtp %>% filter(Z < layer_i*layer_size & Z >= (layer_i - 1)*layer_size)
    
    # Create temp grid
    MyGrid_i <- MyGrid
    MyGrid_i$layer <- layer_i
    
    # ==========================================================================
    # Loop through PC_subset
    # ==========================================================================
    
    for(row_i in seq(1, length(MyGrid_i$X))){
      if(row_i %% 50 == 0 & verbose == T){
        print(paste0(row_i, " / ", length(MyGrid$X)))
      }
      # Range for each grid cell
      x_i <- MyGrid_i[row_i,]$X
      y_i <- MyGrid_i[row_i,]$Y
      
      # Make a local PC (find all data points inside the grid cell)
      PC_local <- PC_subset %>% filter(X >= x_i - GS/2 & X < x_i + GS/2 & Y >= y_i - GS/2 & Y  < y_i + GS/2)
      
      # Extract point density in the grid cell
      count_i <- length(PC_local$X)
      MyGrid_i$Density[MyGrid_i$X == x_i & MyGrid_i$Y == y_i] <- count_i 
    }
    
    # ==========================================================================
    # Compute gap fraction
    # ==========================================================================
    
    if(verbose == T){print("Computing Gap Fraction")}
    max_D <- DT*max(MyGrid_i$Density)
    for(row_i in seq(1, length(MyGrid_i$X))){
      d_i <- MyGrid_i$Density[row_i]
      MyGrid_i$GF[row_i] <- (max_D - d_i)/max_D
      if(MyGrid_i$GF[row_i]<0){
        MyGrid_i$GF[row_i]=0
      }
    }
    
    # Add temp grid to final grid
    MyGridFinal <- rbind(MyGridFinal, MyGrid_i)
    
    
  }
  
  return(MyGridFinal) 
}
