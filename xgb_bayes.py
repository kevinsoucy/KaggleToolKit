from bayes_opt import BayesianOptimization
# pip install git+https://github.com/fmfn/BayesianOptimization.git

# set md and n est yourself

# Define function to maximize
def rmseParams(lr, sub, col, al, lamb, gam, md, n):
    parameters = {
        'booster': 'gbtree',
        'objective': 'reg:linear',
        'eval_metric': 'rmse',  # multiclass log loss, merror = % wrong
        'silent': 1,
        'subsample': sub,
        'learning_rate': lr,
        'colsample_bytree': col,
        'max_depth': int(round(md)),
        'reg_alpha': al,
        'reg_lambda': lamb,
        'gamma': gam}
    xgb_model = xgb.train(parameters, dtrain, evals=evallist, num_boost_round=int(round(n)), early_stopping_rounds=200)
    preds_test = xgb_model.predict(dtest).tolist()
    preds_test = [0 if x < 0 else x for x in preds_test]
    xgbtesterr = skm.mean_squared_error(test_y, preds_test)
    # Maximize -1 * rmse on test set
    return -1*xgbtesterr

# Set limits on search space for each parameter
bo = BayesianOptimization(lambda lr, sub, col, al, lamb, gam, md, n: rmseParams(lr, sub, col, al, lamb, gam, md, n),
        {'lr': (.12, .12),
         'sub': (.6, .7),
         'col': (.79, .79),
         'al': (1.63, 1.63),
         'lamb': (1.178, 1.178),
         'gam': (0.8, .8),
         'md': (4, 5),
         'n': (400, 1000)
         }
        )

bo.maximize(init_points=2, n_iter=10)
