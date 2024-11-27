function new_path = move_and_rename_function(file, new_path)
    
    [~, old_name, ~] = fileparts(file);
    [~, new_name, ~] = fileparts(new_path);
    text = fileread(file);
    
    try
        a = eval(strcat('@', old_name));
        if ~isa(a, 'function_handle')
            error('Function is not a valid function handle')
        end
    catch
        new_path = '';
        return
    end

    new_text = replace(text, old_name, new_name);
    f = fopen(new_path, 'w');
    fwrite(f, new_text);
    fclose(f);
   
end

