library(dplyr)
library(rpart)
library(plumber)

library(jsonlite)



#* @apiTitle Survival Prediction
#* @apiDescription Survival prediction for titanic Data

ath_db<-
  data_frame(user="chzelada",pass="hola123")

fit <- readRDS("final_model.rds")

#' Log some information about the incoming request
#' @param User
#' @filter logger
function(req,User){
  cat(as.character(Sys.time()), "-", 
      req$REQUEST_METHOD, req$PATH_INFO, "-", 
      req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR,' ',User, "\n")
  plumber::forward()
}


#' Log some information about the incoming request
#' @param User
#' @param Password
#' @filter Auth
function(req,res,User,Password){
  if(sum(User %in% ath_db$user)==1){
    password<-ath_db %>% filter(user == User) %>% pull(pass)
    if(Password==password){
      plumber::forward()
    } else {
      res$status <- 401 # Unauthorized
      return(list(error="incorrect Password"))
    }
  } else {
    res$status <- 401 # Unauthorized
    return(list(error="User doesnt exit"))   
  }
  
}


#' @param Cl.thickness that the passenger was on
#' @param Cell.size Passenger gender 
#' @param Cell.shape Passenger age
#' @post /single_cancer_prediction
function(Cl.thickness, Cell.size, Cell.shape){
  features <- data_frame(Cl.thickness=as.integer(Cl.thickness),
                         Cell.size=as.integer(Cell.size),
                         Cell.shape=as.integer(Cell.shape)
                        )
  out<-predict(logitmod, features, type = "response")
  as.character(out)
}


#' @param Observations that the passenger was on
#' @post /multiple_cancer_prediction
function(Observations){
  # json_data <- fromJSON(txt = Observations, flatten = TRUE)
  # json_data
  # features <- data_frame(Cl.thickness=as.integer(Cl.thickness),
  #                        Cell.size=as.integer(Cell.size),
  #                        Cell.shape=as.integer(Cell.shape)
  # )
  # out<-predict(logitmod, features, type = "response")
  # as.character(out)
  
  Cl.thickness <- c(as.integer(Observations$`1`$Cl.thickness), as.integer(Observations$`2`$Cl.thickness))
  Cell.size <- c(as.integer(Observations$`1`$Cell.size), as.integer(Observations$`2`$Cell.size))
  Cell.shape <- c(as.integer(Observations$`1`$Cell.shape), as.integer(Observations$`2`$Cell.shape))
  batch_data <- data.frame(Cl.thickness, Cell.size, Cell.shape)
  
  out<-predict(logitmod, newdata = batch_data, type = "response")
  
  as.character(out)
 
}


#' @post /echo
function(){
  print('Hola')
}
