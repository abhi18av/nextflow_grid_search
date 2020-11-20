nextflow.enable.dsl = 2

NFOLDS = 10

params.H2O_GRID_NAIVE_BAYES_MODELS = [
        nfolds: NFOLDS
]
include { H2O_GRID_NAIVE_BAYES_MODELS } from "../../modules/h2o/grid_naive_bayes_models/grid_naive_bayes_models.nf" addParams(params.H2O_GRID_NAIVE_BAYES_MODELS)



params.H2O_GRID_GENERALIZED_LINEAR_MODELS = [
        nfolds: NFOLDS
]
include { H2O_GRID_GENERALIZED_LINEAR_MODELS } from "../../modules/h2o/grid_generalized_linear_models/grid_generalized_linear_models.nf" addParams(params.H2O_GRID_GENERALIZED_LINEAR_MODELS)


include { UTILS_GRID_TOP_PERFORMER } from "../../modules/utils/grid_top_performer/grid_top_performer.nf"


//================================================================================
// Workflow test
//================================================================================

workflow test {


    input_data_ch = Channel.of([params.train_frame, params.test_frame])


    UTILS_GRID_TOP_PERFORMER(
//            H2O_GRID_NAIVE_BAYES_MODELS(input_data_ch),
            H2O_GRID_GENERALIZED_LINEAR_MODELS(input_data_ch),
    )

}
