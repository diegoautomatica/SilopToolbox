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
            retorno=gotoconfig(parametros);
        case 'gotomeasurement'
            retorno=gotomeasurement(parametros);
        case 'destruye'
            retorno=[];
            destruyexbusmaster(parametros);
        otherwise
            disp('error, el driver no soporta la operación indicada');
            retorno=[];
    end
end

function XBusMaster=destruyexbusmaster(xb)

    XBusMaster=xb;
    try 
        fclose(xb.puerto);
    catch %#ok<CTCH>
    end
    delete(XBusMaster.puerto);
    clear XBusMaster
    XBusMaster=[];
end

function XBusMaster=gotoconfig(XBusMaster)

    % Envia el mensaje GoToConfig al objeto XBusMaster
    % Cuerpo del mensaje (excepto el byte de checksum)
    msg=[250,255,48,0];
    % Se calcula el cheksum y se coloca al final
    msg=[msg 256-mod(sum(msg(2:end)),256)];
    % Se envia por el puerto serie 
    fwrite(XBusMaster.puerto,msg,'uint8','async');

    %Ya deberiamos estar en modo config.
    %Permitimos comunicaciones
    XBusMaster.puerto.RequestToSend='on';
    %y damos tiempo a que se termine cualquier trasmision en curso
    pause(1);

    %Limpiamos todo lo que puede quedar en el buffer de medidas anteriores
    XBusMaster.puerto.Timeout=10;
    while (XBusMaster.puerto.BytesAvailable>0)
        disp(['>>> AVISO: Se descartaran ' int2str(XBusMaster.puerto.BytesAvailable) ' datos']);
        fread(XBusMaster.puerto,XBusMaster.puerto.BytesAvailable,'uint8');
    end

    %Reenviamos el mensaje y esta vez comprobamos la respuesta.
    fwrite(XBusMaster.puerto,msg,'uint8','async');
    % Se espera a recibir la contestacion
    [ack,cnt,msg]=fread(XBusMaster.puerto,5,'uint8');
    if (~isempty(msg))
        error('no se ha recibido la respuesta al comando gotoconfig');
    else
        if (mod(sum(ack(2:end)),256)~=0)
            error('Error de checksum durante gotoconfig');
        else
            if (ack(3)~=49)
                error ('mensaje incorrecto recibido durante gotoconfig');
            end
        end
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


% LEERXBUSDATA Lee datos desde el dispositivo Xbus Master
%Lee datos del buffer. Llamada por una callback
function leerXBusData(obj,event,XBusMaster) %#ok<INUSL>
    global SILOP_DATA_BUFFER;

    data=fread(obj,[XBusMaster.DataLength XBusMaster.nm],'uint8');
    % Procesar los datos de 1 mensaje
    %checksum
    if (any(mod(sum(data(2:end,:)),256)) )
        disp('>>>> ERROR de checksum durante la captura de datos');
    end
    % tipo de mensaje
    if (any(data(3,:)-50))
        disp('>>>> ERROR de tipo de mensaje durante la captura de datos');
    end
    % procesar la informacion
    muestra=([256 1]*data(5:6,:))';
    q=quantizer('Mode','single');
    SILOP_DATA_BUFFER=[];
    for k=1:XBusMaster.ns
        ax=hex2num(q,reshape(sprintf('%02X',data((7:10)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        ay=hex2num(q,reshape(sprintf('%02X',data((11:14)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        az=hex2num(q,reshape(sprintf('%02X',data((15:18)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        rx=hex2num(q,reshape(sprintf('%02X',data((19:22)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        ry=hex2num(q,reshape(sprintf('%02X',data((23:26)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        rz=hex2num(q,reshape(sprintf('%02X',data((27:30)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        mx=hex2num(q,reshape(sprintf('%02X',data((31:34)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        my=hex2num(q,reshape(sprintf('%02X',data((35:38)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        mz=hex2num(q,reshape(sprintf('%02X',data((39:42)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        SILOP_DATA_BUFFER=[SILOP_DATA_BUFFER ax ay az rx ry rz mx my mz]; %#ok<AGROW>
    end
    SILOP_DATA_BUFFER=[muestra SILOP_DATA_BUFFER];
    disp(['leidos ' num2str([muestra(1) muestra(end)])])
end

