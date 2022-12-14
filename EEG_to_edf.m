% 
% This code is used for convert .EEG file to .edf file.
%
% Xuyang ZHAO
% Dec 19, 2022
%

function varargout = EEG_to_edf(in_pathname, out_pathname)

if nargin == 2
    pathname_in = in_pathname;
    pathname_out = out_pathname;

    % Creat temp floder in path.
    mkdir('./data_temp');
    mkdir('./out_temp');
    
    pathname_1 = which('EEG_to_edf.m');
    pathname_1 = pathname_1(1 : (end-12)); 
    pathname_1 = [pathname_1, 'data_temp/'];
    
    pathname_in = cellstr(pathname_in);

    
    % Display the name list of .EEG files.* (in Disk)
    dirs_tmp = dir([char(pathname_in), '/*.EEG']);
    dircell_tmp = struct2cell(dirs_tmp)';
    filenames_tmp = dircell_tmp(:,1);
    
    
    % Display .EEG file storage path and file list.
    f = figure('name', 'Found the following .EEG data.', 'Position', [100,100,600,550]);
    t1 = uitable('Parent', f, 'Position', [50,420,500,100], 'ColumnWidth', {450 50});
    t2 = uitable('Parent', f, 'Position', [50,50,500,330], 'ColumnWidth', {150 50});
    set(t1,'Data', pathname_in);
    set(t2,'Data', filenames_tmp);
    
    pause(2)
    
    status = copyfile(char(pathname_in), char(pathname_1));
    if status == 0
        status = copyfile(char(pathname_in), char(pathname_1));
        if status == 0
            disp('Error in copy data from MiniMac to iMacPro')
        end
    end
    
    % Get input path.
    pathname_in = cellstr(pathname_in);
    pathname_1 = cellstr(pathname_1);

    % Get the name list of .EEG files.*
    dirs = dir([char(pathname_1), '/*.EEG']);
    dircell = struct2cell(dirs)';
    filenames = dircell(:,1);
    
    
    
    
    % Get output path.
    pathname_2 = which('EEG_to_edf.m');
    pathname_2 = pathname_2(1 : (end-12)); 
    pathname_2 = [pathname_2, 'out_temp/'];
    pathname_2 = cellstr(pathname_2);

elseif nargin == 0
    [pathname_in, filenames] = gui();

    % Creat temp floder in path.
    mkdir('./data_temp');
    mkdir('./out_temp');

    pathname_1 = which('EEG_to_edf.m');
    pathname_1 = pathname_1(1 : (end-12)); 
    pathname_1 = [pathname_1, 'data_temp/'];
    
    % Display the name list of .EEG files.* (in Disk)
    dirs_tmp = dir([char(pathname_in), '/*.EEG']);
    dircell_tmp = struct2cell(dirs_tmp)';
    filenames_tmp = dircell_tmp(:,1);
    
    % Display .EEG file storage path and file list.
    f = figure('name', 'Found the following .EEG data.', 'Position', [100,100,600,550]);
    t1 = uitable('Parent', f, 'Position', [50,420,500,100], 'ColumnWidth', {450 50});
    t2 = uitable('Parent', f, 'Position', [50,50,500,330], 'ColumnWidth', {150 50});
    set(t1,'Data', pathname_in);
    set(t2,'Data', filenames_tmp);

    pause(2)

    [pathname_out, filenames_2] = gui();
    
    pathname_2 = which('EEG_to_edf.m');
    pathname_2 = pathname_2(1 : (end-12)); 
    pathname_2 = [pathname_2, 'out_temp/'];
    pathname_2 = cellstr(pathname_2);

    
    status = copyfile(char(pathname_in), char(pathname_1));
    if status == 0
        status = copyfile(char(pathname_in), char(pathname_1));
        if status == 0
            disp('Error in copy data from MiniMac to iMacPro')
        end
    end 
    
    
    % Get input path.
    pathname_in = cellstr(pathname_in);
    pathname_1 = cellstr(pathname_1);
    
    % Get the name list of .EEG files.*
    dirs = dir([char(pathname_1), '/*.EEG']);
    dircell = struct2cell(dirs)';
    filenames = dircell(:,1);
    
end


%% Convert all .EEG files to .edf files.
for n = 1 : length(filenames)

    loadpath = [char(pathname_1), char(filenames(n))]; % Read .EEG file path.
    
    fprintf('%d  ', n);
    fprintf('Processing:  ');
    disp(loadpath);

    [EEG_hdr, EEG_dat] = in_fopen_nk(loadpath); % Use in_fopen_nk to open .EEG file.
    filename = EEG_hdr.filename; % Prepare the name for generate .edf file.
    filename(end-2 : end) = 'edf';
    length(filenames{n});
    filename = filename(end-(length(filenames{n})-1) : end);
    
    for iEpoch = 1:size(EEG_hdr.epochs,2)
        % Read data from .EEG file.
        if iEpoch == 1
            EEG_dat_tmp = in_fread(EEG_hdr, EEG_dat, iEpoch, EEG_hdr.epochs(iEpoch).samples);
        else
            EEG_dat_tmp = [ EEG_dat_tmp, in_fread(EEG_hdr, EEG_dat, iEpoch, EEG_hdr.epochs(iEpoch).samples) ];
        end    
        % Read data length.
        if iEpoch ==1
            edf_hdr.num_data_records = (EEG_hdr.epochs(iEpoch).samples(2)+1)/EEG_hdr.prop.sfreq;
        else
            edf_hdr.num_data_records = edf_hdr.num_data_records + (EEG_hdr.epochs(iEpoch).samples(2)+1)/EEG_hdr.prop.sfreq;
        end
    end

    edf_hdr.num_data_records = floor(edf_hdr.num_data_records);
    EEG_dat_tmp = EEG_dat_tmp(: , 1 : edf_hdr.num_data_records*EEG_hdr.prop.sfreq);
    
    
%% Get .edf header info fromn .EEG file.
    edf_hdr.edf_ver = '0';
    edf_hdr.patient_id = EEG_hdr.header.patient.Id; % ID of patient.
    edf_hdr.local_rec_id = EEG_hdr.header.device; % Device model.
    edf_hdr.recording_startdate = [EEG_hdr.header.startdate(1:2), '.', EEG_hdr.header.startdate(4:5), '.', EEG_hdr.header.startdate(9:10)]; % Date of EEG signal collection.
    edf_hdr.recording_starttime = [EEG_hdr.header.starttime(1:2), '.', EEG_hdr.header.starttime(4:5), '.', EEG_hdr.header.starttime(7:8)]; % Time of EEG signal collection.    
    edf_hdr.num_signals = EEG_hdr.header.num_channels; % Number of channel.
    edf_hdr.num_header_bytes = (edf_hdr.num_signals+1)*256; % Header size of .edf file.
    %edf_hdr.reserve_1 = EEG_hdr.events(1);
    edf_hdr.reserve_1 = ' ';
    %edf_hdr.num_data_records = round(edf_hdr.num_data_records);
    edf_hdr.data_record_duration = 1;

%% Get data header info fromn .EEG file.
    % Every channel has a header.
    for i = 1:edf_hdr.num_signals
        edf_dat_hdr(i).signal_labels = EEG_dat.Channel(i).Name; % Channel name.
        edf_dat_hdr(i).tranducer_type = EEG_dat.Channel(i).Type; % Channel type.
        edf_dat_hdr(i).physical_dimension = 'uV';   
        
        edf_dat_hdr(i).physical_min = -32768;
        edf_dat_hdr(i).physical_max = 32767;
        edf_dat_hdr(i).digital_min = -32768;
        edf_dat_hdr(i).digital_max = 32767;
        
        edf_dat_hdr(i).prefiltering = ' ';
        edf_dat_hdr(i).samples_in_record = EEG_hdr.prop.sfreq; % Channel frequence.
        edf_dat_hdr(i).reserve_2 = ' ';
    end
    
%% Get data info fromn .EEG file.
    % Prepare data format.
    EEG_dat_tmp = EEG_dat_tmp*1000000.0;
    edf_dat = mat2cell(EEG_dat_tmp', (EEG_hdr.prop.sfreq*edf_hdr.num_data_records)*ones(1,1),...
        ones(1,edf_hdr.num_signals));

%% Generate .edf file
    %blockEdfWrite(['./edf/', filename], edf_hdr, edf_dat_hdr, edf_dat);
    blockEdfWrite([char(pathname_2), filename], edf_hdr, edf_dat_hdr, edf_dat);

end

status = copyfile(char(pathname_2), char(pathname_out));
if status == 0
    status = copyfile(char(pathname_2), char(pathname_out));
    if status == 0
        disp('Error in copy data from MiniMac to iMacPro')
    end
end

%% Display GUI of .edf file storage path and file list.
ff = figure('name', 'Following .edf data were generated.', 'Position', [100,100,600,550]);

t11 = uitable('Parent', ff, 'Position', [50,420,500,100], 'ColumnWidth', {450 50});
t22 = uitable('Parent', ff, 'Position', [50,50,500,330], 'ColumnWidth', {150 50});
set(t11,'Data', {[char(pathname_out), '/']});

dirs = dir( [char(pathname_out), '/*.edf'] );
dircell = struct2cell(dirs)';
filename_edf = dircell(:,1);

set(t22,'Data', filename_edf);

%% If you want to check the generated .edf files, you can use this function to read .edf file.
% [edf_hdr_check, edf_dat_hdr_check, edf_dat_check] = blockEdfLoad('./edf/DJ999013.edf');

rmdir data_temp s
rmdir out_temp s

disp(' ')
disp('****************')
disp('Finished')
disp('****************')
