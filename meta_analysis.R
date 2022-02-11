#!/usr/bin/env Rscript

# This script performs meta-analysis using metagen (in R) for at least one test in at least two studies
# Usage: ./meta.R infile number_of_tests outfile
# infile needs to contain columns Study, B1, SE1, B2, SE2, BN, SEN... etc. (beta coefficients and standard errors from at least two studies). Col names don't matter but the order does
# outfile is optional (will default to results.txt)

args = commandArgs(trailingOnly=TRUE) 

# test if there is at least one argument: if not, return an error
if (length(args)<2) {
  stop("At least two arguments must be supplied (input file and number of tests).n", call.=FALSE)
} else if (length(args)==2) {
  # default output file
  args[3] = "results.txt"
}

require(meta)

dfIn = read.table(args[1], header=TRUE)

meta_func <- function(test) {
	  res <- metagen(dfIn[,test*2], dfIn[,(test*2)+1], studlab = dfIn[,1])
	  res_list <- list(test = test, pval_q = res$pval.Q, or_fixed = exp(res$TE.fixed), lower_fixed = exp(res$lower.fixed), upper_fixed = exp(res$upper.fixed), p_fixed = res$pval.fixed, or_random = exp(res$TE.random), lower_random = exp(res$lower.random), upper_random = exp(res$upper.random), p_random = res$pval.random)
	  return(res_list)
	  }

dfOut <- data.frame(test=character(), pval_q=character(), beta_fixed=character(), lower_fixed=character(), upper_fixed=character(), p_fixed=character(), beta_random=character(), lower_random=character(), upper_random=character(), p_random=character())

tests = args[2]

for (test in 1:tests) {
    dfOut <- rbind(dfOut, as.data.frame(meta_func(test)))
    }

write.csv(dfOut, args[3], row.names=FALSE, quote=FALSE)