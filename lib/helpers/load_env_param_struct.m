function env_params = load_env_param_struct(env_path, env_info, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end

    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end

    params = eval_environment_params(env_path, env_info);
    it = environment_components_it(env_info);
    context = dictionary;
    env_params.Subcomponents = struct;
    for i=1:length(it)
        comp = it{i}.n;
        n = matlab.lang.makeValidName(comp.Name);

        if ~is_valid_field(comp, 'PluginType')
            continue
        end
        
        % standalone component
        if isempty(it{i}.p)
            v = params(comp.Id);
            env_params.(comp.PluginType).(n) = v{1};          
        else % subcomponent
            parent_n = matlab.lang.makeValidName(it{i}.p.Name);
            v = params(comp.Id);
            if ~is_valid_field(env_params.Subcomponents, parent_n)
                env_params.Subcomponents.(parent_n) = struct;
            end
            if ~is_valid_field(env_params.Subcomponents.(parent_n), n)
                env_params.Subcomponents.(parent_n).(n) = v{1};
            else
                env_params.Subcomponents.(parent_n).(n)(end+1) = v{1};
            end
        end
        rel_path = component_relative_path(comp);
        context_file = fullfile(env_path, rel_path, comp.Id);
        context(comp.Id) = context_file;
    end
    env_params.ComponentContext = context;
    env_params.EnvPath = env_path;
    % for i=1:length(env_info.Controllers)
    %     n = matlab.lang.makeValidName(env_info.Controllers(i).Name);
    %     env_params.(env_info.Controllers(i).PluginType).(n) = ...
    %         eval_component_params(env_path, env_info.Controllers(i));
    % end
    % for i=1:length(env_info.System)
    %     n = matlab.lang.makeValidName(env_info.System(i).Name);
    %     env_params.(env_info.System(i).PluginType).(n) = ...
    %         eval_component_params(env_path, env_info.System(i));
    % end
    % for i=1:length(env_info.Controllers)
    %     n = matlab.lang.makeValidName(env_info.Controllers(i));
    %     env_params.ctl.(n) = 5;
    % end
    % for i=1:length(env_info.Controllers)
    %     n = matlab.lang.makeValidName(env_info.Controllers(i));
    %     env_params.ctl.(n) = 5;
    % end

end

