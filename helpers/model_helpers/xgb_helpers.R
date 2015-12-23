make_dmat <- function(ds, target_col){
  mat <- xgb.DMatrix(data=data.matrix(ds[, -target_col]), 
                            label=data.matrix(ds[, target_col]))
  return(mat)
}


train_mode <- function(input){
  
  training_data <- input$train
  testing_data <- input$test
  
  target_col <- ncol(training_data)
  
  train_dmat <- make_dmat(training_data, target_col)        
  test_dmat <- make_dmat(testing_data, target_col)
                            
  watch_me_now <- list(val=test_dmat, train=train_dmat)
                            
  print('setup complete. Parsing options...')
                            
  early.stop.round = 50
  if ("early.stop.round" %in% names(input)){
    early.stop.round = input[["early.stop.round"]]
  }
                            
  maximize = FALSE
  if ("maximize" %in% names(input)){
    maximize = input[["maximize"]]
  }
                            
  if ("feval" %in% names(input)){
    feval = input[["feval"]]
            
    trained_models <- list()
    total_training <- length(input[["params"]])
    print(paste("found", total_training, "models requested"))
    
    for(i in seq(1, total_training)){

      print(paste("############# on", i, "of", total_training, "##############"))
      nrounds = input[["params"]][[i]][["nrounds"]]
      params = input[["params"]][[i]][["main"]]
      
      trained_xgb <- xgb.train(params = params,
                               data = train_dmat,
                               nrounds = nrounds,
                               verbose = 1,
                               early.stop.round = early.stop.round,
                               watchlist = watch_me_now,
                               maximize = maximize,
                               feval=feval
      )
      
      trained_models[[i]] <- list(model_object=trained_xgb, val_score=trained_xgb$bestScore, at_round=trained_xgb$bestInd)
      
    }
  }
  
  if ("eval.metric" %in% names(input)){
    eval.metric = input[["eval.metric"]]
    
    trained_models <- list()
    total_training <- length(input[["params"]])
    print(paste("found", total_training, "models requested"))
    
    for(i in seq(1, total_training)){

      print(paste("############# on", i, "of", total_training, "##############"))
      nrounds = input[["params"]][[i]][["nrounds"]]
      params = input[["params"]][[i]][["main"]]
      
      trained_xgb <- xgb.train(params = params,
                               data = train_dmat,
                               nrounds = nrounds,
                               verbose = 1,
                               early.stop.round = early.stop.round,
                               watchlist = watch_me_now,
                               maximize = maximize,
                               eval.metric=eval.metric
      )
      
      trained_models[[i]] <- list(model_object=trained_xgb, val_score=trained_xgb$bestScore, at_round=trained_xgb$bestInd)
      
    }
  }

  return(trained_models)
  
}


cv_mode <- function(input, folds){
  
  tr_rows <- nrow(input$train)
  fold_split <- c(rep(seq(1, folds), (tr_rows - (tr_rows %% folds))/folds), 1:(tr_rows %% folds))

  #training_data <- split(input$train, fold_split)
  #train_dmat <- lapply(training_data, make_dmat, target_col)
  #test_dmat <- make_dmat(testing_data, target_col)

  training_data <- input$train
  testing_data <- input$test
  
  target_col <- ncol(training_data)
                            
  print('setup complete. Parsing options...')
                            
  early.stop.round = 50
  if ("early.stop.round" %in% names(input)){
    early.stop.round = input[["early.stop.round"]]
  }
                            
  maximize = FALSE
  if ("maximize" %in% names(input)){
    maximize = input[["maximize"]]
  }
                            
  
                            
  if ("feval" %in% names(input)){
    feval = input[["feval"]]
            
    trained_models <- list()
    total_training <- length(input[["params"]])
    print(paste("found", total_training, "models requested"))
    
    for (i in seq(1, total_training)){

      print(paste("############# on", i, "of", total_training, "##############"))
      all_trained_xgb <- list()
      perf <- c()
      for (j in seq(1, folds)){

        print(paste("############# on fold", j, "of", folds, "##############"))

        train_dmat <- make_dmat(subset(training_data, fold_split!=j), target_col)        
        test_dmat <- make_dmat(subset(training_data, fold_split==j), target_col)
                                  
        watch_me_now <- list(val=test_dmat, train=train_dmat)

        nrounds = input[["params"]][[i]][["nrounds"]]
        params = input[["params"]][[i]][["main"]]
              
        trained_xgb <- xgb.train(params = input[["params"]][[1]][["main"]],
                                  data = train_dmat,
                                  nrounds = nrounds,
                                  verbose = 1,
                                  early.stop.round = early.stop.round,
                                  watchlist = watch_me_now,
                                  maximize = maximize,
                                  feval=feval
                                )

        all_trained_xgb[[j]] <- trained_xgb
        perf <- c(perf, trained_xgb$bestScore)

      }
      
      trained_models[[i]] <- list(model_object=all_trained_xgb, val_score=mean(perf), at_round=which.min(perf))
      
    }
  }
  
  if ("eval.metric" %in% names(input)){
    eval.metric = input[["eval.metric"]]
    
    trained_models <- list()
    total_training <- length(input[["params"]])
    print(paste("found", total_training, "models requested"))
    
    for (i in seq(1, total_training)){

      print(paste("############# on", i, "of", total_training, "##############"))
      all_trained_xgb <- list()
      perf <- c()
      for (j in seq(1, folds)){

        print(paste("############# on fold", j, "of", folds, "##############"))

        train_dmat <- make_dmat(subset(training_data, fold_split!=j), target_col)        
        test_dmat <- make_dmat(subset(training_data, fold_split==j), target_col)
                                  
        watch_me_now <- list(val=test_dmat, train=train_dmat)

        nrounds = input[["params"]][[i]][["nrounds"]]
        params = input[["params"]][[i]][["main"]]
              
        trained_xgb <- xgb.train(params = input[["params"]][[1]][["main"]],
                                  data = train_dmat,
                                  nrounds = nrounds,
                                  verbose = 1,
                                  early.stop.round = early.stop.round,
                                  watchlist = watch_me_now,
                                  maximize = maximize,
                                  eval.metric=eval.metric
                                )

        all_trained_xgb[[j]] <- trained_xgb
        perf <- c(perf, trained_xgb$bestScore)

      }
      
      trained_models[[i]] <- list(model_object=all_trained_xgb, val_score=mean(perf), at_round=which.min(perf))
      
    }
  }

  return(trained_models)
  
}