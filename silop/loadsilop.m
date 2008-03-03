% LOADSILOP Carga los datos de un fichero de almacenamiento .sl.
%
% LOADSILOP Carga los datos de un fichero de almacenamiento .sl.
% Los datos quedan disponibles en las variables captura y CONFIG
% 
% Syntax: 
%   [CONFIG,captura]=loadsilop(fichero);
%
%   Parámetros de entrada: El nombre del fichero que se tiene que cargar.
%   Parámetros de salida:  
%	    CONFIG:  Estructura de configuración de los sensores y algoritmos de la aplicación.	
%       captura: Matriz con los datos capturados por los sensores y los resultados de los algoritmos(si están
%		       disponibles en el fichero)
% 
% Examples: 
%   
%
% See also: 

% Author:   Diego Álvarez
% History:  13.02.2008  creado
%


function [Config, captura] = loadsilop(fichero)

if (nargin<1)
	error('se debe incluir el nombre del fichero como parámetro');
end

existe=dir(fichero);
if (isempty(existe))
	error('no se encuentra el fichero');
end

unzip(fichero);
tmp=load('config.mat');
Config=tmp.SILOP_CONFIG;
delete ('config.mat');
load('datos.log'); 
delete ('datos.log');
existe=dir('datos_alg.log');
datos_alg=[];
if (~isempty(existe))
    load('datos_alg.log');
    delete ('datos_alg.log');
end
captura=[datos,datos_alg];



