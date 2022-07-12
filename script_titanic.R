#Defininado diretório de trabalho
setwd('c:/FCD/Kaggle/Titanic')
getwd()

# 1 - Carregar dados para Data Frame

#O dataset de treino com 891 observações
df <- read.csv('train.csv') 

#O dataset de teste com 417 observações
df2 <- read.csv('test.csv')

#O dataset para registrar as previsões do modelo
submission <- read.csv('gender_submission.csv')

library(dplyr) #pacote para função bind_rows

#Dataset único para tratamento/analise dos dados inicial
full_df <- bind_rows(df,df2)
View(full_df)

library(tidyr)
library(rmarkdown)


# Dataset com os passageiros do Titanic, sendo que a coluna
# Survived é a variável target, onde 1 é sobrevivente e 0
# é morto no acidente

# 2 - Análise Exploratória dos Dados

str(full_df)
summary(full_df)

#Pclass está classificado como inteiro, na verdade é categórica. 
# O mesmo acontece para Sex

library(ggplot2)
histograma_idade <- ggplot(full_df,aes(x = Age)) + 
  geom_histogram(colour = 'Black', fill = 'dodgerblue3') +
  labs(y = 'Count', x = 'Passenger Age', title = 'Age x Survived - Titanic')
histograma_idade
# O histograma mostra uma população predominante na casa dos 20 anos,
# contudo vemos alguns valores NA que vão requerer algum tratamento
# é possível notar que a distribuição não é normal

Barras_sexo <- ggplot(full_df) + 
  geom_bar(aes(x = Survived, fill = Sex)) + 
  labs(y = 'Count', x = 'Passenger Gender', title = 'Gender x Survived - Titanic')
Barras_sexo
#O gráfico de barras mostra que o maior número de sobreviventes foram mulheres,
# talvez pelo fato de terem prioridade na evacuação. 
# Um sinal de que é uma key variable

Barras_Classe <- ggplot(full_df) + 
  geom_bar(aes(x = Survived, fill = as.factor(Pclass))) +
  labs(y = 'Count', x = 'Passenger Class', title = 'Class x Survived - Titanic')
Barras_Classe
# Pelo gráfico de barras, o maior número de sobreviventes eram da 1ª classe
# o que faz sentido pelo fato deles terem tido prioridade na evacuação
# Ao contrário da 3ª classe que teve o maior número de vitimas na tragédia
# Podemos inferir que essa á uma variável chave, o que será confirmado com o
# Feature Selection

# 3 - Tratamento dos dados

#A variável Age possui 177 valores missing, conforme abaixo.
library(Amelia) 
table(is.na(full_df$Age))
missmap(full_df)
# Nesse caso, será usado a média dos demais valores para ocupar esses NAs

missmap(full_df)
full_df$Age[is.na(full_df$Age)] <- mean(full_df$Age, na.rm = T)
full_df$Age <- round(full_df$Age, 0)

table(is.na(full_df$Age))

#Criação de coluna com títulos dos passageiros
# Pode ser uma informação interessante porque de acordo com o título, 
# o passageiro teve prioridade na evacuação


full_df$Title <- gsub("(.*, )|(\\..*)", "", full_df$Name) #separa string na , e no .

#Classficação dos Rare Titles
rare_titles <- c("Dona", "Lady", "the Countess", "Capt", "Col", "Don", "Dr", "Major", "Rev", "Sir", "Jonkheer")

#Ajustes nos títulos para Miss e Mrs
full_df$Title[full_df$Title == "Mlle"] <- "Miss"
full_df$Title[full_df$Title == "Ms"] <- "Miss"
full_df$Title[full_df$Title == "Mme"] <- "Mrs"

#Classificação dos títulos como rare, apenas os que estão na lista
full_df$Title[full_df$Title %in% rare_titles] <- "Rare"
unique(full_df$Title) #conferência dos valores únicos na coluna Title
full_df$Title <- as.factor(full_df$Title) #Coluna como fator
str(full_df)
rm(rare_titles) #remoção do vetor 


Barras_titles <- ggplot(full_df) + 
  geom_bar(aes(x = Survived, fill = Title)) + 
  labs(y = 'Count', x = 'Passenger Status', title = 'Title x Survived - Titanic')
Barras_titles

# A maior parte dos sobreviventes foram do título Miss (mulheres jovens e solteiras)


# Algumas variáveis precisam ser do tipo fator

fator <- c('Pclass', 'Sex', 'Title', 'Embarked')
full_df[fator] <- lapply(full_df[fator], function(x) as.factor(x))
str(full_df)
rm(fator)


# 4 - Separar os dados em treino e teste

df_train <- full_df[1:891,]
df_test <- full_df[892:1309,]
View(df_train)
View(df_test)

# 5 - Modelo de regressão logistica

model_logistic <- glm(Survived ~ Pclass + Parch + Sex + Age + SibSp + Embarked + Title, 
                      data = df_train, family = 'binomial')
summary(model_logistic)


library(caret)
variavel_modelo <- varImp(model_logistic)
plot_var <- variavel_modelo %>% arrange(desc(Overall)) %>% top_n(10)
plot_var <- round(plot_var,2)
plot_var$class <- row.names(plot_var)
ggplot(plot_var, 
       aes(x = reorder(class,-Overall), y = Overall)) +
       geom_col(colour = 'Black', fill = 'dodgerblue3') +
       labs(x = 'Variable', title = 'Top 10 Feature - Logistic Regression', y = 'Overall') +
       geom_text(aes(label = Overall, vjust = -0.4))


resultado_logistic <- predict(model_logistic, newdata = df_test, type = 'response')
aux_rl <- ifelse(resultado_logistic > 0.5, 1, 0)

#Gerar arquivo de resposta para o Kaggle!
submission_kaggle <- submission
submission_kaggle$Survived <- aux_rl
write.table(submission_kaggle, 'submission_titanic.csv',sep = ",", row.names = F)

#Score no Kaggle foi 0.77272 (77,2%)

