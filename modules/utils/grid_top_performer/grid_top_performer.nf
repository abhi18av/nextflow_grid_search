nextflow.enable.dsl = 2


process UTILS_GRID_TOP_PERFORMER {
    container "quay.io/abhi18av/nextflow_grid_search"
    memory '4 GB'
    cpus 4


    input:
    tuple path(grid_id_file), path(grid_folder)

    output:
    path("Grid_*")

    script:
    """
#!/usr/bin/env python3
import h2o

h2o.init()

# Save the model grid ID
with open("${grid_id_file}", "r") as grid_id_txt: 
    grid_id= grid_id_txt.read() 

grid = h2o.load_grid("${grid_folder}/" + grid_id)
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

    input_ch = Channel.of(["$baseDir/test_data/nb_grid_id.txt",
                           "$baseDir/test_data/nb_grid"])

    UTILS_GRID_TOP_PERFORMER(input_ch)

}
