function on_reference_generator_open()
    handle = gcbh;

    fn = getfullname(handle);
    splits = split(fn, '/');
    env_name = splits{1};

    env_path = fileparts(which(env_name));
    
    
    % if no config, this is not an environment
    if exist(fullfile(env_path, 'config.json'), 'file')
        mo = get_param(handle, 'MaskObject');
        hws = get_param(env_name, 'modelworkspace');
        scenarios = hws.getVariable('Scenarios');
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