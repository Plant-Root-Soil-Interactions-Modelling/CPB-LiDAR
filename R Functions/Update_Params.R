#' Update params
#' 
#' Contextual function that update a plant param dataframe with mannually encoded params
#' @param_df Dataframe with CPB plant parameters
CPB_updateParams <- function(param_df){
  
  # Checks
  pl <- c("leaf_lb", "leaf_la", "leaf_lmax", "leaf_r", "leaf_a", "leaf_Width_blade", "leaf_shapeType", "leaf_tropismT",
          "leaf_tropismN", "leaf_tropismS", "leaf_dx", "leaf_dxMin", "leaf_theta", "leaf_rit", "leaf_gf", "leaf_areaMax", "leaf_geometryN", 
          "stem_r", "stem_lmax", "stem_ln", "stem_theta", "maxTi")
  
  
  # field_params <- data.frame(organ_type = "field",
  #                            organ_name = "field",
  #                            param_name = c("simtime", "N_row", "N_col", "N_plots", "dist_col", "dist_row", "dist_plot"),
  #                            subType = 0,
  #                            param_value = c(simtime, N_row, N_col, N_plots, dist_col, dist_row, dist_plot))
  # param_df <- rbind(param_df, field_params)
  
  # Update plant params
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='lb'] = leaf_lb                        # lb = 8
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='la'] = leaf_la                        # la = 35
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='ln'] = leaf_ln                        # ln = 0
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='lmax'] = leaf_lmax                   # lmax = 43
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='r'] = leaf_r                       # r = 4
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='a'] = leaf_a                     # a = 0.1 
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='Width_petiole'] = leaf_Width_blade        # Width_petiole = 0.35
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='Width_blade'] = leaf_Width_blade           # Width_blade = 0.9
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='shapeType'] = leaf_shapeType               # shapeType = 1
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='tropismT'] = leaf_tropismT                # tropismT = 1
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='tropismN'] = leaf_tropismN               # tropismN = 20
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='tropismS'] = leaf_tropismS             # tropismS = 0.05
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='dx'] = leaf_dx                      # dx = 2
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='dxMin'] = leaf_dxMin                   # dxMin = 1
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='theta'] = leaf_theta                 # theta = 0.2
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='rit'] = leaf_rit            # rit = 1000000000
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='gf'] = leaf_gf                      # gf = 3
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='areaMax'] = leaf_areaMax                # areaMax = 35
  param_df$param_value[param_df$organ_type == 'leaf' & param_df$param_name =='geometryN'] = leaf_geometryN             # geometryN
  
  # Stem
  param_df$param_value[param_df$organ_type == 'stem' & param_df$organ_name == "mainstem" & param_df$param_name =='r'] = stem_r     
  param_df$param_value[param_df$organ_type == 'stem' & param_df$organ_name == "mainstem" & param_df$param_name =='lmax'] = stem_lmax     
  param_df$param_value[param_df$organ_type == 'stem' & param_df$organ_name == "mainstem" & param_df$param_name =='ln'] = stem_ln     
  param_df$param_value[param_df$organ_type == 'stem' & param_df$organ_name == "mainstem" & param_df$param_name =='theta'] = stem_theta     
  
  # Tiller
  param_df$param_value[param_df$organ_type == 'seed' & param_df$param_name =='maxTi'] = maxTi    
  
  # Field
  param_df$param_value[param_df$organ_type == "field" & param_df$param_name == "simtime"] = simtime
  param_df$param_value[param_df$organ_type == "field" & param_df$param_name == "N_row"] = N_row
  param_df$param_value[param_df$organ_type == "field" & param_df$param_name == "N_col"] = N_col 
  param_df$param_value[param_df$organ_type == "field" & param_df$param_name == "N_plots"] = N_plots 
  param_df$param_value[param_df$organ_type == "field" & param_df$param_name == "dist_col"] = dist_col 
  param_df$param_value[param_df$organ_type == "field" & param_df$param_name == "dist_row"] = dist_row 
  param_df$param_value[param_df$organ_type == "field" & param_df$param_name == "dist_plot"] = dist_plot 
  
  return(param_df)
}