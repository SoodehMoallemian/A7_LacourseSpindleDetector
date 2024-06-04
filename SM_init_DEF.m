function SM_init_DEF(sub_id,source_path)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function initiates a structure called DEF_a7 that later must be
% used in main_a7.m function.
% 
% initA7_DEF initiates all basic parameters required to run a7 detectors
%  Purpose :
%       paths, input and output definition
%       Turn On/Off context classifier
%       Select appropriate sampling rate
%       Select sleep staging baseline 
%       (can be one, several or no sleep stages)
%  Input :
%   sub_id = 'COV209';
%   source_path = fullfile('D:\Studies\01_DREEM3\02_RawData');
%  
%  Output :
%       DEF_a7: structure with all the parameters set as defined below
%
%
% Author: Jacques Delfrate
% Date : 2018-02-13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by: Soodeh Moallemian, PhD.
% Brain Health and Allience, CMBN, Rutgers University
% s.moallemian@rutgers.edu
% Date : 2024-06-03
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear variables;
clc;


sub_fold = fullfile(source_path,sub_id);
cd(sub_fold)

if ~exist(fullfile(sub_fold,'Spindles')) %#ok<EXIST> 
    mkdir(sub_fold, 'Spindles'); 
end

SpindleFolder = fullfile(sub_fold,'Spindles');
 % Path
    % Define inputs directory
    DEF_a7.inputPath            = sub_fold;                % input path directory
    % Define inputs files in the input directory
    DEF_a7.EEGvector            = strcat(sub_id, '_SnippedSleep_filtered_bandpass_n2n3_noarousals_fftstep_artifcorr_final.set');           % input eeg vector name
    DEF_a7.sleepStaging         = strcat(sub_id, '_N2N3_stagenames_afterfft_snipped.mat');        % input sleep stages vector name
    DEF_a7.artifactVector       = 'artifactVect';      % input artifact vector name
    % Define outputs
    DEF_a7.outputGrandParentDir = DEF_a7.inputPath;               % output path
    DEF_a7.outputTxtFile        = 'EventDetection.txt';      % Summury of detection
    DEF_a7.outputTS             = 'detectionInfo.mat';       % detection info output file name
    DEF_a7.outputDetectInfo     = 'detectionVector.mat';     % TS output file name
    DEF_a7.outputNREMClass      = 'nremClassifier.mat';      % context classifier info output file name
    DEF_a7.detectorDef          = 'DEF_a7.mat';              % detector info output file name
    
 % A7 default parameters
    % Sampling rate of the eeg vector.
    DEF_a7.standard_sampleRate = 250;
    
    % Sleep stage considered in the baseline.  
    % Set to {'N2', 'N3'} to consider stage N2 and N3  as baseline, 
    % '2' for just stage 2 etc.
    % Note that the stage units must match what is found in the
    % sleepStaging input file (sleepStaging.mat) 
    % (ie use '2', or 'N2' if 2 or N2 is used in the input sleep staging etc.)
    DEF_a7.bslSleepStaging = {'N2','N3'}; % or {'N2'}
    
    % DEF_a7.inContOn=0 (off): the context classifier is by passed 
    % DEF_a7.inContOn=1 (on): the context classifier is run and all the
    %   spindles detected are kept (IN and OUT context).  
    %   The expected spectral context (NREM class) for each spindle 
    %   is written in the nremClassifier.mat
    DEF_a7.inContOn     = 1;  % context classifier On/Off - 1/0
    
    
    % To filter out spindles occuring during an artifact
    %   DEF_a7.spindleNoArt=0 (off) : all the spindles detected are kept (with or without artifact).
    %       All the spindles will be reported in the EventDetection.txt, where
    %       artifact column=0 spindles free of artifact, 
    %       artifact column=1 spindles co-occurring with artifact.
    %   DEF_a7.spindleNoArt=1 (on) : remove spindles coincident with artifact
    %       Spindles co-occurring with artifact wont be reported in the EventDetection.txt
    DEF_a7.spindleNoArt = 0; % Turn off spindle event during an artifact    
    
    % Print in the command window the option definition 
    DEF_a7

    cd(SpindleFolder)
    save('DEF_a7.mat','DEF_a7')
 end

