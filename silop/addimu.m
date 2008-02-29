% ADDIMU Añade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox
%
% ADDIMU añade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox. 
% Se debe incluir la lista completa de IMUs a usar antes de realizar la conexión
% 
% Syntax: 
%   addimu(posicion,numserie, orientacion);
%
%   Parámetros de entrada: 
%	posicion -> Cadena de texto conteniendo la posición en la que está el sensor.
%		    Puede ser: 'COG','MUSLO_DCHO','MUSLO_IZDO','TIBIA_DCHA','TIBIA_IZDA','PIE_DCHO' o 'PIE_IZDO'.
%	numserie -> numero de serie
%       orientacion -> Vector de tres elementos que debe indicar cual es la dirección antero-posterior,
%                   medio-lateral y vertical referida a los ejes del acelerómetro. X=1,Y=2,Z=3.
%                   Por defecto vale [3,-2,1] en el COG=[antero-posterior=Z del acelerómetro, Medio-lateral=-Y del
%                   acelerómetro, vertical=X del acelerómetro].
%                   En el resto de puntos es [1,2,3], o lo que es lo mismo, no se reorientan por defecto.
%		    Se aceptan valores negativos para indicar que el eje anatómico y el del acelerómetro son opuestos.
%	            
%   Parámetros de salida: Ninguno
% 
% Examples: 
%   
%
% See also: 

% Author:   Antonio López
% History:  24.01.2008  creado
%           24.01.2008 Incorporado a la toolbox
%

function addimu(donde, serie, R)
	
	if (nargin<2)
		error('es necesario especificar los dos primeros parámetros');
	elseif (nargin<3)
		if (strcmp(donde,'COG'))
			R=[3,-2,1];
		else R=[1,2,3];
		end
	end

	if (isempty(strmatch(donde, strvcat('COG','PIE_IZDO','PIE_DCHO','MUSLO_IZDO','MUSLO_DCHO','TIBIA_IZDA','TIBIA_DCHA'),'exact')))
		warning('posición de IMU no reconocida')
	else 
		global SILOP_CONFIG;
		eval(['SILOP_CONFIG.SENHALES.',donde,'.Serie=serie;']);
		eval(['SILOP_CONFIG.SENHALES.',donde,'.R=R;']);
	end

