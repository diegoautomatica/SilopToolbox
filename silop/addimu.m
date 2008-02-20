% ADDIMU A�ade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox
%
% ADDIMU a�ade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox. 
% Se debe incluir la lista completa de IMUs a usar antes de realizar la conexi�n
% 
% Syntax: 
%   CONFIG=addimu(posicion,numserie,CONFIG);
%
%   Par�metros de entrada: 
% 	posicion -> Cadena de texto conteniendo la posici�n en la que est� el sensor.
%		    Puede ser: 'COG','MUSLO_DCHO','MUSLO_IZDO','TIBIA_DCHA','TIBIA_IZDA','PIE_DCHO' o 'PIE_IZDO'.
%	numserie -> numero de serie
%	CONFIG   -> estructura de configuraci�n de la aplicaci�n antes de a�adir el sensor
%   Par�metros de salida: 
%	CONFIG  Estructura de configuraci�n de la aplicaci�n despu�s de a�adir el sensor
% 
% Examples: 
%   
%
% See also: 

% Author:   Antonio L�pez
% History:  24.01.2008  creado
%           24.01.2008 Incorporado a la toolbox
%

function CONFIG=addimu(donde, serie, conf)

    CONFIG = conf;

    switch donde
        
        case 'COG',
            CONFIG.SENHALES.COG.Serie = serie;
        case 'MUSLO_DCHO',
            CONFIG.SENHALES.MUSLO_DCHO.serie = serie;
        case 'MUSLO_IZDO',
            CONFIG.SENHALES.MUSLO_IZDO.serie = serie;
        case 'TIBIA_DCHA',
            CONFIG.SENHALES.TIBIA_DCHA.serie = serie;
        case 'TIBIA_IZDA',
            CONFIG.SENHALES.TIBIA_IZDA.serie = serie;
        case 'PIE_DCHO',
            CONFIG.SENHALES.PIE_DCHO.serie = serie;
        case 'PIE_IZDO',
            CONFIG.SENHALES.PIE_IZDO.serie = serie;
            
        otherwise
            warning('posici�n de IMU no reconocida')
    end;
