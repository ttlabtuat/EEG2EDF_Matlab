### Description  
This code is convert the EEG file from .EEG (Nihon Kohden) format to .edf format in Matlab.  



### Usage  
Conversion can be done in two ways: command line or GUI.  

Command line  
```bash
EEG_to_edf('/***/EEG_data/', '/***/edf_data/')  
```
All the .EEG files in the 'EEG_data' folder will be convert to .edf files and save in 'edf_data' folder.  

GUI  
Run the EEG_to_edf.m file.  
The first window will pop up, please select the .EEG file folder.  
Then the second window will pop up, please select the folder to save the .edf file.  
Last, convert will be performed one by one.  



### Resources  
There are fifteen files in total.  
EEG_to_edf.m: main function to convert the format.  
gui.m: GUI function.  

blockEdfWrite.m, blockEdfLoad.m  
Using for write and read the .edf file, can be find in:  
https://www.mathworks.com/matlabcentral/fileexchange/46339-blockedfwrite  
https://www.mathworks.com/matlabcentral/fileexchange/42784-blockedfload  

bst_bsxfun.m, bst_fileparts.m, bst_fullfile.m, db_template.m,  
file_exist.m, n_channel_nk.m, in_fopen_nk.m, in_fread_nk.m,  
in_fread.m, str_date.m, str_split.m  
Using for read the .EEG fils, can be find in: 
https://www.mathworks.com/matlabcentral/fileexchange/64589-brainstorm



Xuyang ZHAO  
Dec 19, 2022  