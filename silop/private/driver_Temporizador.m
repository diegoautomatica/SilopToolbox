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
    t = timer('TimerFcn', {@simula_muestreo, parametros(1)}, 'Period', parametros(2), 'ExecutionMode', 'fixedRate');
end

function retorno=configuratemporizador(parametros)
    retorno=parametros;%Por ahora no hace nada
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