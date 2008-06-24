% SETMTOUTPUTMODE Envía el mensaje SetOutputMode a todos los dispositivos
%
% SETMTOUTPUTMODE Envia el mensaje SetOutputMode a todos los dispositivos
% conectados al XBusMaster. El proceso se queda bloqueado hasta recibir la informacion

% 
% Syntax: XBusMaster=SetMTOutputMode(XBusMaster, orientformat)
% 
% Input parameters:
%   XBusMaster-> Objeto con la información del dispositivo.
%   orientformat -> formato para recibir los datos de orientacion.
%   		0 -> No se reciben
%   		1 -> Quaternion
%   		2 -> Angulos de Euler
%   		3 -> Matriz de rotacion
%
% Output parameters:
%   XBusMaster- Es el mismo objeto de entrada que puede haber sido
%               modificado durante la llamada.
%
% Examples:
%
% See also: creaxbusmaster, gotoconfig, destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           18.12.07    pasada a private por Diego.


function XBusMaster=SetMTOutputMode(XBusMaster, orientformat)


if (nargin<2)
    orientformat=0;
end

switch (orientformat)
    case 0
        outmode=[0 2];
        outsett=[0 0 0 0];
    case 1
        outmode=[0 6];
        outsett=[0 0 0 0];
    case 2
        outmode=[0 6];
        outsett=[0 0 0 4];
    case 3
        outmode=[0 6];
        outsett=[0 0 0 8];
end

for k=1:XBusMaster.Conf.DevNum
    % Cuerpo del mensaje (excepto el byte de checksum)
    msg=[250,k,208,2,outmode];
    % Se calcula el cheksum y se coloca al final
    msg=[msg 256-mod(sum(msg(2:end)),256)]; %#ok<AGROW>
    % Se envia por el puerto serie 
    if (XBusMaster.puerto.BytesAvailable>0)
        % Vaciar el puerto 
        % OJO!!! Los datos se perderan
        disp(['>>> AVISO: Se descartaran ' int2str(XBusMaster.puerto.BytesAvailable) ' datos']);
        fread(XBusMaster.puerto,XBusMaster.puerto.BytesAvailable,'uint8');
    end
    % El valor del TimeOut se fija a 1 segundo
    %tout=XBusMaster.puerto.TimeOut;
    XBusMaster.puerto.Timeout=1;
    fwrite(XBusMaster.puerto,msg,'uint8','async');
    % Se espera a recibir la contestacion
    % Se supone que el buffer de entrada esta vacio
    % Se espera a recibir la contestacion
    % Se supone que el buffer de entrada esta vacio
    %msg=[];
    [ack,cnt,msg]=fread(XBusMaster.puerto,5,'uint8');
    %error=0;
    if (~isempty(msg))
        error('no se ha recibido respuesta al comando setmtoutputmode');
    else
        if (mod(sum(ack(2:end)),256)~=0)
            error('Error de checksum durante el comando setmtoutputmode');
        else
            if (ack(3)~=209)
                error('Error en la secuencia de mensajes durante el comando setmtoutputmode');
            end
        end
    end
    % Enviar el mensaje SetOutputSettings
    % Cuerpo del mensaje (excepto el byte de checksum)
    msg=[250,k,210,4,outsett];
    % Se calcula el cheksum y se coloca al final
    msg=[msg 256-mod(sum(msg(2:end)),256)]; %#ok<AGROW>
    % Se envia por el puerto serie 
    if (XBusMaster.puerto.BytesAvailable>0)
        % Vaciar el puerto 
        % OJO!!! Los datos se perderan
        disp(['>>> AVISO: Se descartaran ' int2str(XBusMaster.puerto.BytesAvailable) ' datos']);
        fread(XBusMaster.puerto,XBusMaster.puerto.BytesAvailable,'uint8');
    end
    % El valor del TimeOut se fija a 1 segundo
    %tout=XBusMaster.puerto.TimeOut;
    XBusMaster.puerto.Timeout=1;
    fwrite(XBusMaster.puerto,msg,'uint8','async');
    % Se espera a recibir la contestacion
    % Se supone que el buffer de entrada esta vacio
    % Se espera a recibir la contestacion
    % Se supone que el buffer de entrada esta vacio
    %msg=[];
    [ack,cnt,msg]=fread(XBusMaster.puerto,5,'uint8');
    %error=0;
    if (~isempty(msg))
        disp(msg);
        error('no se ha recibido respuesta durante el comando setmtoutputmode');
    else
        if (mod(sum(ack(2:end)),256)~=0)
            error('Error de checksum durante el comando setmtoutputmode');
        else
            if (ack(3)~=211)
                error('Error en la secuencia de mensajes durante el comando setmtoutputmode');
            end
        end
    end
end

% Se actualiza la configuracion
XBusMaster=ReqConfiguration(XBusMaster);
