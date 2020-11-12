# Nextflow wrapper for `FIXME` process.

## Pre-requisites

- Nextflow
- Docker 

**NOTE** If you plan to setup a basic server, then you can refer [minimal-nextflow-setup](https://github.com/nextflow-hub/minimal-nextflow-setup)

## Usage

```
nextflow run https://github.com/nextflow-hub/FIXME
```

## Options


- `filePattern`

By default, the process assumes the files to follow the `*_{R1,R2}.fastq.gz` pattern, which could be customized using this option

```
nextflow run https://github.com/nextflow-hub/FIXME --filePattern './*_{1,2}.fastq.gz'
```

- `resultsDir`

By default, it stores the result files locally inside the `results` directory.

```
nextflow run https://github.com/nextflow-hub/FIXME --resultsDir /path/to/custom/resultsDir
```

- `saveMode`

By default, the pipeline publishes the results in the `resultsDir` by copying the relevant output.

You can update this behavior by simply specifying the alternative such as `move` or `link` etc. 

```
nextflow run https://github.com/nextflow-hub/FIXME --saveMode move
```

For more information please refer [Nextflow documentation](https://www.nextflow.io/docs/latest/process.html#publishdir)

## Customizing the script

The sole purpose of process wrappers in `nextflow-hub` is to keep the code small, clean and hackable with some basic knowledge of `nextflow` scripting.

If you have specific requirements, you are encouraged to fork/clone and update your version to accomodate your needs. 


## Contribution

Contribution, in all forms, is most welcome!
