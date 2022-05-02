# Coletar as NC

CCT.get_CCT <- function(link){
  CCT <- read_html(link, encoding = "utf8") %>% html_nodes("b , p") %>% html_text()
  CCT <- gsub("\r\n", "", CCT)
  CCT <- gsub("  ", "", CCT)
  # blanks <- grep("^[:blank:]", CCT)
  # CCT <- CCT[-blanks]
  return(CCT)
}

CCT.get_clauses <- function(vec, n, pos){
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

CCT.organize_CCT<- function(CCT){
  pos <- grep("^CLÁUSULA", CCT)
  
  vec <- unlist(lapply(X = 1:length(pos), FUN = CCT.get_clauses, vec = CCT, pos = pos))
  
  return(vec)
}

CCT.complete <- function(link){
  CCT <- CCT.get_CCT(link)
  CCT <- CCT.organize_CCT(CCT)
  return(CCT)
}

CCT.generate_file_name <- function(sind, df, row_chos){
  return(paste0(sind, "_", row.names(df)[row_chos], ".csv"))
}


# Wrangling

CCT.get_monetary_values <- function(vec){
vec  <- str_extract_all(pattern = "R\\$(.+?)[[:blank:]]", string = vec)
return(vec)
}

CCT.get_percent_value <- function(vec){
  vec  <- str_extract_all(string = vec, pattern = "([[:digit:]]+)([[:punct:]]*)([[:digit:]]*)%")
return(vec)
}

CCT.convert_perct_to_num <- function(vec){
  vec <- gsub(",", "\\.", vec) %>% gsub("[[:blank:]]|%", "", .) %>%  as.numeric()
  vec <- vec/100
  return(vec)
}

CCT.convert_wage_to_int <- function(vec){
  gsub(pattern = "R\\$", replacement = "", x = vec) %>% gsub("\\.|[[:blank:]]", "", .) %>% gsub(",", "\\.", .) %>%
    as.character.numeric_version() %>% as.numeric()
}

CCT.find_nold_clauses <- function(df){
nold_clauses <- unlist(lapply(X = lapply(X = df[1:ncol(df)], FUN = is.na), any))
vec <- lapply(X = df[names(nold_clauses[nold_clauses])], FUN = is.na) %>% do.call(what = cbind, args = .) %>%
  as.data.frame() %>% .[nrow(.),]

vec <- ifelse(vec == TRUE, "Retirado", "Novo")

return(vec)
}

