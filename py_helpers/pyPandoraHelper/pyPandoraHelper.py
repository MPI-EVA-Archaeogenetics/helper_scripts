VERSION = '0.1.0' 

def _remove_suffix(ind_id: str) -> str:
  '''
  This function takes an Individual_ID and removes the '_ss' suffix if present.
  This suffix is added by Autorun_eager to denote single stranded libraries, and does not appear anywhere in Pandora.
  '''
  if ind_id.strip()[-3:] == '_ss':
    result=ind_id.strip()[0:-3]
  else:
    result=ind_id.strip()
  return(result)

def get_site_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Site_ID.
  '''
  ## Check provided for '_ss' suffix, and remove it if present
  result=_remove_suffix(id.strip().split('.')[0])[0:-3]
  return(result)

def get_ind_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Individual_ID.
  '''
  result=_remove_suffix(id.strip().split('.')[0])
  return(result)

def get_sample_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Sample_ID.
  '''
  x=id.strip().split('.')
  if len(x) < 2:
    raise ValueError('The provided Pandora_ID does not contain the Sample_ID.')
  result=_remove_suffix(x[0])+'.'+x[1][0]
  return(result)

def get_extract_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Extract_ID.
  '''
  x=id.strip().split('.')
  if len(x) < 2:
    raise ValueError('The provided Pandora_ID does not contain the Extract_ID.')
  result=_remove_suffix(x[0])+'.'+x[1][0:3]
  return(result)

def get_library_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Library_ID.
  '''
  x=id.strip().split('.')
  if len(x) < 2:
    raise ValueError('The provided Pandora_ID does not contain the Library_ID.')
  result=_remove_suffix(x[0])+'.'+x[1]
  return(result)

def get_capture_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Capture_ID.
  '''
  x=id.strip().split('.')
  if len(x) < 3:
    raise ValueError('The provided Pandora_ID does not contain the Capture_ID.')
  result=_remove_suffix(x[0])+'.'+x[1]+'.'+x[2]
  return(result)

def get_sequencing_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Sequencing_ID.
  '''
  x=id.strip().split('.')
  if len(x) < 3:
    raise ValueError('The provided Pandora_ID does not contain the Sequencing_ID.')
  result=_remove_suffix(x[0])+'.'+x[1]+'.'+x[2]+'.'+x[3]
  return(result)

def test():
  '''
  This function runs test cases for the functions in this module.
  '''
  print('This is a helper module for the pyPandora package.')
  print('It contains functions that help parse Pandora_IDs.')
  print('The functions are:')
  print('get_site_id(id) -> str')
  print('get_ind_id(id) -> str')
  print('get_sample_id(id) -> str')
  print('get_extract_id(id) -> str')
  print('get_library_id(id) -> str')
  print('get_capture_id(id) -> str')
  print('get_sequencing_id(id) -> str')
  print('Running test cases...')
  print('')
  
  for id in ["ABC001", "ABC001.A0101", "ABC001_ss.A0101.SG1.1", "ABCDE001.A0101.SG1.1"]:
    try:
      print('Pandora_ID:',id)
      print('Site_ID:',get_site_id(id))
      print('Individual_ID:',get_ind_id(id))
      print('Sample_ID:',get_sample_id(id))
      print('Extract_ID:',get_extract_id(id))
      print('Library_ID:',get_library_id(id))
      print('Capture_ID:',get_capture_id(id))
      print('Sequencing_ID:',get_sequencing_id(id))
      print('')
    except ValueError as e:
      print(e)
      print('')
      pass

def main():
  import argparse
  parser = argparse.ArgumentParser(description='This is a helper module for the pyPandora package. It contains functions that help parse Pandora_IDs.')
  parser.add_argument('-t','--test', action='store_true', help='Run test cases for the functions in this module. Ignored all other arguments.')
  parser.add_argument('-v', '--version', action='version', version='%(prog)s '+VERSION)
  parser.add_argument('-g','--get', type=str, help='The function to run. Options: site_id, ind_id, sample_id, extract_id, library_id, capture_id, sequencing_id')
  parser.add_argument('pandora_id', type=str, help='The Pandora_ID to infer from')
  args = parser.parse_args()
  
  allowed_get_values = ["site_id", "ind_id", "individual_id", "sample_id", "extract_id", "library_id", "capture_id", "sequencing_id" ]
  if args.test:
    test()
  elif args.get not in allowed_get_values:
    print('The provided value for the -g/--get argument is not allowed.')
    print('The allowed values are:',allowed_get_values)
  else:
    if args.get == "site_id":
      print(get_site_id(args.pandora_id))
    elif args.get in ["ind_id", "individual_id"]:
      print(get_ind_id(args.pandora_id))
    elif args.get == "sample_id":
      print(get_sample_id(args.pandora_id))
    elif args.get == "extract_id":
      print(get_extract_id(args.pandora_id))
    elif args.get == "library_id":
      print(get_library_id(args.pandora_id))
    elif args.get == "capture_id":
      print(get_capture_id(args.pandora_id))
    elif args.get == "sequencing_id":
      print(get_sequencing_id(args.pandora_id))
  
if __name__ == '__main__':
  main()
