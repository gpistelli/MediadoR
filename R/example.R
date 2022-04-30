library(tidyverse)
library(rvest)

links <- c("http://www3.mte.gov.br/sistemas/mediador/Resumo/ResumoVisualizar?NrSolicitacao=MR082441/2015",
           "http://www3.mte.gov.br/sistemas/mediador/Resumo/ResumoVisualizar?NrSolicitacao=MR010095/2017",
           "http://www3.mte.gov.br/sistemas/mediador/Resumo/ResumoVisualizar?NrSolicitacao=MR008138/2019",
           "http://www3.mte.gov.br/sistemas/mediador/Resumo/ResumoVisualizar?NrSolicitacao=MR009875/2020",
           "http://www3.mte.gov.br/sistemas/mediador/Resumo/ResumoVisualizar?NrSolicitacao=MR000977/2021"
           )

CCT_df <- lapply(links, CCT.complete) %>% do.call(what = bind_rows, args = .) %>% as.data.frame()
row.names(CCT_df) <- gsub(pattern = "http(.+)NrSolicitacao(.+)/", replacement = "", x = links)
write.csv(x = CCT_df, file = "StiaCwb.csv", fileEncoding = "utf8")

CCT.find_nold_clauses(CCT_df) # Não houve nenhuma cláusula significativa retirada

piso_salarial <- CCT.get_monetary_values(CCT_df$`SALÁRIO NORMATIVO`) %>% lapply(X = ., FUN = CCT.convert_wage_to_int) %>%
  lapply(X = ., FUN = mean) %>% unlist()

names(piso_salarial) <- row.names(CCT_df)
piso_salarial <- piso_salarial/piso_salarial[1]

reaj_salario <- c(1, CCT.get_percent_value(CCT_df$`REAJUSTE SALARIAL`) %>% unlist() %>% CCT.convert_perct_to_num()+1)

reaj_salario_ano <- numeric(length(reaj_salario))
for (i in 1:length(reaj_salario)){
  reaj_salario_ano[i] <- prod(reaj_salario[1:i])
}

names(reaj_salario_ano) <- c("2014", row.names(CCT_df))

# 
cesta_bas <- read.csv("Cesta_DIEESE.csv", sep = ";")

cesta_bas$Tempo <- gsub(" [[:punct:]][[:digit:]][[:punct:]]", "", cesta_bas$Tempo)
cesta_bas$Curitiba <- gsub(pattern = ",", replacement = "\\.", x = cesta_bas$Curitiba)

cesta_bas <- cbind(do.call(args = str_split(cesta_bas$Tempo, "-"), what = rbind), cesta_bas$Curitiba) %>% as.data.frame()

cesta_bas_mean_year <- numeric(length(2014:2021))
years <- 2014:2021
for (i in 1:length(years)){
cesta_bas_mean_year[i] <- cesta_bas %>% filter(V2 == years[i]) %>% .$V3 %>% as.numeric() %>% mean()
}
cesta_bas_mean_year <- cesta_bas_mean_year/cesta_bas_mean_year[1]

# Começar a plotar com a inflação
plot(x = years, y = cesta_bas_mean_year, type = "l")
lines(x = names(piso_salarial), y = piso_salarial)
lines(x = names(reaj_salario_ano), y = reaj_salario_ano)
