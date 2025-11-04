function path_ret = create_environment(path, name)
   

    path = fullfile(path, name);
    close_system(name, 0);
    
    if exist(path, 'dir')
        error('Cannot create environemnt. Already exists...');
    end

    if ~isempty(which(name))
        error(['Cannot create environemnt. File with name "', ...
            name, '" already exists on path...']);
    end

    
    path_ret = path;
    mkdir(path);
    % setup_metrics(name, path);
    mkdir(fullfile(path, 'params'));
    mkdir(fullfile(path, name));
    mkdir(fullfile(path, 'parts', 'controllers'));
    fclose(fopen(fullfile(path, strcat(name, '.cse')), "w"));
    new_system(name);
    save_system(name, fullfile(path, name));
    close_system(name, 0);
      
    cfg.Id = new_uuid;
    cfg.Name = name;
    cfg.Version = '0.1';
    cfg.Ts = 0.0;

    cfgName = fullfile(path, 'config.json');
    writestruct(cfg, cfgName, 'FileType','json');

    source_environment(path, name);
end


% 
% function setup_metrics(env_name, path)
%     mkdir(fullfile(path, 'autogen', 'metrics', 'private'));
%     addpath(fullfile(path, 'autogen', 'metrics'));
% 
%     f = fullfile(CSPath.get_app_template_path, 'eval_metrics_template.mt');
% 
%     t = fileread(f);
%     f_name = strcat(env_name, '_eval_metrics');
%     content = replace(t, '{{function_name}}', f_name);
% 
%     new_file_path = fullfile(path, 'autogen', 'metrics', strcat(f_name, '.m'));
%     h = fopen(new_file_path, 'w');
%     fprintf(h, content);
%     fclose(h);
% end
