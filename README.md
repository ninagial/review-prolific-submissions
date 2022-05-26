
# Process your Prolific Export

Howdy, I wrote this app for processing Prolific outputs.

Prolific Academic is a participant recruitment service for human subjects research, for instance psychology and behavioral economics experiments, marketing research, or any other type of research microjob.
It is a high quality service, and pushes towards good remuneration for participants.

When you complete a study in Prolific, you can obtain the (anonymized) participants' demographics in a CSV file.
After running a couple of studies on Prolific, I found myself playing around the R command line to figure out which participants lingered unacceptably, did not provide a confirmation code for study completion, or otherwise exhibited sub-par collaboration.

But fooling around in the command line in a non-reproducible manner is not my style.
So I went about it with writing this app.

# Your Survey Data File

Your survey data file is obtained outside Prolific.
For instance I use Qualtrics.

Now, if you use Qualtrics you might know that it exports the data in its own style. 
I have built the parsing of the Qualtrics CSV export in the app, because I use it, but the app is agnostic to the survey data file. 
As long as it is CSV, you should be good to go. Please report any issues to the Issue Tracker.

The function of the survey data here is to cross-validate that the participant completed important sections, or did not provide a prolific ID.

# The Output

The app outputs a table with three computed logicals (A true/false value):

- No Code: The participant provided no completion code
- Too Slow: The pariticpant exceeded the 90th quantile of all completion times for this survey
- Skipped Sections: The participant skipped important sections of the surveys

The app's interface allows you to change the 90th quantile to something else (eg the 50th quantile is the median), as well as use a regular expression to set the "important sections" of the survey.

If you use Qualtrics a handy Codebook can be found in the rightmost tab in the app.
This should help with defining the regular expression for the important sections criterion.

Finally, a list of approvable Prolific IDs is printed in the second tab ("To Bulk Approve").
You can copy and paste these ID's "as is" to the "Bulk approve" menu dialog in Prolific.

# Disclaimer

This is a hobby project and I provide **no guarantee** you will not mess up your research using this app.
It remains your job to crossvalidate these submissions.

I hope you find this app a helpful companion to running studies in Prolific.

Best of luck!
Over and out! 




