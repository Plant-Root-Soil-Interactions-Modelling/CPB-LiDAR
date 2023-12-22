#' Read params
#' 
#' Read plant parameters from a xml file, returns a dataframe
#' @path The path of the xml file
CPB_read_params <- function(path){
  # Load param.xml file for CPB as dataframe
  
  param_file <- read_xml(path)
  organs <- param_file %>% xml_find_all("organ")
  params_df <- data.frame()
  
  # Loop through each <organ> node and extract attributes
  for (node in organs) {
    
    # Extract organ type and name
    type <- xml_attr(node, "type")
    name <- xml_attr(node, "name")
    subType <- xml_attr(node, "subType")
    
    # print(paste0("Type ; ", type, "| Name : ", name, "| subType : ", subType))
    parameters <- node %>% xml_find_all("parameter")
    
    for(param_i in parameters){
      # Extract param values
      param_name_i <- xml_attr(param_i, "name")
      param_value_i <- xml_attr(param_i, "value")
      
      # print(paste0("     | param_name : ", param_name_i, "| param_value : ", param_value_i))
      temp_df_i <- data.frame(organ_type = type,
                              organ_name = name,
                              param_name = param_name_i,
                              subType = subType,
                              param_value = param_value_i
      )
      params_df <- rbind(params_df, temp_df_i)
    }
  }
  return(params_df)
}