function register_component(info, t, lib_name)

   if t == 1
       register_system(info, lib_name);
   elseif t == 2
       register_controller(info, lib_name);
   elseif t == 3
       register_estimator(info, lib_name);
   elseif t == 4
       register_disturbance_generator(info, lib_name);
   end
    
end

