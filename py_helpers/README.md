# py_helpers

This directory stores various helper packages to assist in accessing and working with departmental resources.

The following packages are currently available:

## pyPandoraHelper

This is a python package allowing easy conversion of Pandora_IDs to any ID of higher hierarchical level.
No queries to Pandora take place, only simple text manipulation, and hence this package cannot tell you if the ID exists.

### Installation

The package can be installed with `pip`:

```bash
pip install /mnt/archgen/tools/helper_scripts/py_helpers/
```

### Usage

#### Within Python

Once installed, you can use the package functions as such:
```python
import pyPandoraHelper as pH

pH.get_ind_id("ABC001_ss.A0101.SG1.2")
# 'ABC001'
```

```
## the "->" notation tells you what type of object the function returns.
get_site_id(id      , False) -> str
get_ind_id(id       , False) -> str
get_sample_id(id    , False) -> str
get_extract_id(id   , False) -> str
get_library_id(id   , False) -> str
get_capture_id(id   , False) -> str
get_sequencing_id(id, False) -> str
```
The first argument given to these functions is the ID you wish to infer from.
The second argument is a boolean, denoting if the `_ss` suffix added in Autorun_eager should be kept in the inferred ID.
If the requested ID level cannot be inferred from the provided ID, then a `ValueError` is raised.

Below are some examples of Autorun_eager-style Pandora_IDs, and the output of the different functions with and without suffix retention.

```
$ pyPandoraHelper.py -t
Running test cases...
               	suffix=False             	suffix=True              
Pandora_ID:    	ABC001                   	ABC001                   
Site_ID:       	ABC                      	ABC                      
Individual_ID: 	ABC001                   	ABC001                   
The provided Pandora_ID does not contain the Sample_ID.

               	suffix=False             	suffix=True              
Pandora_ID:    	ABC001.A0101             	ABC001.A0101             
Site_ID:       	ABC                      	ABC                      
Individual_ID: 	ABC001                   	ABC001                   
Sample_ID:     	ABC001.A                 	ABC001.A                 
Extract_ID:    	ABC001.A01               	ABC001.A01               
Library_ID:    	ABC001.A0101             	ABC001.A0101             
The provided Pandora_ID does not contain the Capture_ID.

               	suffix=False             	suffix=True              
Pandora_ID:    	ABC001.A0101.SG1.1       	ABC001.A0101.SG1.1       
Site_ID:       	ABC                      	ABC                      
Individual_ID: 	ABC001                   	ABC001                   
Sample_ID:     	ABC001.A                 	ABC001.A                 
Extract_ID:    	ABC001.A01               	ABC001.A01               
Library_ID:    	ABC001.A0101             	ABC001.A0101             
Capture_ID:    	ABC001.A0101.SG1         	ABC001.A0101.SG1         
Sequencing_ID: 	ABC001.A0101.SG1.1       	ABC001.A0101.SG1.1       

               	suffix=False             	suffix=True              
Pandora_ID:    	ABCDE001_ss.A0101.SG1.1  	ABCDE001_ss.A0101.SG1.1  
Site_ID:       	ABCDE                    	ABCDE                    
Individual_ID: 	ABCDE001                 	ABCDE001_ss              
Sample_ID:     	ABCDE001.A               	ABCDE001_ss.A            
Extract_ID:    	ABCDE001.A01             	ABCDE001_ss.A01          
Library_ID:    	ABCDE001.A0101           	ABCDE001_ss.A0101        
Capture_ID:    	ABCDE001.A0101.SG1       	ABCDE001_ss.A0101.SG1    
Sequencing_ID: 	ABCDE001.A0101.SG1.1     	ABCDE001_ss.A0101.SG1.1  
```

#### CLI

The functionality of `pyPandoraHelper.py` is also available through the CLI, by running the script directly.

```
$ pyPandoraHelper.py -h
usage: pyPandoraHelper.py [-h] [-t] [-k] [-v] [-g GET] pandora_id

This is a helper module for the pyPandora package. It contains functions that help parse Pandora_IDs.

positional arguments:
  pandora_id            The Pandora_ID to infer from

options:
  -h, --help            show this help message and exit
  -t, --test            Run test cases for the functions in this module. Ignored all other arguments.
  -k, --keep_ss_suffix  Keep the ss suffix in the Individual ID (if applicable).
  -v, --version         show program's version number and exit
  -g GET, --get GET     The function to run. Options: site_id, ind_id, sample_id, extract_id, library_id, capture_id, sequencing_id
```

Example usage:
```bash
pyPandoraHelper.py -g extract_id ABC001_ss.A0102.SG1.2
# ABC001.A01
pyPandoraHelper.py --keep_ss_suffix -g extract_id ABC001_ss.A0102.SG1.2
# ABC001_ss.A01
```
