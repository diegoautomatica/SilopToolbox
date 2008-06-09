% ADDIMU Añade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox
%
% ADDIMU añade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox. 
% Se debe incluir la lista completa de IMUs a usar antes de realizar la conexion
% 
% Syntax: 
%   addimu(posicion,numserie, orientacion);
%
%   Parametros de entrada: 
%	posicion -> Cadena de texto conteniendo la posicion en la que esta el sensor.
%	numserie -> numero de serie
%       orientacion -> Vector de tres elementos que debe indicar cual es la direccion antero-posterior,
%                   medio-lateral y vertical referida a los ejes del acelerometro. X=1,Y=2,Z=3.
%                   Por defecto vale [3,-2,1] en el COG=[antero-posterior=Z del acelerometro, Medio-lateral=-Y del
%                   acelerometro, vertical=X del acelerometro].
%                   En el resto de puntos es [1,2,3], o lo que es lo mismo, no se reorientan por defecto.
%		    Se aceptan valores negativos para indicar que el eje anatomico y el del acelerometro son opuestos.
%	            
%   Parametros de salida: Ninguno
% 
% Examples: 
%   
%
% See also: 

% Author:   Antonio Lopez
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

    posiciones=fieldnames(SILOP_CONFIG.SENHALES);
	if (isempty(strmatch(donde, posiciones,'exact')))
        for campo={'Serie','Acc_Z','Acc_Y','Acc_X','G_Z','G_Y','G_X','MG_Z','MG_Y','MG_X'}
            SILOP_CONFIG.SENHALES.(donde).(campo{1})=-1;
        end
    else
        if (SILOP_CONFIG.SENHALES.(donde).Serie~=-1)
            error('el sensor ya estaba declarado')
        end
		SILOP_CONFIG.SENHALES.(donde).Serie=serie;
		SILOP_CONFIG.SENHALES.(donde).R=R;
	end

