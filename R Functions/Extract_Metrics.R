#' Extract basic LiDAR metrics from point cloud
#' Extract Crop Height, Gap Fraction and Density metrics from a point cloud (x,y,z dataframe)
#' @vtp A x,y and z dataframe
#' @gridsize The resolution of the algorithm (usually 15-20 cm)
#' @DT Density Treshold : max density used for computing Gap Fraction
#' @method The method of calculculation ("mean" or "max")
#' @verbose Prints or not

Extract_Metrics <- function(vtp, gridsize, method = "max", verbose = T, DT = 1){
    
  # Specificities
  if(DT < 0 | DT > 1){
    stop("Density Treshold must be betwwen 0 and 1")
  }
  
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
  MyGrid$CH <- NaN
  MyGrid$Density <- NaN
  MyGrid$GF <- NaN
  
  # Algorithm that superpose data to grid
  for(row_i in seq(1, length(MyGrid$X))){
    
    if(row_i %% 50 == 0 & verbose == T){
      print(paste0(row_i, " / ", length(MyGrid$X)))
    }
    
    # Range for each grid cell
    x_i <- MyGrid[row_i,]$X
    y_i <- MyGrid[row_i,]$Y
    
    # print(paste(x_i, " - ", y_i))
    
    # Make a local PC (find all data points inside the grid cell)
    PC_local <- vtp %>% filter(X >= x_i - GS/2 & X < x_i + GS/2 & Y >= y_i - GS/2 & Y  < y_i + GS/2)
    
    # Extract z = height
    if(nrow(PC_local) == 0){
      # print("T")
      mean_z <- 0
    }else{
      if(method == "mean"){
        mean_z <- mean(PC_local$Z)
      } else if(method == "max"){
        mean_z <- max(PC_local$Z)
      }
    }
    
    # Extract point density in the grid cell
    count_i <- length(PC_local$X)
    MyGrid$CH[MyGrid$X == x_i & MyGrid$Y == y_i] <- mean_z
    MyGrid$Density[MyGrid$X == x_i & MyGrid$Y == y_i] <- count_i 
  }
  
  
  max_D <- DT*max(MyGrid$Density)
  for(row_i in seq(1, length(MyGrid$X))){
    d_i <- MyGrid$Density[row_i]
    MyGrid$GF[row_i] <- (max_D - d_i)/max_D
    if(MyGrid$GF[row_i]<0){
      MyGrid$GF[row_i]=0
    }
  }
  
  return(MyGrid) 
}
