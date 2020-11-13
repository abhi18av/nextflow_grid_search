nextflow.enable.dsl = 2

process H2O_GRID_NAIVE_BAYES {
    container "quay.io/abhi18av/nextflow_grid_search"
    memory '4 GB'
    cpus 4

    input:
    tuple val(train_frame), val(test_frame)

    output:
    path('nb_grid')

    script:
    """
#!/usr/bin/env python3

import h2o
from h2o.estimators import H2ONaiveBayesEstimator
from h2o.grid.grid_search import H2OGridSearch
h2o.init()

# Import a sample binary outcome train/test set into H2O
train = h2o.import_file("${train_frame}")
test = h2o.import_file("${test_frame}")

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

print(nb_grid)

# Now let's evaluate the model performance on a test set
# so we get an honest estimate of top model performance
best_nb_model_perf = best_nb_model.model_performance(test)

h2o.save_grid("./nb_grid", nb_grid.grid_id)

# Explicitly print out the  the model's AUC on test data
print('AUC of Top-performer on Test data: ', best_nb_model_perf.auc())
    """
}

//================================================================================
// Module test
//================================================================================

workflow test {

    input_data_ch = Channel.of([params.train_frame, params.test_frame])

    H2O_GRID_NAIVE_BAYES(input_data_ch)

}
