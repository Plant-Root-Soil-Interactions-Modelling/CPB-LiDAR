#' Write params
#' 
#' Write plant parameters as xml file
#' @param_df A dataframe with plant parameters
#' @path The path of the xml file
CPB_write_param <- function(param_df, path){
  # Write xml param file with new parameters
  # param_df is 

  Wheat <- read_xml(path)  # Read the XML file outside the loop
  
  for (row_i in seq_len(nrow(param_df))) {
    # print(row_i)
    param_df_i <- param_df[row_i, ]
    organ_type_i <- param_df_i$organ_type
    organ_name_i <- param_df_i$organ_name
    param_name_i <- param_df_i$param_name
    param_value_i <- param_df_i$param_value
    
    organ_node <- xml_find_first(Wheat, paste0(".//organ[@type='", organ_type_i, "'][@name='", organ_name_i, "']"))
    parameter_node <- xml_find_first(organ_node, paste0(".//parameter[@name='", param_name_i, "']"))
    
    if (!is.null(parameter_node)) {
      xml_set_attr(parameter_node, "value", param_value_i)
    } else {
      # Node not found - you may want to handle this case
      cat("Node not found for:", organ_type_i, organ_name_i, param_name_i, "\n")
    }
  }
  
  write_xml(Wheat, path)  # Write the modified XML file after the loop
}