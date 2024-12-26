function path_ret = create_environment(name, varargin)
    
    fullfile = @BlockHelpers.path_append;
    if nargin == 1
        options = EnvironmentOptions();
    elseif nargin == 2
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

    path = fullfile(path, name);
    controllers_lib_name = strcat(name, '_controllers');
    controllers_lib_path = fullfile(path, strcat(controllers_lib_name, '.slx'));
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
            rmpath(fullfile(path, 'autogen'));
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
    setup_metrics(name, path);
    mkdir(fullfile(path, 'params'));
    mkdir(fullfile(path, 'parts', 'controllers'));
    fclose(fopen(fullfile(path, strcat(name, '.cse')), "w"));
    new_system(name);
    save_system(name, fullfile(path, name));
    close_system(name, 0);
    
    if save_controllers ~= 1
        new_system(controllers_lib_name, 'Library');
        save_system(controllers_lib_name, controllers_lib_path);
        close_system(controllers_lib_name);
    end

    mkdir(fullfile(path, 'saves'));
    
    cfg.Id = string(java.util.UUID.randomUUID.toString);
    cfg.Name = name;
    cfg.Version = '0.1';
    cfg.Ts = options.Ts;

    System.Id = string(java.util.UUID.randomUUID.toString);
    System.Name = options.SystemName;
    System.Params = options.SystemParams;
    System.Type = options.SystemType;
    System.Lib = options.SystemLib;
  

    try
        dims = evalin('caller', strcat(options.SystemParams, ".dims"));
    catch
        dims.input = -1;
        dims.outout = -1;
    end
    System.Dims = dims;

    refs_path = fullfile(path, 'autogen', strcat(name, '_refs.mat'));
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


    cfgName = fullfile(path, 'config.json');
    sysName = fullfile(path, 'parts', 'system.json');
    writestruct(cfg, cfgName, 'FileType','json');
    writestruct(System, sysName, 'FileType','json');

    
    addpath(path);
    addpath(fullfile(path, 'autogen'));
    if save_controllers == 1    
        movefile(save_controllers_temp_file, controllers_lib_path);
    end
end


function setup_metrics(env_name, path)
    mkdir(fullfile(path, 'autogen', 'metrics', 'private'));
    addpath(fullfile(path, 'autogen', 'metrics'));

    f = fullfile(get_app_root_path, 'lib', 'helpers', 'templates', 'eval_metrics_template.mt');

    t = fileread(f);
    f_name = strcat(env_name, '_eval_metrics');
    content = replace(t, '{{function_name}}', f_name);
    
    new_file_path = fullfile(path, 'autogen', 'metrics', strcat(f_name, '.m'));
    h = fopen(new_file_path, 'w');
    fprintf(h, content);
    fclose(h);
end