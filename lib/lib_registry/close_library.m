function close_library(varargin)

    if isnumeric(varargin{end})
        f = varargin{1};
        n = nargin - 1;
    else
        f = 0;
        n = nargin;
    end
    for i=1:n
        name = varargin{i};
        close_system(strcat(name, '_sys'), f);
        close_system(strcat(name, '_ctl'), f);
        close_system(strcat(name, '_est'), f);
        close_system(strcat(name, '_dist'), f);
    end
end

