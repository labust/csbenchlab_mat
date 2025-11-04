function attr = eval_python_class_field(plugin_path, attr_name)
    f = fullfile(CSPath.get_app_python_src_path(), 'm_scripts', 'eval_plugin_class_field.py');
    attr = run_py_file(f, "attr", '--plugin_path', plugin_path, '--attr_name', attr_name);
end