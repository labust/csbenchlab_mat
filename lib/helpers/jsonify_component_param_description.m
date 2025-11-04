function params = jsonify_component_param_description(params)
    if isa(params, 'cell')
      for i=1:length(params)
         if isa(params{i}.DefaultValue, 'function_handle')
            params{i}.DefaultValue = strcat('csb_m_fh');
         elseif isa(params{i}.DefaultValue, 'py.function')
            params{i}.DefaultValue = strcat('csb_py_fh');
         elseif isa(params{i}.DefaultValue, 'LoadFromFile')
            params{i}.DefaultValue = strcat('csb_load_from_file:', params{i}.DefaultValue.as_string());
         else
            params{i}.DefaultValue = double(params{i}.DefaultValue);
         end
      end
   end
end