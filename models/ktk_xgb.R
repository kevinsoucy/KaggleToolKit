## Basic XGB Code for the Kaggle ToolKit
library(xgboost)
source("/media/hdd/kaggle/KaggleToolKit/helpers/model_helpers/xgb_helpers.R")

ktk_xgb <- function(input, mode='train', folds=FALSE){
  
  if (!("params" %in% names(input))){
    print("params option missing!")
    break
  }
  
  if (!(mode %in% c('train', 'cv'))){
    print(paste(mode, 'is an invalid option to mode. Set as train or cv'))
    break
  }
  
  if (!("nrounds" %in% names(input[['params']][[1]]))){
    print("nrounds input required but not found")
    break
  }
  
  if ((!("feval" %in% names(input)) & !("eval.metric" %in% names(input))) |
        (("feval" %in% names(input)) & ("eval.metric" %in% names(input)))){
    print("One (and only one) of feval or eval.metric is required")
    break
  }

  if (mode == 'train'){
    training_output<-train_mode(input)
    return(training_output)
  }
  
  if (mode == 'cv'){
    if (folds == FALSE){
      print('Folds is not set but cv is selected. Defaulting to 10.')
      folds <- 10
    }
    training_output <- cv_mode(input, folds)
  }

}