#!/SYSTEM/R/3.3.2/bin/Rscript

Get_os <- function(){
    sysinf <- Sys.info()
    if (!is.null(sysinf)){
        os <- sysinf['sysname']
        if (os == 'Darwin')
            os <- "osx"
    } else { ## mystery machine
        os <- .Platform$OS.type
        if (grepl("^darwin", R.version$os))
            os <- "osx"
        if (grepl("linux-gnu", R.version$os))
            os <- "linux"
    }
    tolower(os)
}

round_df <- function(x, digits) {
    # round all numeric variables
    # x: data frame 
    # digits: number of digits to round
    numeric_columns <- sapply(x, mode) == 'numeric'
    x[numeric_columns] <-  round(x[numeric_columns], digits)
    x
}

DescribeDataset <- function(df){
  MVNSimulRaw <- describe(df, quant = c(.25, .75)) %>% as.data.frame(stringsAsFactors = FALSE)
  MVNSimul <- MVNSimulRaw %>% 
      rownames_to_column(var = "Parameters") %>% 
      left_join(UnitTable, by = "Parameters") %>% 
      select(Parameter, median, sd, min, Q0.25, mean, Q0.75, max)
  return(MVNSimul)
}
