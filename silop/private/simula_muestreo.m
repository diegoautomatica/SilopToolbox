% SIMULA_MUESTREO Callback que simula la realización de un muestreo desde los Xsens
%
% SIMULA_MUESTREO Callback que simula la realización de un muestreo desde los Xsens. Está pensada para ser llamada
% exclusivamente desde connectsilop. Por ahora usa un fichero de datos fijo, 'rafa.log', que debe pasar a ser configurable.
% 
% Syntax: 
%   simula_muestreo(obj, event);
%
%   Parámetros de entrada:
%		obj y event son los parámetros de la callback
%   Parámetros de salida: Ninguno, modifica la variable global SILOP_DATA_BUFFER
% 
% Examples: 
%   
%
% See also: 

% Author:   Antonio López
% History:  24.01.2008  creado
%           25.01.2008 Incorporado a la toolbox
%


function simula_muestreo(obj, event, log)

persistent puntero_datos;
if (isempty(puntero_datos))
	puntero_datos=1;
end

global SILOP_DATA_BUFFER;
datos = load(log);
longitud = length(datos);
MuestrasCaptura = 100;

%Realiza capturas mientras haya datos, almaceno en el buffer y llamo a funcion SILOP().
%Esta ultima necesita conocer el numero de muestras que se han capturado

if (puntero_datos+MuestrasCaptura < longitud)
     SILOP_DATA_BUFFER = datos(puntero_datos:puntero_datos+MuestrasCaptura-1, :);
     puntero_datos = puntero_datos + MuestrasCaptura;
else
    disp('Se acabaron los datos');
    SILOP_DATA_BUFFER = NaN;
end
