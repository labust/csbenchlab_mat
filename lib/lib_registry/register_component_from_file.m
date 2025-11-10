function ret = register_component_from_file(comp_file, lib_name)
  
   info = get_plugin_info_from_file(comp_file);
   if ~is_valid_field(info, 'Type')
       ret = 0;
       return
   end
   ret = register_component(info, lib_name);
end
