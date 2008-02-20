function error=ResetOrientation(XBusMaster,modo)

% Envia el mensaje ResetOrientation a todos los dispositivos conectados
% error vale 1 si no se recibe el mensaje de ack
% El proceso se queda bloqueado hasta recibir el ack

for k=1:XBusMaster.Conf.DevNum
    % Cuerpo del mensaje (excepto el byte de checksum)
    msg=[250,k,164,2,0,modo];
    % Se calcula el cheksum y se coloca al final
    msg=[msg 256-mod(sum(msg(2:end)),256)];
    % Se envia por el puerto serie 
    XBusMaster.puerto.RequestToSend='off';
    while (XBusMaster.puerto.BytesAvailable>0)
        % Vaciar el puerto 
        % OJO!!! Los datos se perderan
        disp(['>>> AVISO: Se descartaran ' int2str(XBusMaster.puerto.BytesAvailable) ' datos']);
        fread(XBusMaster.puerto,XBusMaster.puerto.BytesAvailable,'uint8');
    end
    % El valor del TimeOut se fija a 1 segundo
    tout=XBusMaster.puerto.TimeOut;
    XBusMaster.puerto.TimeOut=1;
    fwrite(XBusMaster.puerto,msg,'uint8');  
    % Se espera a recibir la contestacion
    % Se supone que el buffer de entrada esta vacio
    msg=[];
    [ack,cnt,msg]=fread(XBusMaster.puerto,5,'uint8');
    error=0;
    if (~isempty(msg))
        disp(msg);
        error=1;
    else
        if (mod(sum(ack(2:end)),256)~=0)
        disp('Error de checksum');
        error=1;
        else
            if (ack(3)~=165)
                disp('Error en la secuencia de mensajes');
                error=1;
            end
        end
    end
end
