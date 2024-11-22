function opts = options_as_struct(options)
    % turn off warning on next line
    warning('off', 'MATLAB:structOnObject'); 
    opts = struct(options);
    warning('on', 'MATLAB:structOnObject');
end

