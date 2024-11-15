function on_reference_generator_open()
    pa = @BlockHelpers.path_append;
    handle = gcbh;

    fn = getfullname(handle);
    splits = split(fn, '/');
    env_name = splits{1};

    % if no config, this is not an environment
    if exist(pa(env_name, 'config.json'), 'file')
        mo = get_param(handle, 'MaskObject');
        scenarios = load(pa(env_name, 'autogen', strcat(env_name, '_scenarios')));
        scenarios = scenarios.Scenarios;

        names = {};
        for i=1:length(scenarios)
            names{end+1} = scenarios(i).Name;  
        end
        warning('off', 'Simulink:Masking:InvalidMaskParameterValue');
        mo.Parameters.set('Name', 'scenario', 'Type', 'popup', ...
                'TypeOptions', names, 'Evaluate', 'off');
        warning('on', 'Simulink:Masking:InvalidMaskParameterValue');

    end
    open_system(handle, 'mask');
end