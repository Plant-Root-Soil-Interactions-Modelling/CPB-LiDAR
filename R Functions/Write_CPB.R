#' Write CPlantBox
#' 
#' Write a python file to be run in linux with CPlantBox instructions
#' @type Select the type of simulation. Can be "solo", "field" or "field_TS" 
#' @param_filename The name of the xml plant parameters file that will be used by CPlantBox
#' @CPB_filename The name and path of the .py file that will be created
#' @paramS_df A dataframe with plant parameters
#' @export_path The path where to store the results
#' @sim_name The name of the results
#' @plot True if you want to display the field after simulating CPB
#' @vtp True to save VTP file

Write_CPB <- function(type, 
                      param_filename, 
                      CPB_filename, 
                      params_df = NULL, 
                      export_path = NULL, 
                      sim_name = NULL, 
                      plot = T,
                      simtime = NULL,
                      vtp = F){
  
  # Check if file already exist
  if(file.exists(CPB_filename)){
    cat("Replacing ", CPB_filename)
    file.remove(CPB_filename)
  } else{
    cat("Writing ", CPB_filename)
  }
  
  if(type == "solo"){
    CPB_writeCPB_solo(param_filename = param_filename, 
                      CPB_filename = CPB_filename, 
                      plot = plot,
                      simtime = simtime)
  }else if(type == "field"){
    CPB_writeCPB(param_filename = param_filename, 
                 CPB_filename = CPB_filename, 
                 params_df = params_df, 
                 export_path = export_path, 
                 sim_name = sim_name, 
                 plot = plot,
                 vtp = vtp)
  }else if(type == "field_TS"){
    CPB_writeCPB_TS(param_filename = param_filename, 
                    CPB_filename = CPB_filename, 
                    params_df = params_df, 
                    export_path = export_path, 
                    sim_name = sim_name, 
                    plot = plot, 
                    vtp = vtp)
  }else{stop("Wrong type provided : only 'solo', 'field' and 'field_TS' are allowed.")}
  
}
