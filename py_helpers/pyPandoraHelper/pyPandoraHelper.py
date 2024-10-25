import sys

def get_site_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Site_ID.
  '''
  ## Check provided 
  result=id.strip().split('.')[0][0:-3]
  return(result)

def get_ind_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Individual_ID.
  '''
  result=id.strip().split('.')[0]
  return(result)

def get_sample_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Sample_ID.
  '''
  x=id.strip().split('.')
  if len(x) < 2:
    raise ValueError('The provided Pandora_ID does not contain the Sample_ID.')
  result=x[0]+'.'+x[1][0]
  return(result)

def get_extract_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Extract_ID.
  '''
  x=id.strip().split('.')
  if len(x) < 2:
    raise ValueError('The provided Pandora_ID does not contain the Extract_ID.')
  result=x[0]+'.'+x[1][0:3]
  return(result)

def get_library_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Library_ID.
  '''
  x=id.strip().split('.')
  if len(x) < 2:
    raise ValueError('The provided Pandora_ID does not contain the Library_ID.')
  result=x[0]+'.'+x[1]
  return(result)

def get_capture_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Capture_ID.
  '''
  x=id.strip().split('.')
  if len(x) < 3:
    raise ValueError('The provided Pandora_ID does not contain the Capture_ID.')
  result=x[0]+'.'+x[1]+'.'+x[2]
  return(result)

def get_sequencing_id(id: str) -> str:
  '''
  This function takes any Pandora_ID and returns the part of it that corresponds to the Sequencing_ID.
  '''
  x=id.strip().split('.')
  if len(x) < 3:
    raise ValueError('The provided Pandora_ID does not contain the Sequencing_ID.')
  result=x[0]+'.'+x[1]+'.'+x[2]+'.'+x[3]
  return(result)

def main():
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
  
  for id in ["ABC001", "ABC001.A0101", "ABC001.A0101.SG1.1", "ABCDE001.A0101.SG1.1"]:
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

if __name__ == '__main__':
  main()