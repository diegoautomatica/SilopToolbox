% ADDALGORITMO Añade un algoritmo al sistema de procesamiento de las aplicaciones estandar de la toolbox
%
% ADDALGORITMO añade un algoritmo al sistema de procesamiento de las aplicaciones estandar de la toolbox. 
% No se pueden incluir algoritmos antes de realizar la conexión mediante connectsilop() ni después de 
% iniciarse el procesamiento con startsilop
% 
% Syntax: 
%   addalgoritmo(nombre, n_valores_retorno, senhales, params, dependencias)
%
%   Parámetros de entrada: 
%	nombre   -> Nombre del algoritmo a usar
%	n_valores_retorno -> Número de datos calculados por el algoritmo
%	senhales -> Nombre de las señales que va a emplear el algoritmo. Ej: COG.Acc_X
%	params  -> parametros de configuración del algoritmo
%	dependencias -> nombres de otros algoritmos, cuyos resultados son necesarios
%
%   Parámetros de salida: Ninguno
% 
% Examples: 
% addalgoritmo('alg_det_event', 2, {'COG.Acc_Z', 'COG.Acc_X'}, [], {});
% addalgoritmo('alg_est_dist_pendulo' , 1, {'COG.Acc_Z'}, [], {'alg_det_event'});
% addalgoritmo('alg_est_orient_gyro', 1, {'COG.G_Z'}, [], {});
% addalgoritmo('alg_est_2d', 2, [], [], {'alg_est_dist_pendulo'  'alg_est_orient_gyro'});
% addalgoritmo('alg_plot_pos2d', 0, [], [], {'alg_est_2d'});
%   
% See also: 

% Author:   Antonio López
% History:  24.01.2008  creado
%           25.01.2008 Incorporado a la toolbox
%           01.02.2008 se busca con buscaposiciones{k} y no de {l}. Necesario para dependencias multiples   

function addalgoritmo(nombre, retornos, senhales, params, dependencias)

    global SILOP_CONFIG;
    
    
    if (isnumeric(retornos))
        n_valores_retorno=retornos;
    else 
        n_valores_retorno=0;
        if (~isempty(retornos))
            if (~iscell(retornos))
                error('la lista de señales retornadas debe ser un cell array')
            end
            for senhal=retornos
                [punto,dato]=strtok(senhal{1},'.'); %Rompo por el punto
                dato=dato(2:end); %Quito el punto
                if (isfield(SILOP_CONFIG.SENHALES,punto))
                    if (isfield(SILOP_CONFIG.SENHALES.(punto),dato))
                       error('La señal %s del %s ya existe',dato,punto);
                    end
                end
                %Falta añadir las señales en SILOP_CONFIG.SENHALES
                % y reservar sus posiciones
                n_valores_retorno=nvalores_retorno+1;
            end
        end
    end
    
    alg.senhales=[];
    if (~isempty(senhales))
        if (~iscell(senhales))
            error('la lista de señales debe ser un cell array')
        end
        for senhal=senhales
            [punto,dato]=strtok(senhal{1},'.'); %Rompo por el punto
            dato=dato(2:end); %Quito el punto
            if (~isfield(SILOP_CONFIG.SENHALES,punto))
                error('No existe el punto %s especificado',punto);
            end
            if (~isfield(SILOP_CONFIG.SENHALES.(punto),dato))
                error('No existe el dato %s solicitado en %s',dato,punto);
            end
            alg.senhales=[alg.senhales SILOP_CONFIG.SENHALES.(punto).(dato)];
        end
    end
    
    alg.parametros = params;    
    
    if(isempty(dependencias))
        alg.dependencias = {};
    else
        l=length(dependencias);
        alg.dependencias = cell(l, 1);
        for k=1:l
            pos=buscaposiciones(SILOP_CONFIG, dependencias{k});
            if(isempty(pos))
                error('No se encuentra la dependencia %s indicada',dependencias{k});
            else
                alg.dependencias{k} = pos;
            end;
        end;
    end;
     
    %Muevo esto al final, hasta que ya se que los datos están bien
    col_disp = SILOP_CONFIG.GLOBAL.COLUMNADISPONIBLE;
    if(col_disp == -1)
        col_disp = SILOP_CONFIG.SENHALES.NUMEROSENHALES+1;
    end;
    
    alg.nombre = nombre;
    
    alg.posiciones = col_disp:col_disp+n_valores_retorno-1;
    SILOP_CONFIG.GLOBAL.COLUMNADISPONIBLE = col_disp+n_valores_retorno;
    
    SILOP_CONFIG.ALGORITMOS = [SILOP_CONFIG.ALGORITMOS alg];





%%%%Función para localizar un algoritmo.
function posiciones = buscaposiciones(CONFIG, nombre)

    vec = CONFIG.ALGORITMOS;
    if(~isempty(vec))
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
        error('Aún no existe ningún algoritmo del que depender');
    end;
