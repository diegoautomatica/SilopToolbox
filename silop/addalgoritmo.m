% ADDALGORITMO Añade un algoritmo al sistema de procesamiento de las aplicaciones estandar de la toolbox
%
% ADDALGORITMO añade un algoritmo al sistema de procesamiento de las aplicaciones estandar de la toolbox. 
% No se pueden incluir algoritmos antes de realizar la conexión mediante connectsilop() ni después de 
% iniciarse el procesamiento con silopstart
% 
% Syntax: 
%   CONFIG=addalgoritmo(CONFIG, nombre, n_valores_retorno, senhales, params, dependencias)
%
%   Parámetros de entrada: 
%	CONFIG   -> estructura de configuración de la aplicación antes de añadir el sensor
%	nombre   -> Nombre del algoritmo a usar
%	n_valores_retorno -> Número de datos calculados por el algoritmo
%	senhales -> señales que va a emplear el algoritmo
%	params  -> parametros de configuración del algoritmo
%	dependencias -> señales generadas por otros programas que necesita el algoritmo
%   Parámetros de salida: 
%	CONFIG  Estructura de configuración de la aplicación después de añadir el sensor
% 
% Examples: 
%   
%
% See also: 

% Author:   Antonio López
% History:  24.01.2008  creado
%           25.01.2008 Incorporado a la toolbox
%           01.02.2008 se busca con buscaposiciones{k} y no de {l}. Necesario para dependencias multiples   

function CONFIG = addalgoritmo(conf, nombre, n_valores_retorno, senhales, params, dependencias)

    CONFIG = conf;
    
    col_disp = CONFIG.GLOBAL.COLUMNADISPONIBLE;
    if(col_disp == -1)
        col_disp = CONFIG.SENHALES.NUMEROSENHALES+1;
    end;
    
    alg.nombre = nombre;
    alg.posiciones = col_disp:col_disp+n_valores_retorno-1;
    CONFIG.GLOBAL.COLUMNADISPONIBLE = col_disp+n_valores_retorno;
    
    alg.parametros = params;    
    alg.senhales = senhales;

    if(isempty(dependencias))
        alg.dependencias = {};
    else
        l=length(dependencias);
        alg.dependencias = cell(l, 1);
        for k=1:l
            pos=buscaposiciones(CONFIG, dependencias{k});
            if(isempty(pos))
		warning('No se encuentra la dependencia indicada. Dependencia invalida');
            else
                alg.dependencias{k} = pos;
            end;
        end;
    end;
     
    
    CONFIG.ALGORITMOS = [CONFIG.ALGORITMOS alg];





%%%%Función para localizar un algoritmo.
function posiciones = buscaposiciones(CONFIG, nombre)

    vec = CONFIG.ALGORITMOS;
    if(length(vec))
        k=1;
        while ((k<=length(vec))&&(~strcmp(nombre, vec(k).nombre)))
            k = k+1;
        end;
        if(k<=length(vec))
            posiciones = vec(k).posiciones;
        else
            posiciones = [];
        end;
    else
        warning('No se han creado algoritmos');
    end;
