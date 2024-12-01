function s = varargin2stringarray(varargin)
    s = strings(nargin, 1);
    for i=1:nargin
        s(i) = convertCharsToStrings(varargin{i});
    end
end

