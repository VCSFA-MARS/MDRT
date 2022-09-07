function t = today() 
%TODAY Current date. 
% convenience function - decouple MDRT from financial toolbox 
 
c = clock; 
t = datenum(c(1),c(2),c(3)); 
