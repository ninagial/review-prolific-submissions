#' Find Participants That Skipped a Section
#'
#' @param  prolific_col     character    there should be a column in your survey data that corresponds to the participants Prolific ID, provide the colname here
#' @param  section_colnames character    for instance a result of grep(val=T, ...) to select colnames of your data
#' @return environment
skipped_section <- function(data, section_colnames){
	out = new.env()
	with(out, {
		d <- data[, section_colnames]
		excl_logical <- apply(d, 1, function(x) all(is.na(x)))
		excl <- which(excl_logical)
		})
	out
}

retrieve_prolific_id <- function(skipObj, prolific_export=NULL, skip=2){
	out <- prolific_export$participant_id[skipObj$excl-skip]
	out
}

