function env_params = load_env_param_struct(env_path, env_info, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end

    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    [~, env_name, ~] = fileparts(env_path);

    env_params = struct;

    env_params.Subcomponents = struct;
    env_params.ComponentContext = dictionary;
    
    fns = fieldnames(env_info);
    for i=1:length(fns)
        fn = fns{i};
        component_list = env_info.(fn);
        for j=1:length(component_list)
            comp = component_list(j);
            n = matlab.lang.makeValidName(comp.Name);
            if is_valid_field(comp, 'PluginType')
                env_params.(comp.PluginType).(n) = ...
                    eval_component_params(env_path, comp);
                rel_path = component_relative_path(comp);
                context_file = fullfile(env_path, rel_path, comp.Id);
                env_params.ComponentContext = ...
                    env_params.ComponentContext.insert(comp.Id, context_file);
            end

            if ~is_valid_field(comp, 'Subcomponents')
                continue
            end

            env_params.Subcomponents.(n) = struct;
            subcomponent_fields = comp.Subcomponents;
            for k=1:length(subcomponent_fields)
                if ~is_valid_field(comp, subcomponent_fields(k))
                    continue
                end
                subcomp = comp.(subcomponent_fields(k));
                for l=1:length(subcomp)
                    sub_n = matlab.lang.makeValidName(subcomp(l).Name);
                    v = eval_component_params(env_path, subcomp(l));
                    if ~is_valid_field(env_params.Subcomponents.(n), sub_n)
                        env_params.Subcomponents.(n).(sub_n) = v;
                    else
                        env_params.Subcomponents.(n).(sub_n)(end+1) = v;
                    end
                    rel_path = component_relative_path(subcomp);
                    context_file = fullfile(env_path, rel_path, subcomp.Id);
                    env_params.ComponentContext = ...
                        env_params.ComponentContext.insert(subcomp.Id, context_file);
                end

            end
        end
    end

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

