function [t, msg] = validate_type_lib(comp)
    t = 0;
    msg = "";
    if strempty(comp.Type)
        t = 1;
        msg = "Component type is empty";
        return
    end
    if strempty(comp.Lib)
        t = 1;
        msg = "Component lib is empty";
        return
    end
end

