function mintpy_API_view(src,evt,action,miesar_para)
%   mintpy_API_view(src,evt,action,miesar_para)
%       [src]           : callback value
%       [evt]           : callback value
%       [action]        : name of the action to perform (string value)
%       [miesar_para]   : user parameters (struct.)
%
%       Function to interface the view.py commands from MintPy. 
%          
%       Script from EZ-InSAR toolbox: https://github.com/alexisInSAR/EZ-InSAR
%
%   See also mintpy_allstep, mintpy_API_tsplottrans, mintpy_parameters, mintpy_API_plot_trans, mintpy_API_plottrans, mintpy_processing, mintpy_API_save, mintpy_network_plot.
%
%   Examples and parameter descriptions from MintPy view.py script: https://github.com/insarlab/MintPy
%   Author: Zhang Yunjun, Heresh Fattahi, 2013
%
%   -------------------------------------------------------
%   Alexis Hrysiewicz, UCD / iCRAG
%   Version: 1.0.0 Beta
%   Date: 17/02/2022
%
%   -------------------------------------------------------
%   Version history:
%           1.0.0 Beta: Initiale (unreleased)

%% Create the GUI
figapimintpyview = uifigure('Position',[200 100 1000 800],'Name','MintPy''s View.py Application');

tbapimintpyview = uitoolbar(figapimintpyview);
helpapimintpyview = uipushtool(tbapimintpyview);
helpapimintpyview.Icon = fullfile(matlabroot,'toolbox','matlab','icons','help_ex.png');
helpapimintpyview.Tooltip = 'Help';
helpapimintpyview.ClickedCallback = @help_mintpy_API_view;

    function help_mintpy_API_view(src,event)
        cmd = {'Help for View.py';...
            '---------------------------------------';
            'Please:';
            '1) Select your dataset';
            '2) Select your subdataset (optional) regarding the use of View.py command';
            '3) Modify the parameters (yes/no or VALUE)';
            '4) Run'};
        boxtmp = msgbox(cmd, 'Help','Help for View.py');
    end 

glapimintpyview = uigridlayout(figapimintpyview,[20 5]);

titleapimintpyview = uilabel(glapimintpyview,'Text','MintPy''s View.py Application','HorizontalAlignment','center','VerticalAlignment','center','FontSize',30,'FontWeight','bold');
titleapimintpyview.Layout.Row = [1 2];
titleapimintpyview.Layout.Column = [1 5];

labeldatasetapimintpyview = uilabel(glapimintpyview,'Text','Dataset:','HorizontalAlignment','Left','VerticalAlignment','center','FontSize',15,'FontWeight','bold');
labeldatasetapimintpyview.Layout.Row = [3];
labeldatasetapimintpyview.Layout.Column = [1 2];

labelsubdatasetapimintpyview = uilabel(glapimintpyview,'Text','Subdataset:','HorizontalAlignment','Right','VerticalAlignment','center','FontSize',15,'FontWeight','bold');
labelsubdatasetapimintpyview.Layout.Row = [3];
labelsubdatasetapimintpyview.Layout.Column = [4 5];

datasetapimintpyview = uidropdown(glapimintpyview,'ValueChangedFcn', @(src,event) subdatasetupdate(src,event));
datasetapimintpyview.Layout.Row = [4];
datasetapimintpyview.Layout.Column = [1 2];

subdatasetapimintpyview = uitextarea(glapimintpyview);
subdatasetapimintpyview.Layout.Row = [4];
subdatasetapimintpyview.Layout.Column = [4 5];
subdatasetapimintpyview.Tooltip = {'example:';...
    'view.py velocity.h5';...
    'view.py velocity.h5 velocity --wrap --wrap-range -2 2 -c cmy --lalo-label';...
    'view.py velocity.h5 --ref-yx  210 566                              #change reference pixel for display';...
    'view.py velocity.h5 --sub-lat 31.05 31.10 --sub-lon 130.05 130.10  #subset in lalo / yx';...
    '  ';...
    'view.py timeseries.h5';...
    'view.py timeseries.h5 -m no                   #do not use auto mask';...
    'view.py timeseries.h5 --ref-date 20101120     #change reference date';...
    'view.py timeseries.h5 --ex drop_date.txt      #exclude dates to plot';...
    'view.py timeseries.h5 ''*2017*'' ''*2018*''       #all acquisitions in 2017 and 2018';...
    'view.py timeseries.h5 20200616_20200908       #reconstruct interferogram on the fly';...
    '';...
    'view.py ifgramStack.h5 coherence';...
    'view.py ifgramStack.h5 unwrapPhase-           #unwrapPhase only in the presence of unwrapPhase_bridging';...
    'view.py ifgramStack.h5 -n 6                   #the 6th slice';...
    'view.py ifgramStack.h5 20171010_20171115      #all data      related with 20171010_20171115';...
    'view.py ifgramStack.h5 ''coherence*20171010*''  #all coherence related with 20171010';...
    'view.py ifgramStack.h5 unwrapPhase-20070927_20100217 --zero-mask --wrap     #wrapped phase';...
    'view.py ifgramStack.h5 unwrapPhase-20070927_20100217 --mask ifgramStack.h5  #mask using connected components';...

    '# GPS (for one subplot in geo-coordinates only)';...
    'view.py geo_velocity_msk.h5 velocity --show-gps --gps-label   #show locations of available GPS';...
    'view.py geo_velocity_msk.h5 velocity --show-gps --gps-comp enu2los --ref-gps GV01';...
    'view.py geo_timeseries_ERA5_ramp_demErr.h5 20180619 --ref-date 20141213 --show-gps --gps-comp enu2los --ref-gps GV01';...

    '# Save and Output';...
    'view.py velocity.h5 --save';...
    'view.py velocity.h5 --nodisplay';...
    'view.py geo_velocity.h5 velocity --nowhitespace';...
    };
labeltableapimintpyview = uilabel(glapimintpyview,'Text','Selection of parameters:','HorizontalAlignment','Left','VerticalAlignment','center','FontSize',15,'FontWeight','bold');
labeltableapimintpyview.Layout.Row = [5];
labeltableapimintpyview.Layout.Column = [1 5];

tableapimintpyview = uitable(glapimintpyview,'ColumnEditable',[false true false]);
tableapimintpyview.Layout.Row = [6 19];
tableapimintpyview.Layout.Column = [1 5];

buttonapimintpyview = uibutton(glapimintpyview,'Text','Run','ButtonPushedFcn', @(btn,event) run_api_view(btn,event));
buttonapimintpyview.Layout.Row = [20];
buttonapimintpyview.Layout.Column = [1 5];

%% Initialisation of datasets

% Load the MintPy directory
fi = fopen([miesar_para.WK,'/mintpydirectory.log'],'r');
pathmintpyprocessing = textscan(fi,'%s'); fclose(fi); pathmintpyprocessing = pathmintpyprocessing{1}{1};

%% Check the possible datasets
list_data_set = dir(pathmintpyprocessing);
data_set = cell(1);
h = 1;
for i1 = 1 : length(list_data_set)
    if isempty(strfind(list_data_set(i1).name,'.h5')) == 0
        data_set{h} = list_data_set(i1).name;
        h = h + 1;
    end

end
list_data_set = dir([pathmintpyprocessing,'/inputs']);
for i1 = 1 : length(list_data_set)
    if isempty(strfind(list_data_set(i1).name,'.h5')) == 0
        data_set{h} = list_data_set(i1).name;
        h = h + 1;
    end
end
list_data_set = dir([pathmintpyprocessing,'/geo']);
for i1 = 1 : length(list_data_set)
    if isempty(strfind(list_data_set(i1).name,'.h5')) == 0
        data_set{h} = list_data_set(i1).name;
        h = h + 1;
    end
end

%% Modification of dropdown
datasetapimintpyview.Items = data_set;
datasetapimintpyview.Value = data_set{end};

subdatasetupdate([],[])

%% Create the parameter table
paratable = {'--show-kept','no','';...
    '--show-kept-ifgram','no','';...
    '--noverbose','no','Disable the verbose message printing (default: True).';...
    '--math','','{deg2rad,rad2deg,square,reverse,sqrt,inverse} Apply the math operation before displaying [for single subplot ONLY].';...
    '--ram','','Max amount of memory in GB to use (default: 4.0).';...
    '--memory','','Adjust according to your computer memory.';...
    '--nosearch',  'no','Disable glob search for input dset.,';...
    '--exclude', '' ,'[Dset [Dset ...]] dates will not be displayed (default: []).';...
    '--vlim', '' ,'Display limits for matrix plotting.';...
    '--unit', '' ,'unit for display.  Its priority > wrap';...
    '--wrap',   'no' ,'';...
    '--wrap-range', '',' MIN MAX  range of one cycle after wrapping (default: [-3.141592653589793, 3.141592653589793]).';...
    '--flip-lr','no','flip left-right';...
    '--flip-ud','no','flip up-down';...
    '--noflip','no','turn off auto flip for radar coordinate file';...
    '--num-multilook','','multilook data in X and Y direction with a factor for display (default: 1).';...
    '--no-multilook','no', 'do not multilook, for high quality display. If multilook is True and multilook_num=1, multilook_num will be estimated automatically. Useful when displaying big datasets.';...
    '--alpha','','Data transparency. 0.0 - fully transparent, 1.0 - no transparency.';...
    '--dem','','DEM file to show topography as background';...
    '--mask-dem','no','Mask out DEM pixels not coincident with valid data pixels';...
    '--dem-noshade','no','do not show DEM shaded relief';...
    '--dem-nocontour','no','do not show DEM contour lines';...
    '--contour-smooth','','Background topography contour smooth factor - sigma of Gaussian filter. Set to 0.0 for no smoothing; (default: 3.0).';...
    '--contour-step','','Background topography contour step in meters (default: 200.0).';...
    '--contour-linewidth','','Background topography contour linewidth (default: 0.5).';...
    '--shade-az','','The azimuth (0-360, degrees clockwise from North) of the light source (default: 315.0).';...
    '--shade-alt','','The altitude (0-90, degrees up from horizontal) of the light source (default: 45.0).';...
    '--shade-min','','The min height in m of colormap of shaded relief topography (default: -4000.0).';...
    '--shade-max','','The max height of colormap of shaded relief topography (default: max(DEM)+2000).';...
    '--shade-exag','','Vertical exaggeration ratio (default: 0.5).';...
    '--fontsize','','font size';...
    '--fontcolor','','font color (default: k).';...
    '--nowhitespace','no','do not display white space';...
    '--noaxis','no','do not display axis';...
    '--notick','no','do not display tick in x/y axis';...
    '--colormap','','colormap used for display, i.e. jet, cmy, RdBu, hsv, jet_r, temperature, viridis, etc. More at https://mintpy.readthedocs.io/en/latest/api/colormaps/';...
    '--cmap-lut','','number of increment of colormap lookup table (default: 256).';...
    '--cmap-vlist','','list of 3 float numbers, for truncated colormap only (default: [0.0, 0.7, 1.0]).';...
    '--nocolorbar','no','do not display colorbar';...
    '--cbar-nbins','','number of bins for colorbar.';...
    '--cbar-ext','','{both,max,None,min,neither} Extend setting of colorbar; based on data stat by default.';...
    '--cbar-label','','colorbar label colorbar location for single plot (default: right).';...
    '--cbar-size','','colorbar size and pad (default: 2%).';...
    '--notitle','no','do not display title';...
    '--title-in','no','draw title in/out of axes';...
    '--figtitle','',' Title shown in the figure.';...
    '--title4sentinel1','no','display Sentinel-1 A/B and IPF info in title.';...
    '--figsize','','figure size in inches - width and length';...
    '--dpi','','DPI - dot per inch - for display/write (default: 300).';...
    '--figext','','{.emf,.eps,.pdf,.png,.ps,.raw,.rgba,.svg,.svgz} File extension for figure output file (default: .png).';...
    '--fignum','','number of figure windows';...
    '--nrows','','subplot number in row';...
    '--ncols','','subplot number in column';...
    '--wspace','','width space between subplots in inches';...
    '--hspace','','height space between subplots in inches';...
    '--no-tight-layout','no','disable automatic tight layout for multiple subplots';...
    '--coord','','{radar,geo} Display in radar/geo coordination system (for geocoded file only; default: geo).';...
    '--animation','no','enable animation mode';...
    '--show-gps','no','Show UNR GPS location within the coverage.';...
    '--mask-gps','no','Mask out GPS stations not coincident with valid data pixels';...
    '--gps-label','no','Show GPS site name';...
    '--gps-ms','','Plot GPS value as scatter in size of ms**2 (default: 6).';...
    '--gps-comp','','{enu2los,hz2los,vert,up2los,horz} Plot GPS in color indicating deformation velocity direction';...
    '--gps-redo','no','Re-calculate GPS observations in LOS direction, instead of read from existing CSV file.';...
    '--ref-gps','','Reference GPS site';...
    '--ex-gps','','[EX_GPS_SITES [EX_GPS_SITES ...]] Exclude GPS sites, require --gps-comp.';...
    '--gps-start-date','','YYYYMMDD start date of GPS data, default is date of the 1st SAR acquisition';...
    '--gps-end-date','','YYYYMMDD start date of GPS data, default is date of the last SAR acquisition';...
    '--hz-az','','Azimuth angle (anti-clockwise from the north) of the horizontal movement in degrees E.g.: -90. for east  direction [default] 0.  for north direction Set to the azimuth angle of the strike-slip fault to show the fault-parallel displacement.';...
    '--mask','','mask file for display. "no" to turn OFF masking.';...
    '--mask-vmin','','hide pixels with mask value < vmin (default: None).';...
    '--mask-vmax','','hide pixels with mask value > vmax (default: None).';...
    '--zero-mask','no','mask pixels with zero value.';...
    '--coastline','','{110m,50m,10m} Draw coastline with specified resolution (default: None). This will enable --lalo-label option. Link: https://scitools.org.uk/cartopy/docs/latest/matplotlib/geoaxes.html#cartopy.mpl.geoaxes.GeoAxes.coastlines one subplot in geo-coordinates only';...
    '--lalo-label','no','Show N, S, E, W tick label for plot in geo-coordinate. Useful for final figure output. one subplot in geo-coordinates only';...
    '--lalo-step','','Lat/lon step for lalo-label option. one subplot in geo-coordinates only';...
    '--lalo-max-num','','Maximum number of lalo tick label (default: 3). one subplot in geo-coordinates only';...
    '--lalo-loc','','left right top bottom Draw lalo label in [left, right, top, bottom] (default: [1, 0, 0, 1]). one subplot in geo-coordinates only';...
    '--scalebar','','LEN X Y scale bar distance and location in ratio (default: [0.2, 0.2, 0.1]).distance in ratio of total width location in X/Y in ratio with respect to the lower left corner --scalebar 0.2 0.2 0.1  #for lower left  corner --scalebar 0.2 0.2 0.8  #for upper left  corner --scalebar 0.2 0.8 0.1  #for lower right corner --scalebar 0.2 0.8 0.8  #for upper right corner one subplot in geo-coordinates only';...
    '--noscalebar','no','do not display scale bar. one subplot in geo-coordinates only';...
    '--scalebar-pad','','scale bar label pad in ratio of scalebar width (default: 0.05). one subplot in geo-coordinates only';...
    '--pts-marker','','Marker of points of interest (default: k^).';...
    '--pts-ms','','Marker size for points of interest (default: 6.0).';...
    '--pts-yx','','Y X Point in Y/X';...
    '--pts-lalo','','LAT LON Point in Lat/Lon';...
    '--pts-file','','Text file for point(s) in lat/lon column';...
    '--ref-date','','Change reference date for display';...
    '--ref-lalo','','LAT LON Change referene point LAT LON for display';...
    '--ref-yx','','Y X Change referene point Y X for display';...
    '--noreference','no','do not show reference point';...
    '--ref-marker','','marker of reference pixel (default: ks).';...
    '--ref-size','','marker size of reference point (default: 6).';...
    '-o','','[OUTFILE [OUTFILE ...]], --outfile [OUTFILE [OUTFILE ...]] save the figure with assigned filename. By default, it''s calculated based on the input file name.';...
    '--save','no','save the figure';...
    '--nodisplay','no','save and do not display the figure';...
    '--update','no','enable update mode for save figure: skip running if 1) output file already exists AND 2) output file is newer than input file.';...
    '--sub-x','','XMIN XMAX subset display in x/cross-track/range direction';...
    '--sub-y','','YMIN YMAX subset display in y/along-track/azimuth direction';...
    '--sub-lat','','LATMIN LATMAX subset display in latitude';...
    '--sub-lon','','LONMIN LONMAX subset display in longitude';...
    };

tableapimintpyview.Data = cell2table(paratable,'VariableNames',{'Parameters' 'Value' 'Information'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Other functions (global)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Update the pathdataset
    function subdatasetupdate(src,event)
        cur_value = datasetapimintpyview.Value;
        pref = '';
        if isempty(strfind(cur_value,'geo'))==0 & strcmp(cur_value,'geometryRadar.h5')== 0
            pref = 'geo/';
        elseif strcmp(cur_value,'ifgramStack.h5')== 1 | strcmp(cur_value,'geometryRadar.h5')== 1
            pref = 'inputs/';
        else
            pref = '';
        end
        pathdataset = [pathmintpyprocessing,'/',pref,cur_value];
    end

%% Run the application
    function run_api_view(btn,event)
        cur_dataset = datasetapimintpyview.Value;
        cur_subdataset = subdatasetapimintpyview.Value{1};

        pref = '';
        if isempty(strfind(cur_dataset,'geo'))==0 & strcmp(cur_dataset,'geometryRadar.h5')== 0
            pref = 'geo/';
        elseif strcmp(cur_dataset,'ifgramStack.h5')== 1 | strcmp(cur_dataset,'geometryRadar.h5')== 1
            pref = 'inputs/';
        else
            pref = '';
        end

        % Check the parameters
        paratablecheck = table2cell(tableapimintpyview.Data);
        cmd = ['view.py ',pref,cur_dataset,' ',cur_subdataset];
        for i1 = 1 : size(paratablecheck)
            if isempty(paratablecheck{i1,2}) == 0 & strcmp(paratablecheck{i1,2},'no') == 0
                if strcmp(paratablecheck{i1,2},'yes') == 1
                    cmd = [cmd,' ',paratablecheck{i1,1}];
                else
                    cmd = [cmd,' ',paratablecheck{i1,1},' ',paratablecheck{i1,2}];
                end
            end
        end

        % Write the command
        scripttoeval = ['scripttoeval_',miesar_para.id,'.sh'];
        fid = fopen(scripttoeval,'w');
        fprintf(fid,'cd %s\n',[pathmintpyprocessing]);
        fprintf(fid,'%s > %s/view.log &\n',cmd,miesar_para.cur);
        fclose(fid);

        % Run the script
        system(['chmod a+x ',scripttoeval]);
        if strcmp(computer,'MACI64') == 1
            %                     system('./runmacterminal.sh');
        else
            system(['./',scripttoeval]);
        end
        try
            delete(scripttoeval)
        end
    end

end
