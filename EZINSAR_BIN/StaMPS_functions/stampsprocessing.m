function stampsprocessing(src,evt,action,miesar_para)
%   stampsprocessing(src,evt,action,miesar_para)
%       [src]           : callback value
%       [evt]           : callback value
%       [action]        : name of the action to perform (string value)
%       [miesar_para]   : user parameters (struct.)
%
%       Function to control the StaMPS processor and initiate the InSAR
%       stack.
%          
%       Script from EZ-InSAR toolbox: https://github.com/alexisInSAR/EZ-InSAR
%
%   See also runGUISBASnetwork, runGUIstampsparameters, stampsMERGEDprocessing, stampsprocessing, stampsPSprocessing, stampsSBASprocessing.
%
%   -------------------------------------------------------
%   Alexis Hrysiewicz, UCD / iCRAG
%   Version: 2.0.0 Beta
%   Date: 30/11/2021
%
%   -------------------------------------------------------
%   Modified:
%           - Xiaowen Wang, UCD, 12/02/2022: bug fix
%           - Alexis Hrysiewicz, UCD / iCRAG, 13/07/2022: StripMap
%           implementation
%           - Alexis Hrysiewicz, UCD / iCRAG, 18/07/2022: modification of
%           text information
%
%   -------------------------------------------------------
%   Version history:
%           1.0.0 Beta: Initial (unreleased)
%           2.0.0 Beta: Initial (unreleased)


switch action
    case 'cropping'
        %% Crop the SLC stack (mandatory) 

        % Check the available results and create the crop command
        if exist([miesar_para.WK,'/merged'])==0
            si = ['The merged directory does seems presented.'];
            update_textinformation([],[],[],si,'error');
            error(si);
        else
            [lon,lat] = read_kml([miesar_para.WK,'/area.kml']);

            cmd = [miesar_para.cur,'/Suppfunctions/run_SLCcropStack_mod.csh 1 ',miesar_para.WK,'/merged ',miesar_para.WK,'/cropped ', num2str(min(lat)),' ', num2str(max(lat)),' ', num2str(min(lon)),' ', num2str(max(lon))];
        end
        
        si = ['Running of SLC-stack cropping...'];
        update_textinformation([],[],[],si,'information');
        
        % Write the script
        scripttoeval = ['scripttoeval_',miesar_para.id,'.sh'];

        fid = fopen(scripttoeval,'w');
        fprintf(fid,'%s\n',cmd);
        fclose(fid);
        % Run the sscript
        system(['chmod a+x ',scripttoeval]);
        if strcmp(computer,'MACI64') == 1
            %                     system('./runmacterminal.sh');
        else
            system(['./',scripttoeval]);
        end
        try
            delete(scripttoeval)
        end

    case 'singlemasterstack'
        %% Preparation of the Single-reference stack for StaMPS
        paramslc = load([miesar_para.WK,'/parmsSLC.mat']);

        % Load the work directory and the log 
        fi = fopen([miesar_para.WK,'/commandstack.log'],'r');
        b = textscan(fi,'%s'); fclose(fi); b = b{1};
        
        % Find the refer date 
        if strcmp(paramslc.mode,'S1_IW') == 1
            IndexC = strfind(b,['-m']);
        else
            IndexC = strfind(b,['--reference_date']);
        end 
        Index = find(not(cellfun('isempty',IndexC)));
        datem = b{Index+1};
        
        % Find the range looks
        if strcmp(paramslc.mode,'S1_IW') == 1
            IndexC = strfind(b,['-r']);
        else
            IndexC = strfind(b,['--range_looks']);
        end 
        Index = find(not(cellfun('isempty',IndexC)));
        if isempty(Index) == 0
            rlooks = b{Index+1};
        else
            rlooks = '2';
        end
        
        % Find the azi looks
        if strcmp(paramslc.mode,'S1_IW') == 1
            IndexC = strfind(b,['-z']);
        else
            IndexC = strfind(b,['--azimuth_looks']);
        end
        Index = find(not(cellfun('isempty',IndexC)));
        if isempty(Index) == 0
            zlooks = b{Index+1};
        else
            zlooks = '2';
        end
        
        % Find the ratio
        aspratio = num2str(fix(str2num(rlooks)./str2num(zlooks)));
        
        % Find lambda
        prompt = {'Enter the lambda [m]:'};
        dlgtitle = 'Input';
        dims = [1 35];

        if strcmp(paramslc.mode,'S1_IW') == 1 | strcmp(paramslc.mode,'S1_SM') == 1
            definput = {'0.055465760'};
        elseif strcmp(paramslc.mode,'TSX_SM') == 1 | strcmp(paramslc.mode,'TSX_SPT') == 1 | strcmp(paramslc.mode,'PAZ_SM') == 1 | strcmp(paramslc.mode,'PAZ_SPT') == 1
            definput = {'0.0311'};
        elseif strcmp(paramslc.mode,'CSK_SM') == 1 | strcmp(paramslc.mode,'CSK_SPT') == 1 
            definput = {'0.0311'};
        end 

        answer = inputdlg(prompt,dlgtitle,dims,definput);
        lw = answer{1};
        
        % Find the directories
        if exist([miesar_para.WK,'/cropped'])==7
            answer = questdlg('Cropping data have been detected. Do you want to process them?', ...
                'Input', ...
                'YES','NO, process all images','YES');
            switch answer
                case 'YES'
                    dirslc = 'cropped/SLC';
                    dirgeo = 'cropped/geom_reference';
                    dirbase = 'cropped/baselines';
                case 'NO, process all images'
                    dirslc = 'merged/SLC';
                    dirgeo = 'merged/geom_reference';
                    dirbase = 'merged/baselines';
            end
        else
            dirslc = 'merged/SLC';
            dirgeo = 'merged/geom_reference';
            dirbase = 'merged/baselines';
        end
        
        % Check if the directory already is created
        rep = 1; 
        if exist([miesar_para.WK,'/stackStaMPS'])
            answer = questdlg('The Stack-StaMPS directory already exists. Do you want to continue? ', ...
                'Warning', ...
                'Yes','No','No');
            switch answer 
                case 'No'
                    rep = 0; 
            end
        end
        if rep == 0
            si = ['The preparation has been cancelled.'];
            update_textinformation([],[],[],si,'error');
            error(si);
        end 
        
        % Directory to StaMPS processing
        pathstampsprocessing = [miesar_para.WK,'/stackStaMPS'];
        system(['mkdir ',pathstampsprocessing]);
        pathstampsprocessingbis = uigetdir(pathstampsprocessing);
        if strcmp(pathstampsprocessing,pathstampsprocessingbis) == 0
%            system(['rm -R ',pathstampsprocessing]);
            pathstampsprocessing = pathstampsprocessingbis;
        end
        fi = fopen([miesar_para.WK,'/stampsdirectory.log'],'w');
        fprintf(fi,'%s\n',pathstampsprocessing);
        fprintf(fi,'%s/INSAR_%s',pathstampsprocessing,datem);
        fclose(fi);
        
        % Write the file
        fi = fopen([pathstampsprocessing,'/input_file'],'w');
        fprintf(fi,'source_data %s\n','slc_stack');
        fprintf(fi,'slc_stack_path %s\n',[miesar_para.WK,'/',dirslc]);
        fprintf(fi,'slc_stack_reference %s\n\n',datem);
        fprintf(fi,'slc_stack_geom_path %s\n',[miesar_para.WK,'/',dirgeo]);
        fprintf(fi,'slc_stack_baseline_path %s\n\n',[miesar_para.WK,'/',dirbase]);
        fprintf(fi,'range_looks %s\n',rlooks);
        fprintf(fi,'azimuth_looks %s\n',zlooks);
        fprintf(fi,'aspect_ratio %s\n\n',aspratio);
        fprintf(fi,'lambda %s\n',lw);

        if strcmp(paramslc.mode,'S1_IW') == 1 
            fprintf(fi,'slc_suffix %s\n','.full');
            fprintf(fi,'geom_suffix %s\n','.full');
        else
            fprintf(fi,'slc_suffix %s\n','');
            fprintf(fi,'geom_suffix %s\n','');
        end 
        
        % Write the script for evaluation
        scripttoeval = ['scripttoeval_',miesar_para.id,'.sh'];
        fid = fopen(scripttoeval,'w');
        fprintf(fid,'cd %s\n',pathstampsprocessing);
        fprintf(fid,'make_single_reference_stack_isce\n');
        fclose(fid);
        
        % Log creation
        fid = fopen([pathstampsprocessing,'/PSprocess.log'],'w');
        fprintf(fid,'preparation NE\n');
        fprintf(fid,'setparm NE\n');
        fprintf(fid,'stamps1 NE\n');
        fprintf(fid,'stamps2 NE\n');
        fprintf(fid,'stamps3 NE\n');
        fprintf(fid,'stamps4 NE\n');
        fprintf(fid,'stamps5 NE\n');
        fprintf(fid,'stamps6 NE\n');
        fprintf(fid,'stamps7 NE\n');
        fprintf(fid,'stamps8 NE\n');
        fclose(fid);

        fid = fopen([pathstampsprocessing,'/SBASprocess.log'],'w');
        fprintf(fid,'network NE\n');
        fprintf(fid,'SBASifg NE\n');
        fprintf(fid,'preparation NE\n');
        fprintf(fid,'setparm NE\n');
        fprintf(fid,'stamps1 NE\n');
        fprintf(fid,'stamps2 NE\n');
        fprintf(fid,'stamps3 NE\n');
        fprintf(fid,'stamps4 NE\n');
        fprintf(fid,'stamps5 NE\n');
        fprintf(fid,'stamps6 NE\n');
        fprintf(fid,'stamps7 NE\n');
        fprintf(fid,'stamps8 NE\n');
        fclose(fid);

        fid = fopen([pathstampsprocessing,'/Mergedprocess.log'],'w');
        fprintf(fid,'merging NE\n');
        fprintf(fid,'setparm NE\n');
        fprintf(fid,'stamps1 NE\n');
        fprintf(fid,'stamps2 NE\n');
        fprintf(fid,'stamps3 NE\n');
        fprintf(fid,'stamps4 NE\n');
        fprintf(fid,'stamps5 NE\n');
        fprintf(fid,'stamps6 NE\n');
        fprintf(fid,'stamps7 NE\n');
        fprintf(fid,'stamps8 NE\n');
        fclose(fid);
        
        si = ['The Single Reference Stack for StaMPS will be created...'];
        set(findobj(gcf,'Tag','maintextoutput'),'Value',si);
        set(findobj(gcf,'Tag','maintextoutput'),'FontColor','black');
        
        % Run the sscript
        system(['chmod a+x ',scripttoeval]);
        if strcmp(computer,'MACI64') == 1
            %                     system('./runmacterminal.sh');
        else
            system(['./',scripttoeval]);
        end
        try
            delete(scripttoeval)
        end
        
        %%% Generate the look_angle file 
%%        la_in=[miesar_para.WK,'/',dirgeo,'/los.rdr.full'];
%%        la_ot=[miesar_para.WK,'/stackStaMPS/INSAR_',datem,'/look_angle.raw'];
%%        system(['imageMath.py -e="a_0" --a=',la_in,' -o ',la_ot,' -s BIL']);              
        
    case 'display'
        %% Message to display the final results. 
        t = sprintf('The processing with StaMPS is finished.\n\n-------------------\n\tIf you want display the results with the tools of StaMPS, see the manual and the use of ''ps_plot''.\n\n\tFor example, in Matlab: ps_plot(''v'',''ts'');\nto display the displacement rates. ');
        h=msgbox(t,'Success','warn');
end











