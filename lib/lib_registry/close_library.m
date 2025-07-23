function close_library(name, varargin)

    if ~isempty(varargin)
        f = varargin{1};
    else
        f = 0;
    end
    close_system(strcat(name, '_sys'), f);
    close_system(strcat(name, '_ctl'), f);
    close_system(strcat(name, '_est'), f);
    close_system(strcat(name, '_dist'), f);
end

