nextflow.enable.dsl = 2


process H2O_NAIVE_BAYES {
    container "quay.io/abhi18av/nextflow_grid_search"
    memory '4 GB'
    cpus 4

    input:
    tuple val(train_frame), val(test_frame)

    output:
    path('NaiveBayes_model_*')

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

# Train the model grid
nb_model.train(x=x,
              y=y,
              training_frame=train)

# Eval performance:
test_perf = nb_model.model_performance(test)

# Save the model
h2o.save_model(nb_model, "./", force=True)

# Explicitly print out the  the model's AUC on test data
print('AUC on Test data: ', test_perf.auc())
    """
}

//================================================================================
// Module test
//================================================================================

workflow test {
    input_data_ch = Channel.of([params.train_frame, params.test_frame])

    H2O_NAIVE_BAYES(input_data_ch)

}
