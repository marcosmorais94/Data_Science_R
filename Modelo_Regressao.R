

# Projeto Machine Learning - Tempo de Permanência

##### DEFINIÇÃO DO PROBLEMA DE NEGÓCIO ####

# O tempo de permanência é um indicador do tempo que o paciente fica internado. 
# Por conta de alguma complicação, uma internação que seria breve se torna algo
# mais complexo. Dessa forma, o custo médico do paciente aumenta consideralvemente.

# O objetivo desse projeto é identificar a probabilidade que um determinado
# pode fica internado de acordo com CID de alta. Para isso vamos analisar dados
#históricos desde 2020.


##### OBSERVAÇÔES ####
# Baixa complexidade - até 3 dias
# Média Complexidade - 3 a 7 dias
# Alta Complexidade - acima de 10 dias

###### SETUP DO RSTUDIO ######

#Definindo diretório de trabalho
setwd('C:/FCD/Projeto_Machine_Learning')
getwd()

#Pacotes utilizados
library(ggplot2)
library(readxl)
library(dplyr)
library(forcats)
library(rmarkdown)
library(rcompanion)
library(Amelia)
library(caret)
library(ROSE)
library(ROCR)


#Carga dos dados
BD <- read_excel(file.choose())
View(BD)

#Filtrando as colunas que serão usadas no modelo

col_names <- c('CARATER','Classe1','tempo_permanencia','Alta_Complexidade','IDADE', 'GENERO')
BD_MODELO <- BD[,col_names]

rm(col_names)

#Visualização dos dados
head(BD_MODELO)
str(BD_MODELO)
summary(BD_MODELO)

#### 2) PRÉ-PROCESSAMENTO ####


# Modelo de Regressão não aceita strings
# Por isso usamos variáveis categóricas (factor type)
BD_MODELO$CARATER <- as.factor(BD_MODELO$CARATER)
BD_MODELO$Classe1 <- as.factor(BD_MODELO$Classe1)
BD_MODELO$GENERO <- as.factor(BD_MODELO$GENERO)
BD_MODELO$Alta_Complexidade <- as.factor(BD_MODELO$Alta_Complexidade)

# Poucos registros NA, a melhor alternativa é removê-los
BD_MODELO2 <- na.omit(BD_MODELO)

str(BD_MODELO2)

round(prop.table(table(BD_MODELO2$Alta_Complexidade)),2)

# No gráfico abaixo temos um clara imagem que as classes estão
# desbalanceadas e isso vai ser tornar um problema para o modelo
# O modelo fica tendecioso a uma classe dessa forma
plot(BD_MODELO2$Alta_Complexidade)


#### 3) Modelo Preditivo ####


# Amostra de dados aleatória para divisão em treino e teste
# Garante a generalização do modelo
amostra_dados <- sample(x = nrow(BD_MODELO2),
                        size = 0.8 * nrow(BD_MODELO2),
                        replace = FALSE)

# Dados de treino e teste
dados_treino <- BD_MODELO2[amostra_dados,]
dados_teste <- BD_MODELO2[-amostra_dados,]
size = 0.8 * nrow(BD_MODELO2)

# Versão 1 do modelo
modelo_1 <- glm(Alta_Complexidade ~ ., data = dados_treino, family = 'binomial')
summary(modelo_1)

# Dados de treino sem a variável target
dados_modelo_teste <- dados_teste[,-3]

previsoes <- predict(modelo_1, newdata = dados_modelo_teste, type = 'response')
previsoes

# Em regressão logistica, probabilidades acima de 0,5 consideramos como
# um limite para divisão das classes
resultado_modelo <- ifelse(previsoes>0.5, "S", "N")
real <- dados_teste$Alta_Complexidade

# Modelo 1 mostra acurácia alta, mas taxa de erro alta para casos de 
# alta complexidade
confusionMatrix(table(data=resultado_modelo, reference = real))


# Balanceamento das classes
treino2 <- ovun.sample(Alta_Complexidade~., 
                       data = dados_treino,
                       method = 'both',
                       N = size)

plot(treino2$data$Alta_Complexidade)

# Versão 2 do modelo
modelo_2 <- glm(Alta_Complexidade ~ ., data=treino2$data, family = 'binomial')
previsoes_2 <- predict(modelo_2, newdata = dados_modelo_teste, type = 'response')
resultado_modelo2 <- ifelse(previsoes_2>0.5, "S", "N")

# Modelo teve uma redução da acurácia, mas em compensação acertou mais
# casos de alta complexidade
confusionMatrix(table(data=resultado_modelo2, reference = real))


# 7 Apresentação Resultados do Modelo

# Função para Plot ROC 
plot.roc.curve <- function(predictions, title.text){
  perf <- performance(predictions, "tpr", "fpr")
  plot(perf,col = "black",lty = 1, lwd = 2,
       main = title.text, cex.main = 0.6, cex.lab = 0.8,xaxs = "i", yaxs = "i")
  abline(0,1, col = "red")
  auc <- performance(predictions,"auc")
  auc <- unlist(slot(auc, "y.values"))
  auc <- round(auc,2)
  legend(0.4,0.4,legend = c(paste0("AUC: ",auc)), cex = 0.6, bty = "n", box.col = "white")
  
}

# Plot Curva ROC
Teste_ROC <- dados_teste
Teste_ROC$Alta_Complexidade <- ifelse(Teste_ROC$Alta_Complexidade == "S", 1, 0)

df_modelo <- as.data.frame(previsoes_2)
df_modelo <- ifelse(previsoes_2>0.5, 1, 0)

df_modelo1 <- as.data.frame(previsoes)
df_modelo1 <- ifelse(previsoes>0.5, 1, 0)

predictions_ <- prediction(df_modelo, Teste_ROC$Alta_Complexidade)
predictions_1 <- prediction(df_modelo1, Teste_ROC$Alta_Complexidade)
par(mfrow = c(1, 2))
plot.roc.curve(predictions_1, title.text = "Curva ROC - Modelo 1")
plot.roc.curve(predictions_, title.text = "Curva ROC - Modelo 2")


# Mddelo Final salvo como objeto
#saveRDS(modelo_2, 'modelo_regressao.rds')
#print(modelo_2)

# Usar modelo salvo como objeto
#modelo_regresso <- readRDS('modelo_regressao.rds')

# Previsoes com modelo salvo
# Incluir dataframe com novos dados aqui para futuras previsões

# novos_dados <- newdf
#previsoes_novas <- predict(modelo_regressao, newdata = dados_modelo_teste, type = 'response')

# DataFrame com os novos resultados
#resultado_novo <- ifelse(previsoes_novas>0.5, "S", "N")
#excel_modelo <- #cbind(newdf, resultado_novo)
  
# Export do dados resultantes do modelo
  
# comando para exporat excel aqui