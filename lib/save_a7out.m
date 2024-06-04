function save_a7out(DEF_a7, detInfoTS, detVect, NREMClass, outputFile, nowdate, electrode_index)

DEF_a7.date = nowdate;
%--------------------------------------------------------------------------
% Section 3.1 Save output 
%--------------------------------------------------------------------------
    % Contain detection information in time series
    save(fullfile(DEF_a7.inputPath,'Spindles', [DEF_a7.sub_id,'_electrode_', electrode_index, '_', ...
        DEF_a7.outputTS]), 'detInfoTS');
    % Contain the detection in sample
    save(fullfile(DEF_a7.inputPath,'Spindles', [DEF_a7.sub_id,'_electrode_', electrode_index, '_', ...
        DEF_a7.outputDetectInfo]), 'detVect');
    % Contain detection in events 
    % 0/1: Not/Is in spectral context
    save(fullfile(DEF_a7.inputPath,'Spindles', [DEF_a7.sub_id,'_electrode_', electrode_index, '_', ...
        DEF_a7.outputNREMClass]), 'NREMClass');
    % save DEF_a7 structure to keep track of settings
    save(fullfile(DEF_a7.inputPath,'Spindles', [DEF_a7.sub_id,'_electrode_', electrode_index, '_', ...
        DEF_a7.detectorDef]), 'DEF_a7');
    % save event file
    cell2tab(fullfile(DEF_a7.inputPath,'Spindles', [DEF_a7.sub_id,'_electrode_', electrode_index, '_', ...
        DEF_a7.outputTxtFile]), outputFile, 'w');
end