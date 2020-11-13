nextflow.enable.dsl = 2


process UTILS_GRID_TOP_PERFORMER {
    container "quay.io/abhi18av/nextflow_grid_search"
    memory '4 GB'
    cpus 4


    input:
    path(grid_folder)
    val(grid_name)

    output:
    path("Grid_*")

    script:
    """
#!/usr/bin/env python3
import h2o

h2o.init()

grid = h2o.load_grid("${grid_folder}/${grid_name}")
print(grid)


# If nfolds is used then the accuracy on CV datasets is used.
# For more info, http://docs.h2o.ai/h2o/latest-stable/h2o-py/docs/modeling.html?highlight=get_grid#h2o.grid.H2OGridSearch.get_grid
top_grid_performer = grid.get_grid(sort_by='auc', decreasing=True)[0]

h2o.save_model(top_grid_performer, "./", force=True)

# Explicitly print out the  the model's AUC on test data
print('AUC of Top-performer on Test data: ', top_grid_performer.auc())

    """
}

//================================================================================
// Module test
//================================================================================

workflow test {

    grid_folder_location = "${baseDir}/${params.grid_folder}"

    UTILS_GRID_TOP_PERFORMER(grid_folder_location,
                             params.grid_name)

}
