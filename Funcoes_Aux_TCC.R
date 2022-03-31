## FUNCOES AUXILIARES TCC MASTER BI ##


#Carrega pacotes
library(rvest)
library(lubridate)
library(purrr)

#Cria funcao para extrair os jogos do site basketball-reference
get_matches <- function(years,months,URL){
  

  #inicializa df
  df = data.frame()
  contador <- 0
  
    #loop para os anos
    for(ano in years){
      
      #loop para os meses
      for (mes in months){
        
        #monta a URL
        url_final <- paste0(url,
                            ano,
                            "_games-",
                            mes,
                            ".html")
        #ajusta url para caso seja outubro de 2020
        # existem dois outubro naquela temporada
        #queremos apenas o outubro de 19 e nao de 20
        if (ano=='2020' && mes == 'october'){
          url_final <- paste0(url,
                              ano,
                              "_games-",
                              mes,
                              '-2019',
                              ".html")
          
        }
        
        #funcao para ler a paigna
        le_pagina <- function(URL){read_html(URL)}
        
        #le a pagina de forma segura
        webpage_safe <- safely(le_pagina)
        result_webpage <- webpage_safe(url_final)
        
        
        #caso a pagina de erro, passar para a proxima
        if (!is.null(result_webpage$error)){
          #print('leitura falhou!')
          next}
          else{
            #print('lendo url')
            webpage <- result_webpage$result
        } 
        
        
        #define nome das colunas
        col_names <- webpage %>% 
          html_nodes("table#schedule > thead > tr > th") %>% 
          html_attr("data-stat")    
        col_names <- c("game_id", col_names)
        
        
        
        #pega os dados, excluindo jogos de playoffs
        dates <- webpage %>% 
          html_nodes("table#schedule > tbody > tr > th") %>% 
          html_text()
        
        
        
        if (is.na(match("Playoffs",dates)) == FALSE){
          excluir <- seq(match('Playoffs',dates),length(dates))
          dates_regular <- dates[-excluir]
          dates_playoffs <- dates[excluir][-1]
        }else {
          dates_regular <- dates
          dates_playoffs <- NULL}
        
        #dates_regular

        game_id <- webpage %>% 
          html_nodes("table#schedule > tbody > tr > th") %>%
          html_attr("csk")
        
        if (is.na(match(NA,game_id)) == FALSE){
          excluir <- seq(match(NA,game_id),length(game_id))
          game_id_regular <- game_id[-excluir]
          game_id_playoffs <-game_id[excluir][-1]
        }else{
          game_id_regular <- game_id
          game_id_playoffs <- NULL
        }
        
        #game_id_regular <- game_id_regular[!is.na(game_id_regular)]
        
        

        #combina os dados
        data <- webpage %>% 
          html_nodes("table#schedule > tbody > tr > td") %>% 
          html_text() %>%
          matrix(ncol = length(col_names) - 2, byrow = TRUE)
        
        if(is.null(dates_playoffs) == F){
          data_regular <- data[-excluir,]
          data_playoffs <- data[excluir-1,][-1,]
        }else{
          data_regular <-data
          data_playoffs <- NULL
        }
        
        if(is.null(data_playoffs)==F){
          month_df_regular <- as.data.frame(cbind(game_id_regular, 
                                                  dates_regular, 
                                                  data_regular), 
                                            stringsAsFactors = FALSE)
          names(month_df_regular) <- col_names
          month_df_playoffs <- as.data.frame(cbind(game_id_playoffs,
                                                   dates_playoffs,
                                                   data_playoffs),
                                             stringsAsFactors = F)
          names(month_df_playoffs) <-col_names
        }else{
          month_df_regular <- as.data.frame(cbind(game_id_regular, 
                                                  dates_regular, 
                                                  data_regular), 
                                            stringsAsFactors = FALSE)
          names(month_df_regular) <- col_names
          month_df_playoffs <- NULL
        }
        
        #verificar se ultimo jogo no df eh playoffs
        if(contador == 0){
          #print('contador = 0')
          po <- 0
          diff <- 0
        }else{
          #print('contador <>0, calculando po e diff')
        po = df[length(df$game_id),12]
        
        
        #calcula diferenca entre ultimo jogo no df e primeiro jogo disponivel
        diff = difftime(mdy(month_df_regular[1,2]),
                        mdy(df[length(df$game_id),2]),
                            'days')
        }

        
        #cria flags de playoffs
        if(is.null(month_df_playoffs) == F){
          month_df_playoffs['FLAG_PLAYOFFS'] = 1
          month_df_regular['FLAG_PLAYOFFS'] = 0
          month_df = rbind(month_df_regular,month_df_playoffs)
        }else if(po==1 & diff <=15 & diff >=0){
          month_df_regular['FLAG_PLAYOFFS'] =1
          month_df = month_df_regular
        }else{
          month_df_regular['FLAG_PLAYOFFS'] = 0
          month_df = month_df_regular
        }
        
        #coluna temporada
        month_df['SEASON'] = ano
        
        
      
        #concatena no df
        df <- rbind(df,month_df)
        
        contador = contador + 1
        
        
        
      }
      
    }
  
  #ajusta o tipo de colunas
  df$visitor_pts <- as.numeric(df$visitor_pts)
  df$home_pts    <- as.numeric(df$home_pts)
  df$attendance  <- as.numeric(gsub(",", "", df$attendance))
  df$date_game   <- mdy(df$date_game)
  
  return(df)
    
  }
  

#Função para checar se "team_name" venceu o "game"
check_result <- function(team_name, game,tabela){
  
  if (tabela$visitor_team_name[tabela$id==game] == team_name & tabela$Home_Win[tabela$id==game]==0 ) {
    result<-"w"
    return(result)
  } else if (tabela$visitor_team_name[tabela$id==game] == team_name & tabela$Home_Win[tabela$id==game]==1) {
    result <- "l"
    return(result)
  } else if (tabela$home_team_name[tabela$id==game] == team_name & tabela$Home_Win[tabela$id==game]==1) {
    result <- "w"
    return(result)
  } else {
    result<- "l"
    return(result)}
}


#funcao para calcular vitorias e derrotas seguidas
calcula_sequencia <- function(tabela){
  
    seasons_list <- sort(unique(tabela$SEASON))
  
  for (season in seasons_list){
  teams_list <- sort(unique(tabela$home_team_name[tabela$SEASON==season]))
  for (team in teams_list){
    team_log <- sort(tabela$id[tabela$home_team_name==team & tabela$SEASON==season | tabela$visitor_team_name==team & tabela$SEASON==season])
    
    count <- 1
    last_result <- check_result(team, team_log[1],tabela = tabela)
    
    #Para cada um dos jogos selecionados
    range<-2:length(team_log)
    
    for (i in range){
      game <- team_log[i]
      game_index <- tabela$id[game]
      
      #Coloca valor de count nas colunas corretas
      
      if (last_result=="w" & (tabela$home_team_name[tabela$id==game]==team)){
        tabela[game_index, 17] = count
        tabela[game_index, 18] = 0
      }
      
      else if (last_result=="w" & (tabela$home_team_name[tabela$id==game]!=team)){
        tabela[game_index, 19] = count
        tabela[game_index, 20] = 0
      }
      else if (last_result=="l" & (tabela$home_team_name[tabela$id==game]==team)){
        tabela[game_index, 17] = 0
        tabela[game_index, 18] = count
        
      }
      else if (last_result=="l" & (tabela$home_team_name[tabela$id==game]!=team)){
        tabela[game_index, 19] = 0
        tabela[game_index, 20] = count
        
      }
      #atualiza count
      result <- check_result(team, game, tabela = tabela)
      if (last_result==result){
        count<-count+1
      }
      else{
        count<-1
        last_result<-result
      }
      
    }
    
  }
  }
  return(tabela)
}



#funcao para calcular taxa de vitoria
calcula_win_ratio <- function(tabela){
  
  seasons_list <- sort(unique(tabela$SEASON))
  
  for (season in seasons_list){
    teams_list <- sort(unique(tabela$home_team_name[tabela$SEASON==season]))
    for (team in teams_list){
      team_log <- sort(tabela$id[tabela$home_team_name==team & tabela$SEASON==season | tabela$visitor_team_name==team & tabela$SEASON==season])
      
      total_jogos <- 1
      total_vitorias <- 0
      win_ratio <- (total_vitorias/total_jogos)*100
      
      last_result <- check_result(team, team_log[1],tabela = tabela)
      
      #Para cada um dos jogos selecionados
      range<-2:length(team_log)
      
      for (i in range){
        game <- team_log[i]
        game_index <- tabela$id[game]
        
        #Coloca valor de taxa de vitorias nas colunas corretas
        
        if (last_result=="w" & (tabela$home_team_name[tabela$id==game]==team)){
          total_vitorias = total_vitorias + 1
          win_ratio = (total_vitorias/total_jogos)*100
          tabela[game_index, 21] = win_ratio
          }
        
        else if (last_result=="w" & (tabela$home_team_name[tabela$id==game]!=team)){
          total_vitorias = total_vitorias +1
          win_ratio = (total_vitorias/total_jogos)*100
          tabela[game_index, 22] = win_ratio
        }
        else if (last_result=="l" & (tabela$home_team_name[tabela$id==game]==team)){
          total_vitorias = total_vitorias
          win_ratio = (total_vitorias/total_jogos)*100
          tabela[game_index, 21] = win_ratio
          
        }
        else if (last_result=="l" & (tabela$home_team_name[tabela$id==game]!=team)){
          total_vitorias = total_vitorias
          win_ratio = (total_vitorias/total_jogos)*100
          tabela[game_index, 22] = win_ratio
  
          
        }
        #atualiza count
        result <- check_result(team, game, tabela = tabela)
        total_jogos = total_jogos + 1
        last_result<-result
        }
        
      }
      
  }
  return(tabela)
  }

#funcao para calcular dias de descanso
calcula_descanso <- function(tabela){
  
  seasons_list <- sort(unique(tabela$SEASON))
  
  for (season in seasons_list){
    teams_list <- sort(unique(tabela$home_team_name[tabela$SEASON==season]))
    for (team in teams_list){
      team_log <- sort(tabela$id[tabela$home_team_name==team & tabela$SEASON==season | tabela$visitor_team_name==team & tabela$SEASON==season])
      
      #Para cada um dos jogos selecionados, pulando o primeiro jogo
      range<-2:length(team_log)
      
      for (i in range){
        game <- team_log[i]
        game_anterior <- team_log[i-1]
        game_index <- tabela$id[game]
        
        descanso <- as.integer(difftime(ymd(tabela$date_game[tabela$id==game]),
                             ymd(tabela$date_game[tabela$id == game_anterior]),
                             'days')) - 1
    
        
        #Coloca valor de descanso nas colunas corretas
        
        if ((tabela$home_team_name[tabela$id==game]==team)){

          tabela[game_index, 23] = descanso
        }
        
        else if ((tabela$home_team_name[tabela$id==game]!=team)){
          tabela[game_index, 24] = descanso
        }
       
      }
      
    }
    
  }
  return(tabela)
}


#criando uma funcao de normalizacao
normalizar <- function(x){
  return ((x-min(x))/(max(x)-min(x)))
}


