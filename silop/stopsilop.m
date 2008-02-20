% STOPSILOP Detiene el procesamiento de las señales, así como las comunicaciones con los buses 
% y/o la simulación de los datosacuerdo a los IMUS y algoritmos indicados
%
% STOPSILOP Detiene el procesamiento de las se�ales, as� como las comunicaciones con los buses 
% y/o la simulaci�n de los datos de acuerdo a los IMUS y algoritmos indicados. En el caso de que se 
% est�n generando logs, esta funci�n crea los ficheros .sl definitivos.
% 
% Syntax: 
%   stopsilop(CONFIG);
%
%   Par�metros de entrada: 
%	CONFIG  Estructura de configuraci�n de los sensores y algoritmos de la aplicaci�n	
% 
% Examples: 
%   
%
% See also: 

% Author:   Diego �lvarez
% History:  29.01.2008  creado e Incorporado a la toolbox
%           12.02.2008  a�adida la parte del Xbus por Rafa

function CONFIG=stopsilop(CONFIG)


if (CONFIG.BUS.Temporizador ~= -1)
    stop(CONFIG.BUS.Temporizador);
    clear simula_muestreo;
end;
if (isstruct(CONFIG.BUS.Xbus))
    CONFIG.BUS.Xbus=pararcaptura(CONFIG.BUS.Xbus);
    destruyexbusmaster(CONFIG.BUS.Xbus);
    CONFIG.BUS.Xbus=-1;
end;
if (isstruct(CONFIG.BUS.File))
	if (CONFIG.BUS.File.Salvar==2)
		zip(CONFIG.BUS.File.Name,{'config.mat','datos.log','datos_alg.log'});
		delete ('datos_alg.log');
	else
		zip(CONFIG.BUS.File.Name,{'config.mat','datos.log'});
	end		
	delete ('config.mat');
	delete ('datos.log');
	movefile ([CONFIG.BUS.File.Name,'.zip'], CONFIG.BUS.File.Name);
end
