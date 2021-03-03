%% Steps to use:
% 1) Use Python_Configurer.py or MATLAB_Configurer.m to set the
%   configuration you want. In order to run CCO, you need to set
%   config.simulation.CCO_0_MRO_1 = 0 and fill in items like no_tx,
%   no_rx_min, BS_drop, and batch_tilts.
%   If you don't want to override the
%   base stations you define in the configurer: BS_drop=0, batch_tilts=[];
% 2) After verifying that your desired options are set, run this function,
%   which will run the batchrun or main code depending on how your tilts are
%   set.
% 3) Results are stored in the output_files folder depending on:
%   if all tilts were the same -> files are in the json, npz, mat folder
%   if tilts are not the same -> files are stored in their scenario folder

clear all;
close all;
big_tic = tic;
fprintf('SIMULATION STARTED ON: %s\n\n',datetime('now'))


params = mvrcQv2_init;

if params.batch == 1 % MRO or CCO multiple tilts
    fprintf("Pre-creating layout");
    params.save_layout = 1; % Force loading the layout to ensure base stations do not move between runs
    params.save_load_channels = 1; % Force loading channels because parallel outer loop is disabled
%     if ~isfile([pwd, 'savedBuilders/builders_obj.mat'])
%         params.save_load_channels = 0;
%     end
    mvrcQv2_layout(params);
    
    save_folder_r = [pwd, sprintf('/savedResults/%s/', params.run_i)];
    params.save_folder_r = save_folder_r;
    
    if ~exist(save_folder_r, 'dir')
        mkdir(save_folder_r);
    end

    fprintf(['Starting batch CCO for downtilts=[', num2str(params.info.simulation.batch_tilts'), ']\n']);
    mvrcQv2_batchrun(params);
else
    if ~params.sim_style % MRO single tilt
        fprintf("Starting MRO with downtilt=%i\n", params.downtilt);

        save_folder_r = ['savedResults/Scenario ', params.sim_num, '/'];
        
        if ~exist(save_folder_r, 'dir')
            mkdir(save_folder_r);
        end
        directories = dir(save_folder_r);
        num_dir = numel(directories([directories(:).isdir]))-2;
        save_folder_r = [save_folder_r, 'trial ', num2str(num_dir+1), '/'];
        params.save_folder_r = save_folder_r;
        mkdir(save_folder_r);
        
        mvrcQv2_MRO(params);
    
    else % CCO single tilt
        fprintf("Starting CCO with downtilt=%i\n", params.downtilt);
        
        save_folder_r = [pwd, sprintf('/savedResults/%s/', params.run_i)];
        params.save_folder_r = save_folder_r;
        
        if ~exist(save_folder_r, 'dir')
            mkdir(save_folder_r);
        end
        
        mvrcQv2_CCO(params);
    end
end



fprintf('==========================================\n');
fprintf('SIMULATION ENDED ON: %s\n',datetime('now'))
fprintf('SIMULATION RUNTIME = %0.0f sec (%0.1f h)\n', toc(big_tic), toc(big_tic)/3600);

