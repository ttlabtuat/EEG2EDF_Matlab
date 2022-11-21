function varargout = blockEdfWrite(varargin)
% blockEdfLoad Load EDF with memory block reads.
% Function inputs an EDF file text string and returns the header,
% header and each of the signals.
%
% Our EDF tools can be found at:
%
%                  http://sleep.partners.org/edf/
%
% The loader is designed to load the EDF file described in: 
% 
%    Bob Kemp, Alpo V�rri, Agostinho C. Rosa, Kim D. Nielsen and John Gade 
%    "A simple format for exchange of digitized polygraphic recordings" 
%    Electroencephalography and Clinical Neurophysiology, 82 (1992): 
%    391-393.
%
% An online description of the EDF format can be found at:
% http://www.edfplus.info/
%
% Requirements:    Self contained, no external references 
% MATLAB Version:  Requires R14 or newer, Tested with MATLAB 7.14.0.739
%
% Input (VARARGIN):
%           edfFN : File text string 
%    signalLabels : Cell array of signal labels to return (optional)
%
% Function Prototypes:
%    status = blockEdfWrite(edfFN, header)
%    status = blockEdfWrite(edfFN, header, signalHeader)
%    status = blockEdfWrite(edfFN, header,  signalHeader, signalCell)
%
% Output (VARARGOUT):
%          header : A structure containing variables for each header entry
%    signalHeader : A structured array containing signal information, 
%                   for each structure present in the data
%      signalCell : A cell array that contains the data for each signal
%
% Output Structures:
%    header:
%       edf_ver
%       patient_id
%       local_rec_id
%       recording_startdate
%       recording_starttime
%       num_header_bytes
%       reserve_1
%       num_data_records
%       data_record_duration
%       num_signals
%    signalHeader (structured array with entry for each signal):
%       signal_labels
%       tranducer_type
%       physical_dimension
%       physical_min
%       physical_max
%       digital_min
%       digital_max
%       prefiltering
%       samples_in_record
%       reserve_2
%
% Examples:
%
%  Write EDF header information
%
%    edfFn3 = 'file.edf';
%    status = blockEdfWrite(edfFn3, header);
%
%
%  Load Signals
%
%    edfFn3 = 'file.edf';
%    [header signalHeader signalCell] = blockEdfLoad(edfFn3);
%
%    edfFn3 = 'file.edf';
%    signalLabels = {'Pleth', 'EKG-R-EKG-L', 'Abdominal Resp'}; 
%    [header signalHeader signalCell] = blockEdfLoad(edfFn3, signalLabels);
%
%    epochs = [1 2];  % Load first through second epoch
%    signalLabels = {'Pleth', 'Abdominal Resp', 'EKG-R-EKG-L'}; 
%    [header signalHeader signalCell] = ...
%         blockEdfLoad(edfFn3, signalLabels, epochs);
%
%
% Version: 0.1.07
%
% ---------------------------------------------
% Dennis A. Dean, II, Ph.D
%
% Program for Sleep and Cardiovascular Medicine
% Brigam and Women's Hospital
% Harvard Medical School
% 221 Longwood Ave
% Boston, MA  02149
%
% File created: October 23, 2012
% Last updated: November 21, 2013 
%    
% Copyright � [2012] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
% WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
% AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
% PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
% BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
% INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
% FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
% AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
% RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
%

%------------------------------------------------------------ Process input

% Defaults for optional parameters            
headerStruct = [];         % Header Structure
signalHeaderStruct = [];   % Labels of signals to return
signalCell = {};           % Signal cell
epochs = [];               % Start and end epoch to return
status = 0;                % Write status

% Initialize return counts
statusHeader = 0;
statusSignalHeader = 0;
statusSignalCell = 0;

% Process input 
if nargin == 2
   edfFN = varargin{1};
   headerStruct = varargin{2};   
elseif nargin == 3 
   edfFN = varargin{1};
   headerStruct = varargin{2};  
   signalHeaderStruct = varargin{3};
elseif nargin == 4 
   edfFN = varargin{1};
   headerStruct = varargin{2};  
   signalHeaderStruct = varargin{3};
   signalCell = varargin{4};
else
    % Echo supported function prototypes to console
    fprintf('[header, signalHeader] = blockEdfWrite(edfFN, headerStruct)\n');
    fprintf('[header, signalHeader] = blockEdfWrite(edfFN, headerStruct, signalHeaderStruct)\n');
    % Call MATLAB error function
    error('Function prototype not valid');
end

%-------------------------------------------------------------- Input check
% Check that first argument is a string
if   ~ischar(edfFN)
    msg = ('First argument is not a string.');
    error(msg);
end
% Check that first argument is a string
if  ~isstruct(headerStruct)
    msg = ('Second argument is not a header structure.');
    error(msg);
end
% Check that first argument is a string
if  and(nargin ==3, ~isstruct(signalHeaderStruct))
    msg = ('Specify epochs = [Start_Epoch End_Epoch.');
    error(msg);
end
% Check if header, signal header and signal sizes are consistent
if nargin > 3
    ndr = headerStruct.num_data_records;
    drd = headerStruct.data_record_duration;
    for s = 1:headerStruct.num_signals;
        dl = length(signalCell{s})/signalHeaderStruct(s).samples_in_record;
        if ndr*drd ~= dl
            msg = sprintf('Data size and headers are not consistent: %s (%.0f)\n',...
                signalHeaderStruct(s).signal_labels,s);
            error(msg);
        end
    end
end
%----------------------------------------------------- Process Header Block
% Create array/cells to create struct with loop
headerVariables = {...
    'edf_ver';             'patient_id';          'local_rec_id'; ...
    'recording_startdate'; 'recording_starttime'; 'num_header_bytes'; ...
    'reserve_1';           'num_data_records';    'data_record_duration';...
    'num_signals'};
headerVariableTypeCheck = ...
    {@isstr;      @isstr;       @isstr;...
     @isstr;      @isstr;       @isnumeric;...
     @isstr;      @isnumeric;   @isnumeric;...
     @isnumeric; ...
     };
headerVariablesConvertF = ... 
     {@(x)x;      @(x)x;        @(x)x;...
      @(x)x;      @(x)x;        @num2str;...
      @(x)x;      @num2str;     @num2str;...
      @num2str};
headerVariableSize = [ 8; 80; 80; 8; 8; 8; 44; 8; 8; 4];
headerVarLoc = vertcat([0],cumsum(headerVariableSize));
headerSize = sum(headerVariableSize);

% Process Header Information

% Create Header Structure
header = blanks(256);
for h = 1:length(headerVariables)
    % Get header variable 
    typeCheckF = headerVariableTypeCheck{h};
    value = getfield(headerStruct, headerVariables{h});
    
    if typeCheckF(value) == 1
        % Process header field
        conF = headerVariablesConvertF{h};
        value = conF(value);
        endLoc = min(headerVarLoc(h+1),headerVarLoc(h)+length(value));
        header(headerVarLoc(h)+1:endLoc) = ...
            value(1:min(length(value),headerVariableSize(h)));
        
        % Check header lengths
        if length(value) > headerVariableSize(h)
            % String was clipped
            errMsg = ...
            sprintf('Header structure variable (%s) was truncated',...
                headerVariables{h});
            err(errMsg);
        end
    else
        % Write error message
        errMsg = ...
            sprintf('Header structure variable (%s) is not appropriately typed',...
            headerVariables{h});
        err(errMsg);
    end
end

%------------------------------------------------------------- Write Header
% Open file for writing
% Load edf header to memory
[fid, msg] = fopen(edfFN, 'r+');

% Proceed if file is valid
if fid <0
    % Open for writing
    [fid, msg] = fopen(edfFN, 'w+');
    
    if fid < 0 
        msg = sprintf('Could not open or create file: %s',edfFN);
    	% file id is not valid
        error(msg);    
    end
end

% Process machine format
% [filename, permission, machineformat, encoding] = fopen(fid);

% Write header
try 
    % Check if only header is being changed
    edfSigHeaderSignals = [];
    if nargin == 2
        % Load original header
        edfHeaderSize = 256;
        [A count] = fread(fid, edfHeaderSize, 'int8');
        
        % Load signal header
        edfSignalHeaderSize = headerStruct.num_header_bytes-edfHeaderSize;
        edfSigHeaderBlock = fread(fid, edfSignalHeaderSize, 'int8');
        
        % Load signal information
        edfSignalsBlock = fread(fid, 'int16');
        
        % Move file pointer to begining of file;
        frewind(fid);
    end
    
    % Write header information in one call
    count = fwrite(fid, int8(header));
    statusHeader = count;
    
    % Check if original file must be rewritten 
    if nargin == 2
%         % Try moving to EOF, status = 0 is a successful change
%         status = fseek(fid, 0, 'eof');
        
        % Load original header
        status = fwrite(fid, int8(edfSigHeaderBlock), 'int8');
        status = fwrite(fid, int16(edfSignalsBlock), 'int16');
    end    
    
    
catch exception
    msg = 'File write error. Check available HD space / if file is open.';
    error(msg);
end

% End Header Write Section

%------------------------------------------------------ Write Signal Header
if nargin >= 3
    %------------------------------------------ Process Signal Header Block
    % Create arrau/cells to create struct with loop
    signalHeaderVar = {...
        'signal_labels'; 'tranducer_type'; 'physical_dimension'; ...
        'physical_min'; 'physical_max'; 'digital_min'; ...
        'digital_max'; 'prefiltering'; 'samples_in_record'; ...
        'reserve_2' };
    signalVariableTypeCheck = ...
        {@isstr;      @isstr;      @isstr;...
         @isnumeric;  @isnumeric;  @isnumeric;...
         @isnumeric;  @isstr;      @isnumeric;...
         @isstr; ...
        };
    signalHeaderVariablesConvertF = ... 
        {@(x)x;       @(x)x;       @(x)x;...
         @num2str;    @num2str;    @num2str;...
         @num2str;    @(x)x;       @num2str;...
         @(x)x};
    num_signal_header_vars = length(signalHeaderVar);
    num_signals = headerStruct.num_signals;
    signalHeaderVarSize = [16; 80; 8; 8; 8; 8; 8; 80; 8; 32];
    signalBlockSize = sum(signalHeaderVarSize);
    signalHeaderBlockSize = signalBlockSize*num_signals;
    signalHeaderVarLoc = vertcat([0],cumsum(signalHeaderVarSize)*num_signals);
    signalHeaderRecordSize = sum(signalHeaderVarSize);

    % Create Signal Header Struct
    signalHeader = struct(...
        'signal_labels', {},'tranducer_type', {},'physical_dimension', {}, ...
        'physical_min', {},'physical_max', {},'digital_min', {},...
        'digital_max', {},'prefiltering', {},'samples_in_record', {},...
        'reserve_2', {});
    
    % Allocate signal header block
    signalHeader = blanks(signalHeaderBlockSize);
    
    % Get each signal header varaible
    for s = 1:num_signals
        for v = 1:num_signal_header_vars
            % Get signalHeader variable
            typeCheckF = signalVariableTypeCheck{v};
            value = getfield(signalHeaderStruct(s), signalHeaderVar{v});
            
            % Check variable type
            if typeCheckF(value) == 1
                % Add signal header information to memory block
                
                % Process header field
                conF = signalHeaderVariablesConvertF{v};
                value = conF(value);
                startLoc = signalHeaderVarLoc(v)+1+signalHeaderVarSize(v)*(s-1);
                endLoc = min(startLoc+signalHeaderVarSize(v),...
                    startLoc+length(value)-1);
                signalHeader(startLoc:endLoc) = ...
                    value(1:min(length(value),signalHeaderVarSize(v)));
                
                % Check header lengths
                if length(value) > signalHeaderVarSize(v)
                    % String was clipped
                    errMsg = ...
                        sprintf('Signal (%s) header structure variable (%s) was truncated',...
                        signalHeaderStruct(s).signal_labels, ...
                        signalHeaderVar{v});
                    err(errMsg);
                end 
            else
                % Write error message
                signalHeaderStruct(s).physical_min,
                errMsg = ...
                    sprintf('Signal (%s) header structure variable (%s) is not appropriately typed',...
                    signalHeaderStruct(s).signal_labels, signalHeaderVar{v});
                error(errMsg);
            end
        end
    end
    %-------------------------------------------------- Write Signal Header
    try 
        % Load signal header into memory in one load
        count = fwrite(fid, int8(signalHeader));
        statusSignalHeader = count;
    catch exception
        msg = 'File load error. Check available memory.';
        error(msg);
    end
end % End Signal header write section

%------------------------------------------------------- Write Signal Block
if nargin >= 4
    % Read digital values to the end of the file
    %try
        % Set default error mesage
        %errMsg = 'File write error. Check disk space.';
        
    	%-------------------------------------------- Process Signal Block
        % Get values to reshape block
        num_data_records = headerStruct.num_data_records;
        num_data_records = floor(num_data_records);
        getSignalSamplesF = @(x)signalHeaderStruct(x).samples_in_record;
        signalSamplesPerRecord = arrayfun(getSignalSamplesF,[1:num_signals]);
        recordWidth = sum(signalSamplesPerRecord);
        numRecords = num_data_records;

        % Create matrix to hold raw results
        A = zeros(recordWidth, num_data_records);
        
        % Create raw signal cell array
        signalLocPerRow = horzcat([0],cumsum(signalSamplesPerRecord));
        for s = 1:num_signals
            % Get signal location
            signalRowWidth = signalSamplesPerRecord(s);
            signalRowStart = signalLocPerRow(s)+1;
            signaRowEnd = signalLocPerRow(s+1);
            
            % Get signal
            signal = signalCell{s};
            signal = signal(1 : num_data_records*signalRowWidth);
            % Get scaling factors
            dig_min = double(signalHeaderStruct(s).digital_min);
            dig_max = double(signalHeaderStruct(s).digital_max);
            phy_min = double(signalHeaderStruct(s).physical_min);
            phy_max = double(signalHeaderStruct(s).physical_max);
            
            % Get signal factor  
            signal = (signal-phy_min)/(phy_max-phy_min);
            signal = signal.*double(dig_max-dig_min)+dig_min; 

            value = (signal-dig_min)/(dig_max-dig_min);
            value = value.*double(phy_max-phy_min)+phy_min; 
            
            % Convert physical signal to digital signal
            signal = reshape(signal, signalSamplesPerRecord(s), ...
                num_data_records ...
                );
              
            % Generate signal matrix and put in place
            A(signalLocPerRow(s)+1:signalLocPerRow(s+1), 1:end) = ...
                signal;
        end
        
        
        % --------------------------------------------------- Write Signals
        % Restructure Matrix
        A = reshape(A, num_data_records*recordWidth, 1);
        statusSignalCell = fwrite(fid, A, 'int16');

        
        %num_data_records
    %catch exception
    %    error(errMsg);
    %end
end % End Signal Load Section

%---------------------------------------------------- Create return value
if nargout < 2
   varargout{1} = statusHeader + statusSignalHeader + statusSignalCell;
elseif nargout == 2
   varargout{1} = statusHeader;
   varargout{2} = signalSignalHeader;
elseif nargout == 3
   varargout{1} = statusHeader;
   varargout{2} = signalSignalHeader;
   varargout{3} = statusSignalCell;
end % End Return Value Function

% Close file explicitly
%if fid > 0 
%    fclose(fid);
%end

st = fclose(fid);
while st == -1
   st = fclose(fid);
end


end % End of blockEdfLoad function
