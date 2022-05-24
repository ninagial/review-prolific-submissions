#' Identify time Outliers, Given Cutoff Point
#
time_outliers <- function(data, cutoff=2.0){
	out = new.env()
	with(out, {
	d <- transform(data, time_z = scale(time_taken))
	excl <- which(abs(d$time_z) > cutoff)
	prolific_ids <- d[excl, 'participant_id']
	filtered <- d[-excl,]
	quas=quantile(d$time_taken, seq(1,100)/100)
})
	out
}


time_quantiles <- function(data, cutoff=85){
	out = new.env()
	with(out, {
		     quas <- quantile(data$time_taken, seq(1,100)/100)
		     excl_logical <- data$time_taken >= quas[cutoff]
		     excl <- which(excl_logical)
		     prolific_ids <- data[excl, 'participant_id']
})
	out
}
