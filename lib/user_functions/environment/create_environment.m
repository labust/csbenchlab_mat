function path_ret = create_environment(name, varargin)
    
    pa = @BlockHelpers.path_append;
    if nargin == 2
        options = varargin{1};
    elseif nargin > 2
        options = EnvironmentOptions(varargin{:});
    end
    
    % set only after all the checks
    path_ret = '';
    if (isa(options.SystemParams, "char") || isa(options.SystemParams, "string")) && ~isempty(options.SystemParams)
        exist_exp = strcat("exist('", options.SystemParams, "', 'var')");
        if ~evalin('caller', exist_exp)
            error(strcat('Cannot create environemnt. ', options.SystemParams, ' variable does not exist...'));
        end
        paramsStruct = evalin('caller', options.SystemParams);
    else
        paramsStruct = options.SystemParams;
    end

    if ~isempty(options.Path)
        path = options.Path;
    else
        path = pwd;
    end

    path = pa(path, name);
    controllers_lib_name = strcat(name, '_controllers');
    controllers_lib_path = pa(path, strcat(controllers_lib_name, '.slx'));
    save_controllers = 0;
    save_controllers_temp_file = "temp_controllers_lib.slx";

    close_system(name, 0);
    close_system(controllers_lib_name, 0);
    
    if exist(path, 'dir')
        if options.Override == 0
            error('Cannot create environemnt. Already exists...');
        else
            if exist(controllers_lib_path, 'file')
                load_system(controllers_lib_name);
                l = find_system(controllers_lib_name, 'SearchDepth', 1);
                len = length(l);
                close_system(controllers_lib_name);
                if len > 1
                    close_system(controllers_lib_name, 0)
                    answer = questdlg(['Controller library is not empty. Do you ' ...
                        'the library to persist?']);

                    if strcmp(answer, 'Cancel')
                        return
                    elseif strcmp(answer, 'Yes')
                        save_controllers = 1;
                        movefile(controllers_lib_path, save_controllers_temp_file);
                    end
                end
            end
            
            % suppres warnings on path removal
            warning('off', 'MATLAB:rmpath:DirNotFound'); 
            rmpath(pa(path, 'autogen'));
            rmpath(path);
            warning('on', 'MATLAB:rmpath:DirNotFound'); 
            rmdir(path, 's');
        end
    end

    if ~isempty(which(name))
        error(['Cannot create environemnt. File with name "', ...
            name, '" already exists on path...']);
    end

    
    path_ret = path;
    mkdir(path);
    mkdir(pa(path, 'autogen'));
    mkdir(pa(path, 'params'));
    fclose(fopen(fullfile(path, strcat(name, '.cse')), "w"));
    new_system(name);
    save_system(name, pa(path, name));
    close_system(name, 0);
    
    if save_controllers ~= 1
        new_system(controllers_lib_name, 'Library');
        save_system(controllers_lib_name, controllers_lib_path);
        close_system(controllers_lib_name);
    end

    mkdir(pa(path, 'saves'));

    
    system_config_file = pa('autogen', strcat(name, '_system.mat'));
    cfg.Name = name;
    cfg.Version = '0.1';
    cfg.Ts = options.Ts;
    cfg.System.Name = options.SystemName;
    cfg.System.Config = system_config_file;
    cfg.System.Params = options.SystemParams;
    cfg.System.Type = options.SystemType;
    cfg.System.Lib = options.SystemLib;

    try
        dims = evalin('caller', strcat(options.SystemParams, ".dims"));
    catch
        dims.input = -1;
        dims.outout = -1;
    end
    cfg.System.Dims = dims;

    cfg.Controllers = [];



    refs_path = pa(path, 'autogen', strcat(name, '_refs.mat'));
    if ~isempty(options.References)
        if isa(options.References, 'Simulink.SimulationData.Dataset')
            refs = options.References;
        else
            f = options.References;
            if ~endsWith(options.References, '.mat')
                f = strcat(options.References, '.mat');
            end
            if ~exist(f, 'file')
                error('Cannot copy scenarios. Scneario file does not exist.');
            end
            refs = load(refs_path);
            refs = refs.References;
            copyfile(f, refs_path);
        end
    else
        refs = Simulink.SimulationData.Dataset;
        element1 = Simulink.SimulationData.Signal;
        element1.Name = "Signal1";
        element1.Values = timeseries(0, 0);
        refs{1} = element1;
    end
    names = {};
    for i=1:refs.numElements
        names{end+1} = refs{i}.Name;
        ds = Simulink.SimulationData.Dataset;
        ds = ds.addElement(refs{i});
        eval(strcat(refs{i}.Name, ' = ds;'));
    end


    save(refs_path, names{:});


    scenarios_path = pa(path, 'autogen', strcat(name, '_scenarios.mat'));
    if ~isempty(options.Scenarios)
        Scenarios = options.Scenarios;
        validate_scenarios(Scenarios);
    else
        Scenarios = struct;
    end
    save(scenarios_path, 'Scenarios')


    plots_path = pa(path, 'autogen', strcat(name, '_plots.mat'));
    if ~isempty(options.Plots)
        Plots = options.Plots;
        validate_plots(Plots);
    else
        Plots = struct;
    end
    save(plots_path, 'Plots')


    cfgName = pa(path, 'config.json');
    params = paramsStruct;
    save(pa(path, system_config_file), 'params');
    clear('data');

    writestruct(cfg, cfgName, 'FileType','json');
    
    addpath(path);
    addpath(pa(path, 'autogen'));
    if save_controllers == 1    
        movefile(save_controllers_temp_file, controllers_lib_path);
    end
end
