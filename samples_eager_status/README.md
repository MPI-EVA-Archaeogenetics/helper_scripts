# samples_eager_status

This is a script for checking for a list of samples if the latest autorun_eager run has completed (e.g. if you want to check whether your samples 
on the latest seqeuncing run has been sucesfully processed)


You need one input text file with the list of Pandora IDs for the samples you want to check (e.g. DRH001), one ID per line. An example 
of the input sample list file:

```
DRH001
DRH002
DRH003
```

lets say you call this text file ``` my_samples.txt ```

Then run the script like below:
```
samples_eager_status.sh -i my_samples.txt
```
the script will output anothr text filed called ``` my_samples.txt_samples_eager_status.txt ``` with a second column next to the 
original ID column saying ``` Pipeline-completed-successfully- ``` if the processing for that sample has completed succesfully. If there is nothing 
written it means that the pipeline it's still running or hasn't started yet (or the sample ID doesn't exist). If you expect the processing to be 
finished (e.g. all the samples from the same run finished already a while before), it culd also mean the pipeline failed for other reasons and I 
suggest to check then the sample/s individually.

ouput example:

```
DRH001	Pipeline-completed-successfully-
DRH002	Pipeline-completed-successfully-
DRH003	Pipeline-completed-successfully-
DRH004	Pipeline-completed-successfully-
LNC001	
LNC001	
LNC001	
LNC001
	
````
