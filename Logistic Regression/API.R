library(dplyr)
library(plumber)
library(jsonlite)
library(logging)
basicConfig()


#* @apiTitle Breast Cancer Detection API
#* @apiDescription Breast cancer prediction model, based on cells' thickness, size, and shape.

# List of valid usernames
users<- c("chzelada", "tortolala")

# Trained model
fit <- readRDS("final_model.rds")


#' Saves information about the incoming request
#' @param User
#' @filter Pre-logger
function(req,User){
  log_user <<- User
  log_endpoint <<- req$PATH_INFO
  log_user_agent <<- req$HTTP_USER_AGENT
  log_method <<- req$REQUEST_METHOD
  plumber::forward()
}


#' User verification
#' @param User
#' @filter Auth
function(req,res,User){
  if(User %in% users){
    plumber::forward()
  } else {
    res$status <- 401 # Unauthorized code 
    logwarn('FAILED LOGIN BY USER: %s', User)
    return(list(error="401: User does not exist"))   
  }
}


#' @param Cl.thickness Cells' thickness
#' @param Cell.size Cells' size
#' @param Cell.shape Cells' shape
#' @post /single_cancer_prediction
function(Cl.thickness, Cell.size, Cell.shape){
  features <- data_frame(Cl.thickness=as.integer(Cl.thickness),
                         Cell.size=as.integer(Cell.size),
                         Cell.shape=as.integer(Cell.shape)
                        )
  out<-predict(logitmod, features, type = "response")
  
  out_final <- ifelse(out > 0.5, "malignant", "benign")
  
  loginfo('USER: %s, ENDPOINT: %s, USER AGENT: %s, PAYLOAD:  {Thickness: %s, Size: %s, Shape: %s}, OUTPUT: %s',
          log_user, 
          log_endpoint,
          log_user_agent,
          features$Cl.thickness,
          features$Cell.size,
          features$Cell.shape,
          out_final
          )
  
  as.character(out_final)

}


#' @param Observations Object with all observations on the batch
#' @post /multiple_cancer_prediction
function(Observations){
  
  Cl.thickness <- Observations$Cl.thickness
  Cell.size <- Observations$Cell.size
  Cell.shape <- Observations$Cell.shape
  batch_data <- data.frame(Cl.thickness, Cell.size, Cell.shape)
  
  out<-predict(logitmod, newdata = batch_data, type = "response")
  
  out_final <- ifelse(out > 0.5, "malignant", "benign")
  
  loginfo('USER: %s, ENDPOINT: %s, USER AGENT: %s, PAYLOAD: {Thickness: [%s], Size: [%s], Shape: [%s]}, OUTPUT: %s',
          log_user, 
          log_endpoint,
          log_user_agent,
          batch_data$Cl.thickness,
          batch_data$Cell.size,
          batch_data$Cell.shape,
          out_final
  )
  
  as.character(out_final)
  
}


#' @param Observations Object with all observations on the batch
#' @post /performance_metrics
function(Observations){
  
  Cl.thickness <- Observations$Cl.thickness
  Cell.size <- Observations$Cell.size
  Cell.shape <- Observations$Cell.shape
  Class <- Observations$Class
  
  batch_data <- data.frame(Cl.thickness, Cell.size, Cell.shape)
  test_data <- data.frame(Cl.thickness, Cell.size, Cell.shape, Class)
  
  out<-predict(logitmod, newdata = batch_data, type = "response")
  
  loginfo('USER: %s, ENDPOINT: %s, USER AGENT: %s, PAYLOAD: {Thickness: [%s], Size: [%s], Shape: [%s], Class: [%s]}, OUTPUT: %s',
          log_user, 
          log_endpoint,
          log_user_agent,
          test_data$Cl.thickness,
          test_data$Cell.size,
          test_data$Cell.shape,
          test_data$Class,
          as.character(format(out, digits=2, nsmall=2))
  )
  
  as.character(format(out, digits=4, nsmall=4))
  
}


