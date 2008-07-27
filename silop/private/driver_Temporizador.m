% DRIVER_Temporizador implementa todo el código necesario para el correcto
% funcionamiento de las simulaciones a partir de ficheros de log
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
%
% DRIVER_Temporizador implementa todo el código necesario para el correcto
% funcionamiento de las simulaciones a partir de ficheros de log
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
% 
% Syntax: retorno=driver_Temporizador(operacion, parametros)
% 
% Output parameters:
%
% Examples:

function retorno=driver_Temporizador(operacion,parametros)
global SILOP_DATA_LOG; %#ok<NUSED>

    switch operacion
        case 'create' %parametros: {source, updateeach} 
            retorno=createmporizador(parametros);
        case 'connect'
            retorno=parametros; %NO hace nada. Pero es necesario que exista
        case 'gotoconfig'
            retorno=parametros;
            stop(parametros);
            clear SILOP_DATA_LOG;
            clear simula_muestreo;
        case 'configura'
            retorno=configuratemporizador(parametros);
        case 'gotomeasurement'
            start(parametros);
            retorno=parametros;
        case 'destruye'
            delete(parametros);
            retorno=[];
        otherwise
            disp('error, el driver no soporta la operación indicada');
            retorno=[];
    end
end

function t=createmporizador(parametros)
    existe=dir(parametros{1});
    if ((isempty(existe))&&(~strcmp(parametros{1},'test.log')))
        error('no se encuentra el fichero');
    end
    if ( (~strcmp(parametros{1}(end-3:end),'.log'))&&(~strcmp(parametros{1}(end-4:end),'.tana'))&&(~strcmp(parametros{1}(end-2:end),'.sl')) )
        error('formato de archivo desconocido. Solo se soportan ficheros .log, .tana y .sl');
    end        
    t = timer('TimerFcn', {@simula_muestreo, parametros{1}}, 'Period', parametros{2}, 'ExecutionMode', 'fixedRate');
end

function retorno=configuratemporizador(parametros)
    %Si se toman datos de un .log
    source=parametros{2};
    if (strcmp(source(end-3:end),'.log'))
        conectar_a_log(source);
    %Si se toman datos de un .tana
    elseif (strcmp(source(end-4:end),'.tana'))
        conectar_a_tana(source);
    %Si se toman los datos de un .sl tenemos que comprobar el config de ese fichero
    elseif (strcmp(source(end-2:end),'.sl'))
        conectar_a_sl(source);
    end        
    retorno=parametros{1};%Por ahora no hace nada
end

%Callback que simula la realizaci�n de un muestreo desde los Xsens
function simula_muestreo(obj, event, log) %#ok<INUSD>

    persistent puntero_datos;
    if (isempty(puntero_datos))
        puntero_datos=1;
    end

    global SILOP_DATA_BUFFER;
    global SILOP_DATA_LOG;
    longitud = length(SILOP_DATA_LOG);
    MuestrasCaptura = 100;

    %Realiza capturas mientras haya datos, almaceno en el buffer y llamo a funcion SILOP().
    %Esta ultima necesita conocer el numero de muestras que se han capturado

    if (puntero_datos+MuestrasCaptura < longitud)
        SILOP_DATA_BUFFER = SILOP_DATA_LOG(puntero_datos:puntero_datos+MuestrasCaptura-1, :);
        puntero_datos = puntero_datos + MuestrasCaptura;
    else
        disp('Se acabaron los datos');
        SILOP_DATA_BUFFER = NaN;
    end
end

function []=conectar_a_log(log)
    global SILOP_CONFIG
    global SILOP_DATA_LOG
    
    posiciones=fieldnames(SILOP_CONFIG.SENHALES);
    numerodeimus=length(posiciones)-1;
    if (numerodeimus>1)
        error('Solo se puede tener un IMU en la simulacion desde un .log');
    end
    sensor=2;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_Z = 4;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_Y = 3;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_X = 2;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_Z = 7;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_Y = 6;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_X = 5;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_Z = 10;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_Y = 9;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_X = 8;
    SILOP_CONFIG.SENHALES.NUMEROSENHALES = 10;
	
    SILOP_DATA_LOG=load(log);
    orden=SILOP_CONFIG.SENHALES.COG.R;
    Rot=zeros(3,3);
    for k=1:3
        Rot(k,abs(orden(k)))=sign(orden(k));
    end;
    SILOP_DATA_LOG(:,2:4)=SILOP_DATA_LOG(:,2:4)*Rot';
    SILOP_DATA_LOG(:,5:7)=SILOP_DATA_LOG(:,5:7)*Rot';
    SILOP_DATA_LOG(:,8:10)=SILOP_DATA_LOG(:,8:10)*Rot';
end

function  []=conectar_a_tana(log)
    global SILOP_CONFIG
    global SILOP_DATA_LOG
    posiciones=fieldnames(SILOP_CONFIG.SENHALES);
    numerodeimus=length(posiciones)-1;
    if (numerodeimus>1)
        error('Solo se puede tener un IMU en la simulacion desde un .tana');
    end
    sensor=2;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_Z = 3;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_Y = 2;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_X = 1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_Z = -1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_Y = -1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_X = -1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_Z = -1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_Y = -1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_X = -1;
    SILOP_CONFIG.SENHALES.NUMEROSENHALES = 5; %3 aceleraciones y 2!! tiempos
		
	SILOP_DATA_LOG=load(log); 
end

function  []=conectar_a_sl(log)
    global SILOP_CONFIG
    global SILOP_DATA_LOG
    unzip(log);
    tmp=load('config.mat');
     %Comprobamos que el log tenga los sensores solicitados
    posiciones=fieldnames(SILOP_CONFIG.SENHALES);
    numerodeimus=length(posiciones)-1;
    
    SILOP_CONFIG.SENHALES.NUMEROSENHALES = tmp.SILOP_CONFIG.SENHALES.NUMEROSENHALES;
    for numero=2:numerodeimus+1
        %la segunda condicion es para mantener compatibilidad con ficheros
        %viejos, que tenían -1 en las señales no usadas.
         if  (~isfield(tmp.SILOP_CONFIG.SENHALES, posiciones{numero}) ||  (tmp.SILOP_CONFIG.SENHALES.(posiciones{numero}).Serie==-1  ))
                 error(['no se encuentra el sensor del ',posiciones{numero}]);
         end
             SILOP_CONFIG.SENHALES.(posiciones{numero})= tmp.SILOP_CONFIG.SENHALES.(posiciones{numero});
    end    
     %Ya no necesitamos mas el .mat ni tampoco los resultados de algoritmos previos.
     delete ('config.mat');
     existe=dir('datos_alg.log');
     if (~isempty(existe))
         delete ('datos_alg.log');
     end
      SILOP_DATA_LOG=load('datos.log'); 
     delete ('datos.log');
end
