function unregister_component(info, t, lib_name)

   if t == 1
       unregister_system(info, lib_name);
   elseif t == 2
       unregister_controller(info, lib_name);
   elseif t == 3
       unregister_estimator(info, lib_name);
   elseif t == 4
       unregister_disturbance_generator(info, lib_name);
   end
    
end

