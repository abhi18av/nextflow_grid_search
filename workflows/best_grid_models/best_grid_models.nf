nextflow.enable.dsl = 2


params.H2O_GRID_NAIVE_BAYES = [
nfolds: 10
]
include { H2O_GRID_NAIVE_BAYES } from "../../modules/h2o/grid_naive_bayes/grid_naive_bayes.nf" addParams (params.H2O_GRID_NAIVE_BAYES)

include { UTILS_GRID_TOP_PERFORMER } from "../../modules/utils/grid_top_performer/grid_top_performer.nf"


//================================================================================
// Workflow test
//================================================================================

workflow test {


    input_data_ch = Channel.of([params.train_frame, params.test_frame])


    UTILS_GRID_TOP_PERFORMER(
            H2O_GRID_NAIVE_BAYES(input_data_ch),
    )

}
