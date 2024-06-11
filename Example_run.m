clc
clear all
sub_id = 'COV053'; 
source_path = fullfile('D:\Studies\01_DREEM3\02_RawData'); 
dep_path = fullfile('D:\Git\A7_LacourseSpindleDetector\lib');
cd 'D:\Git\A7_LacourseSpindleDetector'
SM_detectSpindles(sub_id, source_path,dep_path)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you have multiple sessions for a subject, use the one below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear all
sub_id = 'COV053'; 
prompt = input('what is the session number?','s');
session_num = strcat('ses0',prompt);
source_path = fullfile('D:\Studies\01_DREEM3\02_RawData', sub_id, session_num); 
dep_path = fullfile('D:\Git\A7_LacourseSpindleDetector\lib');
cd 'D:\Git\A7_LacourseSpindleDetector'
SM_detectSpindles(sub_id, source_path,dep_path)