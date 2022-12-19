### Description  
This code is convert the EEG file from .EEG (Nihon Kohden) format to .edf format in Matlab.  



### Usage  
Conversion can be done in two ways: command line or GUI.  

Command line  
```bash
EEG_to_edf('/***/EEG_data/', '/***/edf_data/')  
```
All the .EEG files in the _EEG_data_ folder will be convert to .edf files and save in _edf_data_ folder.  

GUI  
1. Run the _EEG_to_edf.m_ file, the first window will pop up, please select the .EEG file folder.  
2. The second window will pop up automatically, please select the folder to save the .edf file.  
3. Convert will be performed one by one.  



### Resources  
There are fifteen files in total.  
_EEG_to_edf.m_: main function to convert the format.  
_gui.m_: GUI function.  

_blockEdfWrite.m, blockEdfLoad.m_  
Using for write and read the .edf file, can be find in:  
https://www.mathworks.com/matlabcentral/fileexchange/46339-blockedfwrite  
https://www.mathworks.com/matlabcentral/fileexchange/42784-blockedfload  

_bst_bsxfun.m, bst_fileparts.m, bst_fullfile.m, db_template.m, file_exist.m,  
n_channel_nk.m, in_fopen_nk.m, in_fread_nk.m, in_fread.m, str_date.m, str_split.m_  
Using for read the .EEG fils, can be find in:  
https://www.mathworks.com/matlabcentral/fileexchange/64589-brainstorm



Xuyang ZHAO  
Dec 19, 2022  
