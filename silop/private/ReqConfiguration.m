% REQCONFIGURATION Envía el mensaje RequestConfiguration al objeto XBusMaster
%
% REQCONFIGURATION Envía el mensaje RequestConfiguration al objeto XBusMaster. El proceso
%         se queda bloqueado hasta recibir la información
% 
% Syntax: [XBusMaster,error]=ReqConfiguration(XBusMaster)
% 
% Input parameters:
%   XBusMaster-> Objeto con la información del dispositivo.
%
% Output parameters:
%   XBusMaster- Es el mismo objeto de entrada que puede haber sido
%               modificado durante la llamada.
%   error     - 0 si no se produjo ningún error y 1 en caso contrario.
%               si no se recibe el mensaje con la descripción de los dispositivos
%               conectados
%
% Examples:
% >> [xb,error]=ReqConfiguration(xb);
%
% See also: creaxbusmaster, gotoconfig, pararcaptura, continuarcaptura,
%           destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           18.12.07    pasada a private por Diego.


function [XBusMaster,error]=ReqConfiguration(XBusMaster)

% Envia el mensaje InitBus al objeto XBusMaster
% error vale 1 si no se recibe el mensaje con la descripcion
% de los dispositivos conectados
% El proceso se queda bloqueado hasta recibir la informacion

% Cuerpo del mensaje (excepto el byte de checksum)
msg=[250,255,12,0];
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
tout=XBusMaster.puerto.TimeOut;
XBusMaster.puerto.TimeOut=1;
fwrite(XBusMaster.puerto,msg,'uint8');
% Se espera a recibir la contestacion
% Se supone que el buffer de entrada esta vacio
msg=[];
% Primero se leen 4 bytes para concer la longitud total del mensaje
% NOTA: Al no conocer la longitud total de mensaje, si especificamos el
% maximo valor posible, la funcion fread se bloquearia hasta que venciese
% el tout.
[ack1,cnt1,msg]=fread(XBusMaster.puerto,4,'uint8');
if (cnt1<4 || ~isempty(msg))
    error=1;
    disp(msg);
    return;
else
    if (ack1(3)~=13)
        disp('Error en la secuencia de mensajes');
        error=1;
        return;
    end
end
error=0;
% de momento no se ha detectado ningun error y se continua con la lectura
% del resto del mensaje ack1(end)+1 bytes
[ack2,cnt2,msg]=fread(XBusMaster.puerto,ack1(end)+1,'uint8');
ack=[ack1; ack2];
if (~isempty(msg))
    disp(msg);
    error=1;
    return;
else
    if (mod(sum(ack(2:end)),256)~=0)
        disp('Error de checksum');
        error=1;
        return;
    end
    % XBusMaster.Configuracion=ack(5:(end-1));
    XBusMaster.Conf.MDID=ack(5:8);
    XBusMaster.Conf.SampPeriod=115200/([256 1]*ack(9:10));
    XBusMarter.Conf.OutputSkipFactor=[256 1]*ack(11:12);
    XBusMaster.Conf.SyncMode=[256 1]*ack(13:14);
    XBusMaster.Conf.SyncSkipFactor=[256 1]*ack(15:16);
    XBusMaster.Conf.SyncOffset=(256.^[3 2 1 0])*ack(17:20);
    XBusMaster.Conf.Date.Year=(10.^[3 2 1 0])*ack(21:24);
    XBusMaster.Conf.Date.Month=(10.^[1 0])*ack(25:26);
    XBusMaster.Conf.Date.Day=(10.^[1 0])*ack(27:28);
    XBusMaster.Conf.Time.Hour=[10 1]*ack(29:30);
    XBusMaster.Conf.Time.Min=[10 1]*ack(31:32);
    XBusMaster.Conf.Time.Sec=[10 1]*ack(33:34);
    XBusMaster.Conf.Time.CS=[10 1]*ack(35:36);
    XBusMaster.Conf.DevNum=[256 1]*ack(101:102);
    for k=1:(XBusMaster.Conf.DevNum)
        base=103+20*(k-1)-1;
        XBusMaster.Conf.Dev(k).ID=ack(base+(1:4));
        XBusMaster.Conf.Dev(k).DataLength=[256 1]*ack(base+(5:6));
        XBusMaster.Conf.Dev(k).OutputMode=[256 1]*ack(base+(7:8));
        XBusMaster.Conf.Dev(k).OutputSettings=[256 1]*ack(base+(9:10));
    end
end
