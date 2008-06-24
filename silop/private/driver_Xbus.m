% DRIVER_Xbus implementa todo el código necesario para el correcto funcionamiento del dispositivo
% Xsens XBus Master y sus dispositovos MTx asociados
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
%
% DRIVER_Xbus implementa todo el código necesario para el correcto funcionamiento del dispositivo
% Xsens XBus Master y sus dispositovos MTx asociados
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
% 
% Syntax: retorno=driver_Xbus(operacion, parametros)
% 
% Output parameters:
%
% Examples:

function retorno=driver_Xbus(operacion,parametros)

    switch operacion
        case 'create'
        case 'connect'
        case 'gotoconfig'
        case 'gotomeasurement'
            retorno=gotomeasurement(parametros);
        case 'destruye'
        otherwise
            disp('error, el driver no soporta la operación indicada');
            retorno=[];
    end
end



%Funcion para el paso a modo medida
function xbus=gotomeasurement(xbus)
    global SILOP_DATA_BUFFER;
    SILOP_DATA_BUFFER=[];

    % Cuerpo del mensaje (excepto el byte de checksum)
    msg=[250,255,16,0];
    % Se calcula el cheksum y se coloca al final
    msg=[msg 256-mod(sum(msg(2:end)),256)];
    % Se envia por el puerto serie 
    if (xbus.puerto.BytesAvailable>0)
        % Vaciar el puerto 
        % OJO!!! Los datos se perderan
        disp(['>>> AVISO: Se descartaran ' int2str(xbus.puerto.BytesAvailable) ' datos']);
        fread(xbus.puerto, xbus.puerto.BytesAvailable,'uint8');
    end
    % El valor del TimeOut se fija a 1 segundo
    xbus.puerto.Timeout=1;
    fwrite(xbus.puerto,msg,'uint8','async');
    % Se espera a recibir la contestacion
    [ack,cnt,msg]=fread(xbus.puerto,5,'uint8');
    if (~isempty(msg))
        disp(msg);
        error('no se ha recibido respuesta al mensaje gotomeasurement');
    elseif (mod(sum(ack(2:end)),256)~=0)
        error('Error de checksum durante el comando gotomeasurement');
    elseif (ack(3)~=17)
                error('Error en la secuencia de mensajes durante el comando gotomeasurement');
    end
    leerXBusDatahandle=@leerXBusData;
    xbus.puerto.BytesAvailableFcn={leerXBusDatahandle, xbus};
end
