% FILTRO0 Filtro paso bajo de fase cero
%
% FILTRO0 Implementa un filtro FIR paso bajo de fase 0. 
% 
% Syntax: Y=filtro0(datos,orden,corte)
% 
% Input parameters:
%   datos-> señal a filtrar
%   N    -> orden del filtro FIR a usar
%   corte-> frecuencia de corte normalizada. La frecuencia de corte debe estar entre 0 y 1, con 1
% 		correspondiendo a la mitad de la frecuencia de muestreo
%
% Output parameters:
%   maximos<- vector conteniendo la posicion de los maximos
%
% Examples:
% %filtramos a 2.5Hz una señal muestreada a 100Hz. fcorte=0.05*100/2
% filtrado=filtro0(datos,60,0.05); 
%
% See also: 

% Author:   Diego
% History:  xx.yy.zz    Diegocrea el archivo
%           18.05.2006  comentada por JC
%           21.01.2008  documentada


function Y=filtro0 (datos,orden,corte)

b=fir1(orden/2,corte,'stop');

Y=filtfilt(b,1,datos);
