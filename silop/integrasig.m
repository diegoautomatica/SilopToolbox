%
% INTEGRASIG Integra una senyal hasta un instante, incluyendo reseteo
%
% INTEGRASIG Sirve para integrar una senyal hasta un cierto instante final,
% a partir del cual se supone que la senyal integrada vale cero, rellenan-
% dose el resto del vector de la senyal integrada con ceros. 
% Para forzar a que la senyal integrada valga cero en el instante final de 
% la integracion, se aplica un coeficiente de valores 1 en el instante ini-
% cial, y 0 en el instante final de la integracion, por ejemplo una recta, 
% o mas en general una curva definida por un coeficiente alfa que tiene 
% como valores extremos [0,1] entre los instantes inicial y final de
% integracion. 
% 
% Syntax: [sigint]=integrasig(sig,eventof,alfa,freq)
% 
% Input parameters:
%   sig         - Vector con la se–al original a integrar.
%   eventof     - Instante final de la integracion
%   alfa        - coeficiente de reset, entre 0 (sin reseteo) y 1 (lineal)
%   freq        - frecuencia de muestreo de los datos anteriores (en Hzs)
%
% Output parameters:
%   sigint     - senyal integrada y reseteada, de tama–o el de la se–al  
%                   original, y con ceros a partir de la posicion eventof
% Examples:
% % integracion de un giro muestreado a 100 Hz para obtener angulo, se 
% % integra la senyal completa sin reseteo
% >> tetaA=integrasig(giroY, size(giroY,1), 0, 100)
%
% See also: eventpierectoff

% Author:   Juan C. Alvarez
% History:  04.12.07    creacion del archivo


function [sigint]=integrasig(sig,eventof,alfa,freq)

% Set standard initialization parameter
       InitOptStandard = [size(sig,1), 0, 1];
   % eventof = size(sig,1) (integrate the whole signal),
   % alfa = 0 (no integral reset)
   % freq = 1 (original sampling 1 Hz)

% Check input parameters
   % At least the first input parameters is necessary
   if nargin < 1,  error('Not enough input parameters (at least 1 parameter - signal to integrate)'); end
   % When too many options are contained, issue a warning
   if nargin > 4,  warning('Too many input parameters! Only four are used'); end
   if isnan(sig), sig = []; end
   % The 3 other input parameter are optional,
   if nargin < 2,  
       eventof = InitOptStandard(1,1);
       alfa = InitOptStandard(1,2);
       freq = InitOptStandard(1,3);
   end
   if nargin < 3,  
       alfa = InitOptStandard(1,2);
       freq = InitOptStandard(1,3);
   end
   if nargin < 4,  
       freq = InitOptStandard(1,3);
   end

% integracion sin reseteo:
tmp=(1/freq)*cumsum(sig(1:eventof,:));
% se prepara un subvector para rellenar con ceros:
aux=zeros(size(sig,1)-eventof,1);

% si procede se hace el reseteo:
if ne(alfa,0),     
    for i=1:eventof,
        coef(i)=((eventof-i)/(eventof-1))^alfa; % numeros entre 1 y 0
        tmp2(i)=coef(i)*tmp(i); % se aplica la correcion
    end
    sigint=[tmp2'; aux]; % vector final resetado
% si no se quiere el reseteo solo se rellena de ceros:
else 
    sigint=[tmp; aux];
end
