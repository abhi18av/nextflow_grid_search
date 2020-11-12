nextflow.enable.dsl = 2

params.train_frame = "https://s3.amazonaws.com/erin-data/higgs/higgs_train_10k.csv"
params.test_frame = "https://s3.amazonaws.com/erin-data/higgs/higgs_test_5k.csv"

process H2O_NAIVE_BAYES {
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

# Build and train the model:
nb_model = H2ONaiveBayesEstimator(laplace=0,
                                 nfolds=5,
                                 seed=1234)

nb_model.train(x=predictors,
              y=response,
              training_frame=train)

# Eval performance:
test_perf = nb_model.model_performance(test)

print(test_perf.auc())
    """
}

//================================================================================
// Module test
//================================================================================

workflow test {


}
