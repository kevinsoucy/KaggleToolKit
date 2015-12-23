## Example Usage File for the Kaggle Toolkit
# When using the kgalle toolkit, first set a seed using set.seed()
set.seed(5277)

# Using the Kaggle rossman data as an example, we'll construct the required data object
# for the XGB kaggle toolikit package 
source('/media/hdd/kaggle/rossman/code/make_data.R')

### PASSING THE DATA ###
# In general the KTK requires the following for DATA
# 1. A named list object is passed to the modeling object, train=TRAINING DATA test=Testing Data
#    For consistency, the training and testing split is left outside the modeling framework unless
#    the mode is set to CV. If the mode is set to CV and that is enabled for the requested model
#    then train=TRAINING DATA is all that is required
# 2. All data should be prepped for modeling as required by the requested model type. The outcome
#    variable should be last. 

variable_order = c(names(train_gbl)[-3], 'Sales') # note target is last!!

my_training_data = train_gbl[, variable_order]
my_testing_data = test_glb[, variable_order]

model_ = list(train=my_training_data, test=my_testing_data)

### USING THE KTK MODELS: XGB ###
# Using the KTK XGB module is extreamly simple. First source the module
# POINT TO THE CORRECT REPO LOCATION
source('/media/hdd/kaggle/KaggleToolKit/models/ktk_xgb.R')

# Next set up the XGB paramter object. This should be itself a named list
param_in <- list( objective = "reg:linear", 
                  booster = "gbtree", eta = .09, max_depth = 10,
                  subsample = 0.7, colsample_bytree = 0.7 # 0.7
)
xgbp = list(nrounds=20, main=param_in)

# it, itself should be passed to the main model object
# as a list element named "params":
model_[["params"]] <- list(xgbp, xgbp)

# note that the list is required. If multiple elements are detected within 
# "params" then all will be run and the best will be returned. This is 
# the tuning paradaigm


# Set your F-eval metrics
# A custom error function can be made (or imported from KaggleToolKit/helpers/ktk_errorfuncs.R)
# if a customized error function is set, the list element should be called feval
# model_[["feval"]] = function

# otherwise set model_[["eval.metric"]] = valid XGB eval metric 
#(https://xgboost.readthedocs.org/en/latest/parameter.html)
model_[["eval.metric"]] <- "rmse"

## With this set you can call the XGB wrapper:
example_model <- ktk_xgb(model_, mode='train')

# mode can be either "train" or "cv". If mode is set to "cv", you must set folds=[2-INF]

# you can set additional options to xgb.train (when using the ktk_xgb) by setting them EXACTLY as found 
# in the documentation
model_['early.stop.round'] <- 100
model_['maximize'] <- FALSE

# Call the training model
training_example <- ktk_xgb(model_, mode='cv')
