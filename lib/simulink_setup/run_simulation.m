function run_simulation(env_name)
    hws = get_param(env_name, 'modelworkspace');
    
    d = hws.getVariable('simulation_description');

    if isa(d, 'simulink.multisim.DesignStudy')
        set_param(env_name, 'FastRestart', 'on');
        out = sim(d);        
    else
        set_param(env_name, 'FastRestart', 'off');
        out = sim(env_name);
    end
end