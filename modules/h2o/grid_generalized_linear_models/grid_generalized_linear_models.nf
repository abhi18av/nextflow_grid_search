nextflow.enable.dsl = 2

params.nfolds = 5
params.seed = 1234
params.independent_variable = 'response'


// hyper-parameters
params.alpha =
params.lambda =
params.missing_values_handling =
params.seed = 1234
params.standardize =
params.theta =
params.tweedie_link_power =
params.tweedie_variance_power =

process H2O_GRID_GENERALIZED_LINEAR_MODELS {
    container "quay.io/abhi18av/nextflow_grid_search"
    memory '16 GB'
    cpus 8

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

glm_hyperparams = {
'laplace': ${params.laplace},
'min_sdev': ${params.min_sdev},
'min_prob': ${params.min_prob} 
}

# Build and train the model:
glm_base_model = H2OGeneralizedLinearEstimator(
                                        nfolds=nfolds,
                                        seed=${params.seed})


glm_grid = H2OGridSearch(model=glm_base_model,
                        hyper_params=glm_hyperparams)


glm_grid.train(x=x, 
             y=y,
             training_frame=train,
             validation_frame=test)


sorted_glm_grid = glm_grid.get_grid(sort_by='auc', decreasing=True)

best_glm_model = sorted_glm_grid[0]

print(sorted_glm_grid)


# Now let's evaluate the model performance on a test set
# so we get an honest estimate of top model performance
best_glm_model_perf = best_glm_model.model_performance(test)

# Explicitly print out the  the model's AUC on test data
print('AUC of Top-performer on Test data: ', best_glm_model_perf.auc())

# Save the model grid
h2o.save_grid("./glm_grid", glm_grid.grid_id)

# Save the model grid ID
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
