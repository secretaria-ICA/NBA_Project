# Mensurando o Impacto da Presença de Torcida nas Chances de Vitoria do Time da Casa em uma Partida da NBA

#### Aluno: [Stefanno Ruiz Manni](https://github.com/Stefanno28)
#### Orientador: [Manuela Kohler](https://github.com/manoelakohler) 
#### Co-orientador: [Felipe Borges](https://github.com/FelipeBorgesC) 

---

Trabalho apresentado ao curso [BI MASTER](https://ica.puc-rio.ai/bi-master) como pré-requisito para conclusão de curso e obtenção de crédito na disciplina "Projetos de Sistemas Inteligentes de Apoio à Decisão".

- [Link para o código](https://github.com/Stefanno28/NBA_Project).



---

### Resumo

A NBA é a maior liga de basquete do mundo e vem se internacionalizando a cada ano, com cada vez mais presença de jogadores de fora dos Estados
Unidos. Devido à sua grande popularidade e a cultura de estatística esportiva estadunidense muitos dados estão disponíveis para realização
de estudos para quem tiver interesse. Pensando nisso e no momento particular no esporte vivido pela época da Pandemia foi possível, pela primeira vez na historia,
a realizacao de um número significativo de jogos sem torcida. Assim, utilizando os resultados das temporadas da NBA entre 2016 e 2021 foi possível
criar modelos para prever o resultado de uma partida da NBA e em um segundo momento, esse modelos podem ser utilizados para entender
o impacto da presença de torcida. Os modelos criados utilizaram apenas variaveis possíveis de calcular com os resultados das partidas da NBA
e apresentaram uma acurácia em média de 65% nos dados de teste. Um problema comum para os modelos foi o overfitting, que ao ser contornado
resultava em modelos de menor acurácia nos dados de teste

### 1. Introdução

 NBA (National Basketball Association) é a principal liga de basquete do mundo, disputada nos Estados Unidos e que vem se expandindo internacionalmente ao longo dos ultimos anos.

Devido à grande cultura de dados, enraizada nos esportes estadunidenses, temos a nossa disposição uma infinidade de dados que nos possibilitam entender o jogo nos mínimos detalhes. 

Com a Pandemia do COVID19 surgiram algumas situações únicas que, pela primeira vez, nos permitem mensurar o real impacto que a presença de torcida possui, uma vez que tivemos um número significativo de jogos em quadra neutra.

Esse trabalho visa a criação de modelos de classificacao para a previsão do vencedor de uma partida da NBA e com esses modelos ser capaz de mensurar o real impacto da presenca de torcida em termos de aumentar as chances de vitoria do time da casa. Isso será feito a partir da análise do coeficiente da variavel que indica presenca de torcida.




Vamos retirar esses dados do site basketball-reference.com, utilizando crawler criado pelo arquivo de Funcoes_Aux_TCC.R 
Vamos tambem retirar os dados de capacidade maxima de cada arena para calculo da ocupacao das arenas nos jogos.
### 2. Modelagem

Para a modelagem foram retirados dados do site-basketball-reference.com utilizando um crawler criado dentro do arquivo Funcoes_Aux_TCC.R.
A Funçao criada para obtenção dos resultados das partidas é a função get_matches que recebe três parâmetros: uma lista com os anos
que se quer extrair os resultados das partidas, uma lista com os meses que ser quer extrair e a URL do site basketball-reference. O codigo
utiliza os anos e os meses das listas para construir a URL que contem os dados daquele respectivo ano e mes e é realizada uma extração
do html via pacote RVEST. Após a extração dos resultados alguns tratamentos ainda precisam ser realizados, como exclusao de algumas colunas
e identificação dos jogos de playoffs.

As demais funções dentro do arquivo Funcoes_AXU_TCC.R são utilizadas para construção das variáveis que serão utilizadas na modelagem:
1) Função check_results para verificar se o time da casa venceu o jogo, uma vez que os dados vinham apenas com a pontuacao do time da 
casa e do time visitante. Essa função foi utilizada para a criação da variável Home_Win.
2) Funcao calcula_sequencia para calcular a sequencia de derrotas ou vitorias tanto do time da casa quanto visitante. Funcao foi utilizada
para criação das variaveis Home_Win_Streak, Home_Loss_Streak, Away_Win_Streak, Away_Loss_Streak
3)Funcao calcula_win_ratio para cálculo da taxa de vitoria do time da casa e visitante antes da realizacao do jogo. Utilizada para criação
das variaveis Home_Win_Ratio e Away_Win_Ratio. Essa variáveis se mostraram sendo as mais significativas nos modelos,
4) Função calcula_descanso para cálculo de quantos dias de descanso cada time tinha antes da realizacao do jogo. As variaveis criadas foram
Home_Descanso e Away_Descanso.
5) Ultima funcao presente no arquivo é a funcao normalizar que utiliza o metodo MinMax para normalização das variáveis.

Assim as variáveis criadas foram (tanto para time da casa como para time visitante):

**1. TaxaDeVitoria:** Porcentagem de jogos vencidos pelo time ate a data daquele jogo.

**2. VitoriasEmSequencia:** Jogos vencidos em sequencia pelo time ate a data daquele jogo.

**3. DerrotasEmSequencia:** Jogos perdidos em sequencia pelo time ate a data daquele jogo.

**4. Dias de descanso:** Quantidade de dias entre o jogo atual e o ultimo jogo.

**5. Arena Occupation:** Ocupacao da arena pelos fas. Ja calculado. 

**6. Fans_Presence:** Presenca ou nao de torcida. Ja calculdado.

Foram utilizadas duas abordagens para modelagem:

1. Utilizar dados de três temporadas sem pandemia e criar a variavél ocupação (indicando quanto da capacidade da arena foi ocupada pelo publico) e entender seu impacto. E esperado que quanto maior o público presente maior as chances de vitoria do time da casa.

2. Utilizar dados da temporada 2019-2020 na qual a pandemia comecou e tivemos a realizacao da bolha da NBA. Os ultimos dez jogos de cada time naquela temporada regular foi realizada em quadra neutra. Com esses dados iremos criar a variavel presenca de publico (indicando se a partida foi realizada sem ou com torcida) e vamos analisar seu impacto nas chances de vitoria do time da casa. E esperado que essa variavel tenha impacto positivo nas chances de vitoria do time da casa.

A base de dados será construida a partir dos dados dos jogos das seguintes temporadas regulares da NBA:

2016-17  <br />
2017-18  <br />
2018-19  <br />
2019-20 --> temporada da bolha da NBA  <br />
2020-21 --> temporada com jogos sem torcida e publico limitado

Os modelos testados nas duas abordagens foram regressão logistica, random forest, xgboost e naive bayes.

### 3. Resultados

Os modelos nas duas abordagens nao apresentaram bons resultados, sofrendo de overfitting nos algoritmos random forest e xgboost. Mesmo após regularizacao dos
parametros dos modelos, aliviou-se o problema de overfittin, porém não foi possível ultrapassar a acurácia do modelo de regressão logistica.

O modelo de regressão logísitca apresentou uma acurácia de 65%, porém tanto a variável de presenca de torcida (abordagem 2) quanto a variável
de taxa de ocupação da arena não foram estatísticamente significativas (alto p-valor).

O Modelo Naive Bayes apresentou resultados parecidos com o modelo de regressão logística.

A utilização desses modelos para identificação do impacto da presença de torcida na chance do time da casa vencer fica limitado, uma vez
que não se obteve bons resultados.

Foram criados diversos modelos, afim de prever o vencedor de uma partida de basquete da NBA. Porém, esbarrou-se em uma acurácia de no máximo
65% nos dados de treino, dificultando a possibilidade de mensuração do impacto da presenca de torcida nos resultados das partidas.
Isso evidencia a necessidade de se obter mais dados sobre os times, afim de aumentar a acurácia do modelo e assim realizar a mensuração do impacto
da torcida. Não foram utilzadas nenhuma estatística avancada sobre os times, como por exemplo offensive rating, defensive rating que podem contribuir
para uma melhor performance dos modelos, assim como um melhor entendimento do jogo.
Como próximos passos, a obtenção dessas estatísticas serviria como um ponto de partida para melhores resultados.


### 4. Conclusões <br />

---

Matrícula: 201.110.695

Pontifícia Universidade Católica do Rio de Janeiro

Curso de Pós Graduação *Business Intelligence Master*
