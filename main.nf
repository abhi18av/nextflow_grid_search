#!/usr/bin/env nextflow

/*
#==============================================
code documentation
#==============================================
*/


/*
#==============================================
PARAMS
#==============================================
*/


/*
#----------------------------------------------
flags
#----------------------------------------------
*/

params.FLAG = false

/*
#----------------------------------------------
directories
#----------------------------------------------
*/

params.resultsDir = 'results/FIXME'


/*
#----------------------------------------------
file patterns
#----------------------------------------------
*/

params.refFasta = "NC000962_3.fasta"
params.readsFilePattern = "./*_{R1,R2}.fastq.gz"

/*
#----------------------------------------------
misc
#----------------------------------------------
*/

params.saveMode = 'copy'

/*
#----------------------------------------------
channels
#----------------------------------------------
*/

Channel.value("$workflow.launchDir/$params.refFasta")
        .set { ch_refFasta }

Channel.fromFilePairs(params.readsFilePattern)
        .set { ch_in_PROCESS }

/*
#==============================================
PROCESS
#==============================================
*/

process PROCESS {
    publishDir params.resultsDir, mode: params.saveMode
    container 'FIXME'


    input:
    set genomeFileName, file(genomeReads) from ch_in_PROCESS

    output:
    path FIXME into ch_out_PROCESS


    script:
    genomeName = genomeFileName.toString().split("\\_")[0]

    """
    CLI PROCESS
    """
}


/*
#==============================================
# extra
#==============================================
*/
