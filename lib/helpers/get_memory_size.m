function totSize = get_memory_size(this) 
    %https://www.mathworks.com/matlabcentral/answers/14837-how-to-get-size-of-an-object
   props = properties(this); 
   totSize = 0; 
   
   for ii=1:length(props) 
      currentProperty = getfield(this, char(props(ii))); 
      s = whos('currentProperty'); 
      totSize = totSize + s.bytes; 
   end
    
end