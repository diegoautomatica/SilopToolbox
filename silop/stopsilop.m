% STOPSILOP Detiene el procesamiento de las señales, así como las comunicaciones con los buses 
% y/o la simulación de los datosacuerdo a los IMUS y algoritmos indicados
%
% STOPSILOP Detiene el procesamiento de las señales, asi como las comunicaciones con los buses 
% y/o la simulacion de los datos de acuerdo a los IMUS y algoritmos indicados. En el caso de que se 
% esten generando logs, esta funcion crea los ficheros .sl definitivos.
% 
% Syntax: 
%   stopsilop(modo);
%
%   Parametros de entrada: 
%       Modo: indica si se debe detener totalmente el sistema (modo=1) o
%               solo la captura y procesamiento de datos (modo=0) en cuyo caso se podría 
%               reiniciar de nuevo con playsilop()
%   Parametros de salida: Ninguno
% 
% Examples: 
%   
%
% See also: 

% Author:   Diego Alvarez
% History:  29.01.2008  creado e Incorporado a la toolbox
%           12.02.2008  añadida la parte del Xbus por Rafa

function stopsilop(modo)

if (nargin<1)
    modo=0;
end

global SILOP_CONFIG
global SILOP_DATA_LOG; %#ok<NUSED>

if (SILOP_CONFIG.BUS.Temporizador ~= -1)
    stop(SILOP_CONFIG.BUS.Temporizador);
    if (modo>0)
        delete(SILOP_CONFIG.BUS.Temporizador);
        SILOP_CONFIG.BUS.Temporizador=-1;
    end
    clear simula_muestreo;
    clear SILOP_DATA_LOG; %Liberamos la memoria del enorme fichero de log.
end;
if (isstruct(SILOP_CONFIG.BUS.Xbus))
    SILOP_CONFIG.BUS.Xbus=pararcaptura(SILOP_CONFIG.BUS.Xbus);
    if (modo>0)
        destruyexbusmaster(SILOP_CONFIG.BUS.Xbus);
        SILOP_CONFIG.BUS.Xbus=-1;
    end
    clear alg_ejes_anatomicos
end;
if (isstruct(SILOP_CONFIG.BUS.File))
    if (SILOP_CONFIG.BUS.File.Salvar>0)
        if (SILOP_CONFIG.BUS.File.Salvar==2)
            zip(SILOP_CONFIG.BUS.File.Name,{'config.mat','datos.log','datos_alg.log'});
            delete ('datos_alg.log');
        else
            zip(SILOP_CONFIG.BUS.File.Name,{'config.mat','datos.log'});
        end		
        delete ('config.mat');
        delete ('datos.log');
        movefile ([SILOP_CONFIG.BUS.File.Name,'.zip'], CONFIG.BUS.File.Name);
    end
end
