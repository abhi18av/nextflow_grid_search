nextflow.enable.dsl = 2
//FIXME This entire file needs to be changed


// Model parameters
params.nfolds = 5
params.independent_variable = 'response'
params.family = 'binomial'

// Generalized Linear Model hyper-parameters
params.model_seed = 1234
params.alpha = 0.5
//params.lambda =
params.missing_values_handling = " 'mean_imputation', 'skip' "
params.standardize = 'False'
params.theta = [0, 0.3, 0.6, 0.9, 1]
params.tweedie_link_power = [0, 0.3, 0.6, 0.9, 1, 3, 6, 9]
params.tweedie_variance_power = [0, 0.3, 0.6, 0.9, 1, 3, 6, 9]


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

process H2O_GRID_GENERALIZED_LINEAR_MODELS {
    container "quay.io/abhi18av/nextflow_grid_search"
    memory '8 GB'
    cpus 4

    input:
    tuple val(train_frame), val(test_frame)

    output:
    tuple path('glm_grid_id.txt'), path('glm_grid')

    script:
    """
#!/usr/bin/env python3

import h2o
from h2o.estimators.glm import H2OGeneralizedLinearEstimator
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

glm_hyperparams = {
'alpha' : ${params.alpha},
# lambda' : {params.lambda},
'missing_values_handling' : [${params.missing_values_handling}],
'theta' : ${params.theta},
'tweedie_link_power' : ${params.tweedie_link_power},
'tweedie_variance_power' : ${params.tweedie_variance_power}
}

# Build and train the model:
glm_base_model = H2OGeneralizedLinearEstimator(
                                        family= "${params.family}",
                                        nfolds=nfolds,
                                        seed=${params.model_seed},
                                        standardize= ${params.standardize}
)


glm_grid = H2OGridSearch(model=glm_base_model,
                        hyper_params=glm_hyperparams,
                        parallelism= ${params.parallelism})


glm_grid.train(x=x, 
             y=y,
             training_frame=train,
             validation_frame=test)

print("Saving the grid")
h2o.save_grid("./glm_grid", glm_grid.grid_id)

print("Saving the grid ID")
with open("glm_grid_id.txt", "w") as grid_id_file: 
    grid_id_file.write(glm_grid.grid_id) 


    """
}

//================================================================================
// Module test
//================================================================================

workflow test {

    input_data_ch = Channel.of([params.train_frame, params.test_frame])

    H2O_GRID_GENERALIZED_LINEAR_MODELS(input_data_ch)

}
