% STOPSILOP Detiene el procesamiento de las seÃ±ales, asÃ­ como las comunicaciones con los buses 
% y/o la simulaciÃ³n de los datosacuerdo a los IMUS y algoritmos indicados
%
% STOPSILOP Detiene el procesamiento de las señales, así como las comunicaciones con los buses 
% y/o la simulación de los datos de acuerdo a los IMUS y algoritmos indicados. En el caso de que se 
% estén generando logs, esta función crea los ficheros .sl definitivos.
% 
% Syntax: 
%   stopsilop(CONFIG);
%
%   Parámetros de entrada: 
%	CONFIG  Estructura de configuración de los sensores y algoritmos de la aplicación	
% 
% Examples: 
%   
%
% See also: 

% Author:   Diego Álvarez
% History:  29.01.2008  creado e Incorporado a la toolbox
%           12.02.2008  añadida la parte del Xbus por Rafa

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
