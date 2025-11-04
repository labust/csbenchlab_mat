function scenarios = eval_scenario_descriptions(env_path, env_data)

    script_path = fullfile(CSPath.get_app_python_src_path(), 'm_scripts',...
        'eval_scenario_descriptions.py');


    result = eval_py_script_with_json_argument(script_path, '--env-data-path', env_data, "result", '--env-path', env_path);
    scenarios = jsondecode(char(result));
end

