function [ output_args ] = MDRTannotation( type, text, P1, P2 )
%MDRTannotation Summary of this function goes here
%   Detailed explanation goes here

ax = gca;
pos = ax.Position;

xi = pos(1);
yi = pos(2);

xs = pos(3);
ys = pos(4);

X1 = (P1(1) - abs(min(xlim)) ) / diff(xlim) * xs + xi ;
Y1 = (P1(2) - abs(min(ylim)) ) / diff(ylim) * ys + yi ;

X2 = (P2(1) - abs(min(xlim)) ) / diff(xlim) * xs + xi ;
Y2 = (P2(2) - abs(min(ylim)) ) / diff(ylim) * ys + yi ;

han = annotation( type, [X1, X2], [Y1, Y2], 'String', text);

end

