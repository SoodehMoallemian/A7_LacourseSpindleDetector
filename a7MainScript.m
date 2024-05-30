% a7SpindleDetection package
%
% The a7SpindleDetection.m function is the algorithm that detects spindles 
% from one single EEG channel at a time.
% The a7MainScript.m helper function is provided to load example data and
% generate the output files.  If you already have data loaded into matlab,
% then skip sections that loads the data (sections 1.1, 1.2, 1.3) and go
% directly to section 2.1 to run the a7SpindleDetection.m function.
%
% Prior to running the  a7MainScript.m script, make sure you have modified
% the parameters in the initA7_DEF.m file to match your configuration.
%
%  
% INPUT data :
%     This script loads:
%       - An input EEG vector raw data sample-by-sample (numeric, microVolts)
%       - An input sleep stages (categorical, same length as EEG vector)
%       - An artifact vector    (binary, same length as EEG vector)
%                       (0=No artifact / 1=artifact)
% OUTPUT data :
%      This script saves features and detected spindles as .mat files:
%       - A7 options and definitions
%       - detectionVector (binary, by-sample; where 1=spindle, by-sample)
%       - detectionInfo matrix (by-sample), this matrix includes the 4 parameters used to detect spindles: 
%         1 : PSDSigmaLog (sigma power log10 transformed)
%         2 : relSigPow (z-score of relative sigma power from 30 sec clean around the PSA window)
%         3 : sigmaCov (z-score of the covariance of sigma from 30 sec clean closed to the PSA window)
%         4 : sigmaCorr (correlation of sigma)
%         5 : artifact vector (same as input)
%         6 : slow ratio information vector (log10 slowRatio values, context classifier output)
%       - EventDetection.txt : This files lists all spindle detections, one per row.
%         1 : Spindle start (sample)
%         2 : Spindle end (sample)
%         3 : Duration (sample)
%         4 : Spectral Context (0="OUT" of context / 1="IN" context)
%         5 : Sleep stage (from the input)
%
%  Requirements : 
%       - initA7_DEF.m
%       - a7SpindleDetection.m
%       - cell2tab.m
%       - lib directory with a7 functions
% 
%  Authors : Karine Lacourse
%            Jacques Delfrate
%  Date    : 2018-02-13
% 
%  RELEASE : v1.1 with MATLAB 9.1.0.441655 (R2016b)
%            Note that this code may not run on previous versions of MATLAB.  
%            For example, it does not work with R2012a due to changes to 'omitnan' flags for math functions (ie sum).

%-------------------------------------------------------------------------
% 
% REMARKS :
%     Free use and modification of this code is permitted, provided that
%     any modifications are also freely distributed.
%
%     When using this code or modifications of this code, please cite:
%       Lacourse, K., Delfrate, J., Beaudry, J., Peppard, P. & Warby, S. C. 
%       A sleep spindle detection algorithm that emulates human expert spindle scoring. 
%       J. Neurosci. Methods (2018). doi:10.1016/j.jneumeth.2018.08.014
%
%
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Modified by Soodeh Moallemian. PhD. Brain Health Alliance, CMBN, Ritgers University
% NOTE: the modifications are done based on the DREEM3 data.
% s.moallemian@rutgers.edu
% Date: 2024-05-29
%-------------------------------------------------------------------------

%% a7 inits
% A7 features and path init
initA7_DEF;

% A7 thresholds
    % Sigma based thresholds
    DEF_a7.absSigPow_Th = 1.25; % absSigPow threshold (sigma power log10 transformed)
    DEF_a7.relSigPow_Th = 1.6;  % relSigPow (z-score of relative sigma power from a clean 30 sec around the current window)
    % Correlation and covariance thresholds
    DEF_a7.sigCov_Th    = 1.3;  % sigmaCov (z-score of the covariance of sigma from a clean 30 sec around the current window)
    DEF_a7.sigCorr_Th   = 0.69; % sigmaCorr (correlation of sigma signal)
    
% Spindle definition
    DEF_a7.minDurSpindleSec = 0.3; % minimum duration of spindle in sec
    DEF_a7.maxDurSpindleSec = 2.5; % maximum duration of spindle in sec

% Context Classifier definition (Slow ratio)   
    % Slow ratio filter
    DEF_a7.lowFreqLow   = 0.5; % frequency band of delta + theta
    DEF_a7.lowFreqHigh  = 8.0;   % frequency band of delta + theta
    DEF_a7.highFreqLow  = 16.0;  % frequency band of beta
    DEF_a7.highFreqHigh = 30.0;  % frequency band of beta.
    % Detection In Context 
    DEF_a7.slowRat_Th   = 0.9; % slow ratio threshold for the spindle spectral context
    
% Sigma filter definition
    DEF_a7.sigmaFreqLow  = 11.0;   % sigma frequency band low
    DEF_a7.sigmaFreqHigh = 16.0;   % sigma frequency band high
    DEF_a7.fOrder        = 20.0;   % filter order for the sigma band
    
% Baseline filter definition for relative sigma power
    DEF_a7.totalFreqLow     = 4.5; % frequency band of the broad band
    DEF_a7.totalFreqHigh    = 30.0;  % frequency band of the broad band
    
% Sliding windows definition
    % Detection and PSA window
    DEF_a7.winLengthSec     = 0.3;  % window length in sec
    DEF_a7.WinStepSec       = 0.1;  % window step in sec
    DEF_a7.ZeroPadSec       = 2;    % zero padding length in sec
    DEF_a7.bslLengthSec     = 30;   % baseline length to compute the z-score of rSigPow and sigmaCov
    
% Parameter settings
    % Setting used in a7subAbsPowValues.m
    DEF_a7.eventNameAbsPowValue       = 'a7AbsPowValue'; % event name for warnings
    % Settings used in a7subRelSigPow.m
    DEF_a7.eventNameRelSigPow         = 'a7RelSigPow';  % event name for warnings
    DEF_a7.lowPerctRelSigPow          = 10;             % low percentile to compute the STD and median of both thresholds
    DEF_a7.highPerctRelSigPow         = 90;             % high percentile to compute the STD and median of both thresholds
    % 1 = On / 0 = Off
    DEF_a7.useLimPercRelSigPow        = 1;              % Consider only the baseline included in the percentile selected
    DEF_a7.useMedianPSAWindRelSigPow  = 0;              % To use the median instead of the mean to compute the threshold. 
    % Settings used in a7subSigmaCov.m
    DEF_a7.eventNameSigmaCov          = 'a7SigmaCov';   % event name for warnings
    DEF_a7.lowPerctSigmaCov           = 10;             % low percentile to compute the STD and median of both thresholds
    DEF_a7.highPerctSigmaCov          = 90;             % high percentile to compute the STD and median of both thresholds
    DEF_a7.filterOrderSigmaCov        = 20;             % Define the filter order
    % 1 = On / 0 = Off
    DEF_a7.useLimPercSigmaCov         = 1;              % Consider only the baseline included in the percentile selected
    DEF_a7.removeDeltaFromRawSigmaCov = 0;              % To filter out the delta signal from the raw signal to compute the covariance
    DEF_a7.useMedianWindSigmaCov      = 0;              % On: Use the median to the bsl normlization, Off: Use the mean value
    DEF_a7.useLog10ValNoNegSigmaCov   = 1;              % On: Use log10 distribution (It is more similar to normal distribution)
    % Settings used in a7subSigmaCorr.m 
    % 1 = On / 0 = Off
    DEF_a7.removeDeltaFromRawSigCorr  = 0;              % To filter out the delta signal from the raw signal to compute the correlation

    % Settings used in a7subTurnOffDetSlowRatio.m
    DEF_a7.eventNameSlowRatio         = 'a7SlowRatio';  % event name for warnings
    % 1 = On / 0 = Off 
    DEF_a7.useMedianWindSlowRatio     = 0;              % On: Use the median to the bsl normlization, Off: Use the mean value
    DEF_a7.useLog10ValNoNegSlowRatio  = 1;              % On: Use log10 distribution (It is more similar to normal distribution)
    
%% Other inits description 
    % output date
    DEF_a7.date = datestr(now,'yyyy-mm-dd_HH:MM:SS');
    % add libraries to path
    addpath(genpath('./lib'));
    
%% Script
fprintf('Data is loading...\n');

%--------------------------------------------------------------------------
% Section 1.1 Load a EEG signal to run the detector
%--------------------------------------------------------------------------
% Load the eeg timeseries c3 filtered 0-30 Hz 
    EEG = pop_loadset(fullfile(DEF_a7.inputPath, DEF_a7.EEGvector));
    eeg_C3A2 = EEG.data; % by-sample
    % eeg_C3A2 = eeg_C3A2.dataVector;
    
%--------------------------------------------------------------------------
% Section 1.2 Load the sleep staging
%--------------------------------------------------------------------------
    sleepStageVect = load(fullfile(sub_fold,DEF_a7.sleepStaging)); % by-sample
    sleepStageVect = sleepStageVect.N2N3_stages_afterfft_snipped;
    
%--------------------------------------------------------------------------
% Section 1.3 Load the artifact vector
%-------------------------------------------------------------------------- 
    % NREM 2 artifact free recording has been selected as the example data
    % (0 : No artifact / 1: artifact)
    
    DEF_a7.artifactVector = false(1, length(EEG.data));
    artifactVect = DEF_a7.artifactVector; % by-sample
    % artifactVect = artifactVect.artifactVect;

%--------------------------------------------------------------------------
% Section 2.1 Detect spindles in the signal
%--------------------------------------------------------------------------
    % make sure all input vectors are the same size
    %loop over the 5 electrodes for DREEM3
    % the electrode names
    electrode_names = {'F7-O1', 'F8-O2', 'F8-F7', 'F8-O1', 'F7-O2'};
    time = datestr(now,'yyyy-mm-dd_HH-MM-SS');
    for elect_i =1: 5
        elect_TimeSeries= double(eeg_C3A2(elect_i,:));
        elect_name = char(electrode_names(elect_i));
        if isequal(length(artifactVect),length(eeg_C3A2),length(sleepStageVect))
            [detVect, detInfoTS, NREMClass, outputFile] = ...
                a7SpindleDetection(elect_TimeSeries, sleepStageVect, ...
                artifactVect, DEF_a7);
        else
            % error, check input vector
            error('input vectors should be same size, check input vectors');
        end
        save_a7out(DEF_a7, detInfoTS,detVect, NREMClass,outputFile,time,elect_name)
    end

%--------------------------------------------------------------------------
% remove path from Matlab        
%--------------------------------------------------------------------------
    rmpath(genpath('./lib'));


    
