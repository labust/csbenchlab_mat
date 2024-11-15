function result = evaluate_on_scenarios(env_name, varargin)
    
    if ~isempty(varargin)
        scenarios = varargin{1};
    else
        scenarios = load_scenarios(env_name);
    end
    disp('Starting evaluation...')
    for i=1:length(scenarios)
        select_scenario(env_name, scenarios(i).Name);
        disp(strcat("Scenario ", num2str(i), "/", num2str(length(scenarios))));
        sim(env_name);
        result(i) = evalin('base', 'sim_result');
    end

end