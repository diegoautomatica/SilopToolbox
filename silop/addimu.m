% ADDIMU Añade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox
%
% ADDIMU añade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox. 
% Se debe incluir la lista completa de IMUs a usar antes de realizar la conexión
% 
% Syntax: 
%   CONFIG=addimu(posicion,numserie,CONFIG);
%
%   Parámetros de entrada: 
% 	posicion -> Cadena de texto conteniendo la posición en la que está el sensor.
%		    Puede ser: 'COG','MUSLO_DCHO','MUSLO_IZDO','TIBIA_DCHA','TIBIA_IZDA','PIE_DCHO' o 'PIE_IZDO'.
%	numserie -> numero de serie
%	CONFIG   -> estructura de configuración de la aplicación antes de añadir el sensor
%   Parámetros de salida: 
%	CONFIG  Estructura de configuración de la aplicación después de añadir el sensor
% 
% Examples: 
%   
%
% See also: 

% Author:   Antonio López
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
            warning('posición de IMU no reconocida')
    end;
