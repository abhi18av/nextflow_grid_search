nextflow.enable.dsl = 2

// Model parameters
params.nfolds = 5
params.independent_variable = 'response'


// Naive-Bayes hyper-parameters
params.model_seed = 1234
params.laplace = [0, 1, 2]
params.min_sdev = [0.3, 0.6, 0.9]
params.min_prob = [0.3, 0.6, 0.9]
params.eps_prob = [0.3, 0.6, 0.9]
params.eps_sdev = [0.3, 0.6, 0.9]
params.compute_metrics = ['True', 'False']

// Grid search criteria
params.strategy = 'RandomDiscrete'
params.max_models = 10
params.max_runtime_secs = 600
params.stopping_metric = 'AUC'
params.stopping_tolerance = 0.00001
params.stopping_rounds = 5
params.grid_seed = 1234

// Grid parallel training, number of models to be trained in parallel
params.parallelism = 1


process H2O_GRID_NAIVE_BAYES_MODELS {
    container "quay.io/abhi18av/nextflow_grid_search"
    memory '16 GB'
    cpus 8

    input:
    tuple val(train_frame), val(test_frame)

    output:
    tuple path('nb_grid_id.txt'), path('nb_grid')

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
y = "${params.independent_variable}"
x.remove(y)

# For binary classification, response should be a factor
train[y] = train[y].asfactor()
test[y] = test[y].asfactor()

# Number of CV folds (to generate level-one data for stacking)
nfolds = ${params.nfolds}


search_criteria = {
'strategy' : "${params.strategy}",
'stopping_metric' : "${params.stopping_metric}",
'max_models' : ${params.max_models},
'max_runtime_secs' : ${params.max_runtime_secs},
'stopping_metric' : "${params.stopping_metric}",
'stopping_tolerance' : ${params.stopping_tolerance},
'stopping_rounds' : ${params.stopping_rounds},
'seed' : ${params.grid_seed},
}


nb_hyperparams = {
'laplace': ${params.laplace},
'min_sdev': ${params.min_sdev},
'min_prob': ${params.min_prob},
'eps_prob': ${params.eps_prob},
'eps_sdev': ${params.eps_sdev},
'compute_metrics': ${params.compute_metrics}
}

# Build and train the model:
nb_base_model = H2ONaiveBayesEstimator(
                                        nfolds=nfolds,
                                        seed=${params.model_seed})


nb_grid = H2OGridSearch(model=nb_base_model,
                        hyper_params=nb_hyperparams,
                        parallelism= ${params.parallelism})


nb_grid.train(x=x, 
             y=y,
             training_frame=train,
             validation_frame=test)

sorted_nb_grid = nb_grid.get_grid(sort_by='auc', decreasing=True)

best_nb_model = sorted_nb_grid[0]

print(sorted_nb_grid)

# Now let's evaluate the model performance on a test set
# so we get an honest estimate of top model performance
best_nb_model_perf = best_nb_model.model_performance(test)

# Explicitly print out the  the model's AUC on test data
print('AUC of Top-performer on Test data: ', best_nb_model_perf.auc())

# Save the model grid
h2o.save_grid("./nb_grid", nb_grid.grid_id)

# Save the model grid ID
with open("nb_grid_id.txt", "w") as grid_id_file: 
    grid_id_file.write(nb_grid.grid_id) 

    """
}

//================================================================================
// Module test
//================================================================================

workflow test {

    input_data_ch = Channel.of([params.train_frame, params.test_frame])

    H2O_GRID_NAIVE_BAYES_MODELS(input_data_ch)

}
