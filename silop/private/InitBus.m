% INITBUS Envía el mensaje InitBus al objeto XBusMaster
%
% INITBUS Envía el mensaje InitBus al objeto XBusMaster. El proceso
%         se queda bloqueado hasta recibir la información
% 
% Syntax: [XBusMaster]=InitBus(XBusMaster)
% 
% Input parameters:
%   XBusMaster-> Objeto con la información del dispositivo.
%
% Output parameters:
%   XBusMaster- Es el mismo objeto de entrada que puede haber sido
%               modificado durante la llamada.
%
% Examples:
% >> [xb]=InitBus(xb);
%
% See also: creaxbusmaster, gotoconfig, destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           18.12.07    pasada a private por Diego.

function [XBusMaster]=InitBus(XBusMaster)

% Envia el mensaje InitBus al objeto XBusMaster
% error vale 1 si no se recibe el mensaje con la descripcion
% de los dispositivos conectados
% El proceso se queda bloqueado hasta recibir la informacion

% Cuerpo del mensaje (excepto el byte de checksum)
msg=[250,255,2,0];
% Se calcula el cheksum y se coloca al final
msg=[msg 256-mod(sum(msg(2:end)),256)];
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
%msg=[];
% Primero se leen 4 bytes para concer la longitud total del mensaje
% NOTA: Al no conocer la longitud total de mensaje, si especificamos el
% maximo valor posible, la funcion fread se bloquearia hasta que venciese
% el tout.
[ack1,cnt1,msg]=fread(XBusMaster.puerto,4,'uint8');
if (cnt1<4 || ~isempty(msg))
    disp(msg);
    error('no se ha recibido una respuesta correcta en InitBus');
else
    if (ack1(3)~=3)
        error('Error en la secuencia de mensajes');
    end
end
% de momento no se ha detectado ningun error y se continua con la lectura
% del resto del mensaje ack1(end)+1 bytes
[ack2,cnt2,msg]=fread(XBusMaster.puerto,ack1(end)+1,'uint8');
ack=[ack1; ack2];
if (~isempty(msg))
    disp(msg);
    error('no se ha recibido una respuesta correcta en InitBus');
else
    if (mod(sum(ack(2:end)),256)~=0)
        error('Error de checksum en initbus');
    end
    XBusMaster.ndisp=ack(4)/4;
    XBusMaster.sensores.ID=reshape(ack(5:(end-1)),[4 XBusMaster.ndisp]);
    XBusMaster.sensores.Cadena=reshape(sprintf('%02X',double(ack(5:(end-1)))),[2*4 XBusMaster.ndisp]);
end
