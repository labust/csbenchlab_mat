function t = is_valid_m_function(name)
    
    try
        a = eval(strcat('@', name));
        if isa(a, 'function_handle')
            t = 1;
            return
        end
    catch
        t = 0;
    end
        
end

