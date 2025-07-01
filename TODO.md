## Synopsis

This is a fork of the original bnmf-clustering repository that re-factors pre-2025 code in a way that workflow management provided by targets is used. 

## How to run from cmd?
`R --vanilla -e "library('targets'); tar_make()"` in the directory containing `_targets.R`

## Issues 
Below, we list issues encountered when running the code:

* when connection timeout is encountered when communicating with external server for either LD pruningor proxy search, the code crashes ungracefully and there is no way to start from a checkpoint. Partially this has been resolved by using `targets` but checkpoints are at rule level, so e.g. when proxy search timeout occurs at chr 11, we need to start from scratch, instead of from chr 10
* when proxy search cannot find any good candidates, it returns `NULL` and this is not handled properly in the downstream code resulting in an uncaught error
* reading p-values is sensitive to encoding (engineerin notation?) as it sometimes reads p-vals as character instead as of numeric

## Suggestions

* migrate from GWAS data being read from xls to csv for portability (or add csv handling as alternative)
* parallelize some tasks, like proxy search. Preferably using `futureverse` for portability and flexibility as well as for it handles random seeds properly in hps environments
* consider exporting partial results and pausing execution so that parts of the pipeline can be run externally when working on secure environments with limited networking

## TODOs

* provide proper versioning, presumably using `renv`. Currently `pacman` + `targets` options but no proper versioning and no full reproducibility is guaranteed
* add some basic type checking and validators for inputs
* add try-catch blocks to handle errors
* check whether all parameters were pulled out to config.yml 
