function params = eval_casadi_py_component(plugin_path)
    
    temp_dir = fullfile(tempdir, 'csb_casadi_tmp');

    try
        run_py_file(script_path, '', ...
            '--plugin-path', plugin_path, ...
            '--result-path', temp_dir);
        delete_temp_dir(temp_dir);
    catch e
        delete_temp_dir(temp_dir)
        rethrow(e);
    end

    a = 5;

end

function delete_temp_dir(temp_dir)
    if exist(temp_dir, 'dir')
        rmdir(temp_dir, "s");
    end
end
