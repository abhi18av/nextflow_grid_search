nextflow.enable.dsl = 2

params.train_frame = "https://s3.amazonaws.com/erin-data/higgs/higgs_train_10k.csv"
params.test_frame = "https://s3.amazonaws.com/erin-data/higgs/higgs_test_5k.csv"

process H2O_GRID_NAIVE_BAYES {
    container "quay.io/abhi18av/nextflow_grid_search"

    input:
    tuple file(params.train_frame), file(params.test_frame)

    output:
    stdout auc

    script:
    """
#!/usr/bin/env python3

import h2o
from h2o.estimators import H2ONaiveBayesEstimator
from h2o.grid.grid_search import H2OGridSearch
h2o.init()

# Import a sample binary outcome train/test set into H2O
train = h2o.import_file("${params.train_frame}")
test = h2o.import_file("${params.test_frame}")

# Identify predictors and response
x = train.columns
y = "response"
x.remove(y)

# For binary classification, response should be a factor
train[y] = train[y].asfactor()
test[y] = test[y].asfactor()

# Number of CV folds (to generate level-one data for stacking)
nfolds = 5

nb_hyperparams = {
'laplace': [0, 1, 2],
'min_sdev': [0.3, 0.6, 0.9],
'min_prob': [0.3, 0.6, 0.9]
}

# Build and train the model:
nb_base_model = H2ONaiveBayesEstimator(
                                        nfolds=5,
                                        seed=1234)


nb_grid = H2OGridSearch(model=nb_base_model,
                        hyper_params=nb_hyperparams)


nb_grid.train(x=x, 
             y=y,
             training_frame=train,
             validation_frame=test)

best_nb_model = nb_grid.get_grid(sort_by='auc', decreasing=True)[0]

# Now let's evaluate the model performance on a test set
# so we get an honest estimate of top model performance
best_nb_model_perf = best_nb_model.model_performance(test)

print(best_nb_model_perf.auc())
    """
}

//================================================================================
// Module test
//================================================================================

workflow test {


}
