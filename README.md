![_115017688_c6122844-332e-4516-a812-e56991e9374a](https://user-images.githubusercontent.com/91103250/195934400-d0edfd0d-2f3c-4d42-ac38-3bad2756a194.jpg)
*Fonte: https://www.bbc.com/portuguese/geral-54653975*
# Modelo Preditivo - Titanic

Com base na mais famosa competição do Kaggle, foi feito um modelo preditivo com o objetivo de prever se um passageiro iria ou não sobreviver com base nos seus dados de embarque.

### O Desastre do RMS Titanic
O destino do Titanic foi selado em sua viagem inaugural de Southampton, na Inglaterra, à cidade de Nova York. Às 23h40 de 14 de abril de 1912, a lateral do Titanic colidiu com um iceberg no norte do Atlântico, afundando partes do casco do estibordo por uma extensão de quase 100 metros e expondo à água do mar os seis compartimentos dianteiros à prova d’água. A partir daquele instante, o naufrágio era inevitável.

*Fonte: https://www.nationalgeographicbrasil.com/historia/2019/08/como-foi-o-naufragio-e-redescoberta-do-titanic*

### Dicionário de Dados

| Atributo  | Descrição | Métrica |
| ------------- | ------------- | ------------- |
| Survival | Marcador se o passageiro sobreviveu ou não | 0 = Não sobreviveu, 1 = Sobreviveu |
| pclass (Ticket class)  | Classe que o passageiro estava embarcado  | 1 = Primeira Classe, 2 = Segunda Classe, 3 = Terceira Classe |
| sex  | Sexo do passageiro  | Male/Female |
| Age  | Idade do passageiro  | Numérico |
| sibsp  | Número de irmãos/Cônjugues a bordo do Titanic  | Numérico |
| parch  | Content Cell  | Pai ou mãe/Filhos a bordo do Titanic |
| ticket  | Número da passagem  | Texto |
| Passenger fare  | Tarifa do passageiro  | Numérico |
| cabin number  | Número da cabine no Titanic  | Texto |
| embarked  | Porto de embarque  | C = Cherbourg, Q = Queenstown, S = Southampton |

Informações do dataset:

|  |  |
| ------------- | ------------- |
| Total de registros  | 1.309 |
| Total de atributos  | 12 |

*A fonte do dataset é: https://www.kaggle.com/c/titanic/overview*
