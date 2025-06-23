function attr = eval_python_class_field(plugin_path, attr_name)
    f = fullfile(get_app_python_src_path(), 'registry', 'eval_plugin_class_field.py');
    attr = run_py_file(f, "attr", '--plugin_path', plugin_path, '--attr_name', attr_name);
end