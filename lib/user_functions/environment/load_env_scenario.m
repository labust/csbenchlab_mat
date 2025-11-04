function s = load_env_scenario(env_path, name, varargin)
    s = load_component_data(env_path, fullfile('parts', 'scenarios', name, 'scenario.json'), varargin{:});
end