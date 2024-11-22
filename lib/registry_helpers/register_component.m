function register_component(info, t, lib_name)
   

   if strcmp(info.Type, 'm')
       if t == 1
           register_m_system(info, lib_name);
       elseif t == 2
           register_m_controller(info, lib_name);
       elseif t == 3
           register_m_estimator(info, lib_name);
       elseif t == 4
           register_m_disturbance_generator(info, lib_name);
       end
   end
    
end

