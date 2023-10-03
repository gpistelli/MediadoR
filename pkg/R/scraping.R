#' Get a NCT text
#'
#' Download raw text from a Collective Bargaining Contract (Negociacao Coletiva de Trabalho - NCT) with some formatting
#'
#' @param path Either a Mediador link or a file path to a NCT
#' @return A character vector
#' @examples
#' NCT_get_NCT("http://www3.mte.gov.br/sistemas/mediador/Resumo/ResumoVisualizar?NrSolicitacao=MR039775/2018")
#' NCT_get_NCT("SENGE_SICEPOT_2018.html")
#'
#' @import magrittr
#' @export
NCT_get_NCT <- function(path){
  NCT <- rvest::read_html(path, encoding = "utf8") %>% rvest::html_nodes("b , p") %>% rvest::html_text()
  NCT <- gsub("\r|\n", "", NCT)
  NCT <- gsub("  ", "", NCT)
  return(NCT)
}

#' Get a NCT clauses
#'
#' Filter a clause/article from a NCT and names it
#'
#' @param vec A NCT character vector, usually from a NCT_get_NCT object
#' @param n The order of that clause in your NCT
#' @param pos A blueprint of where all clauses start in your vector
#' @return A named character vector containing an article from your NCT
#'
#' @export
NCT_get_clauses <- function(vec, n, pos){
  claus <- if(is.na(vec[pos[n+1]])) {
    vec[pos[n]:length(vec)]} else {
      vec[pos[n]:(pos[n + 1] - 1)]
    }

    name_claus <- unlist(strsplit(claus[1], " - "))
    name_claus <- name_claus[-grep(pattern = "CLÁUSULA", x = name_claus, ignore.case = T)]
    name_claus <- ifelse(test = length(name_claus) > 1, yes = paste(name_claus, collapse = " "), no = name_claus)

    claus <- paste(claus, collapse = " ")
    names(claus) <- name_claus
    return(claus)
}

#' Organize NCT
#'
#' Filter all articles and paste them together in a named character vector
#'
#' @param NCT A character vector containing all your articles and extracted from NCT_get_NCT
#'
#' @export
NCT_organize_NCT<- function(NCT){
  pos <- grep("^CLÁUSULA", NCT)

  vec <- unlist(lapply(X = 1:length(pos), FUN = NCT_get_clauses, vec = NCT, pos = pos))

  return(vec)
}

#' Get an organized NCT
#'
#' Wrapper of our original NCT scraping functions, working as an end-to-end function
#'
#' @param Either a Mediador link or a file path to a NCT
#' @return An organized named character vector
#'
#' @export
NCT_get_complete_NCT <- function(path){
  NCT <- NCT_get_NCT(path)
  NCT <- NCT_organize_NCT(NCT)
  return(NCT)
}

#' Generate file name for your data.frame
#'
#' Generates a file name for your data.frame, taking a year from each of its row names.
#' It's intended to be an easy way to automate and standardize our files, making it easy to find them in our github.
#'
#' @param sind A union name. Our convention is to use the labor unions name here, if there's many of them, select the most important one.
#' @param negot Another part name. It can be an enterprise, federation, etc.
#' @param df Your data.frame to be exported. Be careful so that it follows our standards. To see it, check our github page.
#' @param row_chos A row to isolate and store as a data.frame.
#'
#' @examples
#' for (i in 1:nrow(CCT_df)){
#' write.csv(x = CCT_df[i,],
#'           file = NCT_generate_file_name("STIAC", "SINDITRIGO", CCT_df, i),
#'           fileEncoding = "utf8")
#' }
#'
#' @export
NCT_generate_file_name <- function(sind, negot, df, row_chos){
  return(paste0(sind, "_", negot, "_", row.names(df)[row_chos], ".csv"))
}

#' Extract monetary values
#'
#' Extracts monetary values (in R$) from a string or a vector of strings. Recommended to study wages.
#'
#' @param vec A string or vector of strings with monetary values (R$)
#' @return A list of strings containing your monetary value(s)
#' @examples
#' NCT_get_monetary_values(CCT_df$`SALARIO NORMATIVO`)
#' NCT_get_monetary_values(CCT[`SALARIO NORMATIVO`])
#'
#' @export
NCT_get_monetary_values <- function(vec){
vec  <- stringr::str_extract_all(pattern = "R\\$(.+?)[[:blank:]]", string = vec)
return(stringr::str_trim(vec))
}

#' Convert monetary value to numeric
#'
#' Converts your monetary value string into a numeric value, cleaning and adjusting symbols.
#' Takes "." as a filler and changes "," into "." to represent decimals.
#'
#' @param vec A string or vector of strings containing an extracted monetary value
#' @return A vector of numeric values
#' @examples
#' NCT_convert_mon_to_num("R$ 1.233,50")
#'
#'
#' @import magrittr
#' @export
NCT_convert_mon_to_num <- function(vec){
  gsub(pattern = "R\\$", replacement = "", x = vec) %>% gsub("\\.|[[:blank:]]", "", .) %>% gsub(",", "\\.", .) %>%
    as.character.numeric_version() %>% as.numeric()
}

#' Extracts percentages values
#'
#' Extracts percentages values from a character string. Recommended to study wages correction.
#'
#' @param vec A string or vector of strings containing percentages values
#' @return A list of strings containing percentage(s) value(s)
#' @examples
#' NCT_get_percent_value(CCT_df$`REAJUSTE SALARIAL`)
#'
#' @export
NCT_get_percent_value <- function(vec){
  vec  <- stringr::str_extract_all(string = vec, pattern = "([[:digit:]]+)([[:punct:]]*)([[:digit:]]*)%")
return(stringr::str_trim(vec))
}

#' Converts percentages to numeric
#'
#' Converts percentage values to numeric, also dividing them by 100 to represent percentages in a proportion.
#'
#' @param vec A extracted string (or a vector of those) containing a percentage value
#' @return A numeric value
#' @examples
#' NCT_convert_perct_to_num("5%")
#'
#' @import magrittr
#' @export
NCT_convert_perct_to_num <- function(vec){
  vec <- gsub(",", "\\.", vec) %>% gsub("[[:blank:]]|%", "", .) %>%
    as.numeric()
  vec <- vec/100
  return(vec)
}

#' Generate ggplot data.frame
#'
#' Create a new data.frame from a named vector containing some periodically variation.
#' Uses these vectors names as their period (generally, if we are talking about NCTs, a year)
#'
#' @param obj_name A string to represent your object analyzed
#' @param vec A named vector containing its time period as names and numeric values
#' @return A ggplot2 like data.frame to bind and create time series plots
#'
#' @examples
#' piso_salarial <- c("2012" = 2343, "2013" = 2566, "2014" = 2777)
#' NCT_generate_ggplot2_df("Piso", piso_salarial)
#'
#' @export
NCT_generate_ggplot2_df <- function(obj_name, vec){
  df <- as.data.frame(cbind(rep(obj_name, length(vec)), names(vec), vec))
  return(df)
}

#' Finds old and new articles
#'
#' Finds old and new articles from a data.frame containing ordered articles of these NCT.
#' Recommended to be used with `dplyr` `bind_rows` to create your data.frames
#'
#' @param A data.frame containing columns with NA, representing articles that were added or taken out
#' @return A named character vector with these articles conditions
#'
#' @import magrittr
#' @export
NCT_find_nold_clauses <- function(df){
nold_clauses <- unlist(lapply(X = lapply(X = df[1:ncol(df)], FUN = is.na), any))
vec <- lapply(X = df[names(nold_clauses[nold_clauses])], FUN = is.na) %>% do.call(what = cbind, args = .) %>%
  as.data.frame() %>% .[nrow(.),]

vec <- ifelse(vec == TRUE, "Retirado", "Novo")

return(vec)
}
