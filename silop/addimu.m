% ADDIMU Añade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox
%
% ADDIMU añade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox. 
% Se debe incluir la lista completa de IMUs a usar antes de realizar la conexión
% 
% Syntax: 
%   CONFIG=addimu(CONFIG,posicion,numserie, orientacion);
%
%   Parámetros de entrada: 
%	CONFIG   -> estructura de configuración de la aplicación antes de añadir el sensor
% 	posicion -> Cadena de texto conteniendo la posición en la que está el sensor.
%		    Puede ser: 'COG','MUSLO_DCHO','MUSLO_IZDO','TIBIA_DCHA','TIBIA_IZDA','PIE_DCHO' o 'PIE_IZDO'.
%	numserie -> numero de serie
%       orientacion -> Vector de tres elementos que debe indicar cual es la dirección antero-posterior,
%                   medio-lateral y vertical referida a los ejes del acelerómetro. X=1,Y=2,Z=3.
%                   Por defecto vale [3,-2,1] en el COG=[antero-posterior=Z del acelerómetro, Medio-lateral=-Y del
%                   acelerómetro, vertical=X del acelerómetro].
%                   En el resto de puntos es [1,2,3], o lo que es lo mismo, no se reorientan por defecto.
%		    Se aceptan valores negativos para indicar que el eje anatómico y el del acelerómetro son opuestos.
%	            
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

function CONFIG=addimu(CONFIG, donde, serie, R)
	
	if (nargin<3)
		error('es necesario especificar los tres primeros parámetros');
	elseif (nargin<4)
		if (donde=='COG')
			R=[3,-2,1];
		else R=[1,2,3];
		end
	end

    switch donde
        
        case 'COG',
            CONFIG.SENHALES.COG.Serie = serie;
            CONFIG.SENHALES.COG.R = R;
        case 'MUSLO_DCHO',
            CONFIG.SENHALES.MUSLO_DCHO.serie = serie;
            CONFIG.SENHALES.MUSLO_DCHO.R = R;
        case 'MUSLO_IZDO',
            CONFIG.SENHALES.MUSLO_IZDO.serie = serie;
            CONFIG.SENHALES.MUSLO_IZDO.R = R;
        case 'TIBIA_DCHA',
            CONFIG.SENHALES.TIBIA_DCHA.serie = serie;
            CONFIG.SENHALES.TIBIA_DCHA.R = R;
        case 'TIBIA_IZDA',
            CONFIG.SENHALES.TIBIA_IZDA.serie = serie;
            CONFIG.SENHALES.TIBIA_IZDA.R = R;
        case 'PIE_DCHO',
            CONFIG.SENHALES.PIE_DCHO.serie = serie;
            CONFIG.SENHALES.PIE_DCHO.R = R;
        case 'PIE_IZDO',
            CONFIG.SENHALES.PIE_IZDO.serie = serie;
            CONFIG.SENHALES.PIE_IZDO.R = R;
            
        otherwise
            warning('posición de IMU no reconocida')
    end;
