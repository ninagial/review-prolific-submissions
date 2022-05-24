read_qualtrics_file <- function(fname){ 
	d <- read.csv(fname, skip=2)
	metad <- read.csv(fname, nrows=2)
	colnames(d) <- colnames(metad)
	codes=structure(list(item=colnames(d),statement=gsub("[^-]*- ","",metad[1,])),class='data.frame', row.names=colnames(d))

	list(data=d, codebook=codes)
}

