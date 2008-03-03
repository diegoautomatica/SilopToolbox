% ADDIMU A�ade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox
%
% ADDIMU a�ade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox. 
% Se debe incluir la lista completa de IMUs a usar antes de realizar la conexi�n
% 
% Syntax: 
%   addimu(posicion,numserie, orientacion);
%
%   Par�metros de entrada: 
%	posicion -> Cadena de texto conteniendo la posici�n en la que est� el sensor.
%		    Puede ser: 'COG','MUSLO_DCHO','MUSLO_IZDO','TIBIA_DCHA','TIBIA_IZDA','PIE_DCHO' o 'PIE_IZDO'.
%	numserie -> numero de serie
%       orientacion -> Vector de tres elementos que debe indicar cual es la direcci�n antero-posterior,
%                   medio-lateral y vertical referida a los ejes del aceler�metro. X=1,Y=2,Z=3.
%                   Por defecto vale [3,-2,1] en el COG=[antero-posterior=Z del aceler�metro, Medio-lateral=-Y del
%                   aceler�metro, vertical=X del aceler�metro].
%                   En el resto de puntos es [1,2,3], o lo que es lo mismo, no se reorientan por defecto.
%		    Se aceptan valores negativos para indicar que el eje anat�mico y el del aceler�metro son opuestos.
%	            
%   Par�metros de salida: Ninguno
% 
% Examples: 
%   
%
% See also: 

% Author:   Antonio L�pez
% History:  24.01.2008  creado
%           24.01.2008 Incorporado a la toolbox
%

function addimu(donde, serie, R) %#ok<INUSD>
	global SILOP_CONFIG; %#ok<NUSED>
	
	if (nargin<2)
		error('es necesario especificar los dos primeros par�metros');
	elseif (nargin<3)
		if (strcmp(donde,'COG'))
			R=[3,-2,1]; %#ok<NASGU>
		else R=[1,2,3]; %#ok<NASGU>
		end
	end

	if (isempty(strmatch(donde, {'COG','PIE_IZDO','PIE_DCHO','MUSLO_IZDO','MUSLO_DCHO','TIBIA_IZDA','TIBIA_DCHA'},'exact')))
        error('posicion de IMU no reconocida')
	else 
		eval(['SILOP_CONFIG.SENHALES.',donde,'.Serie=serie;']);
		eval(['SILOP_CONFIG.SENHALES.',donde,'.R=R;']);
	end

