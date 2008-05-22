% GOTOMEASUREMENT Pasa el dispositivo Xbus Master al estado measurement
%
% GOTOMEASUREMENT Env�a al dispositivo Xbus Master un mensaje que le obliga
% a pasar al modo measurement
% 
% Syntax: XBusMaster=gotomeasurement(XBusMaster)
% 
% Input parameters:
%   XBusMaster-> Objeto con la informaci�n del dispositivo.
%
% Output parameters:
%   XBusMaster- Es el mismo objeto de entrada que puede haber sido
%               modificado durante la llamada.
%
% Examples:
% >> xb=creaxbusmaster('COM24',115200,50,0,1,2);
% >> xb=gotomeasurement(xb);
%
% See also: creaxbusmaster, gotoconfig, pararcaptura, continuarcaptura,
%           destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           18.12.07    pasada a private por Diego. Se conserva .doc en private-SilopToolbox.doc

function XBusMaster=gotomeasurement(XBusMaster)

global SILOP_DATA_BUFFER;

SILOP_DATA_BUFFER=zeros(XBusMaster.buffer,XBusMaster.Data);




% El proceso se queda bloqueado hasta recibir el ack

% Cuerpo del mensaje (excepto el byte de checksum)
msg=[250,255,16,0];
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
[ack,cnt,msg]=fread(XBusMaster.puerto,5,'uint8');
if (~isempty(msg))
    disp(msg);
    error('no se ha recibido respuesta al mensaje gotomeasurement');
else
    if (mod(sum(ack(2:end)),256)~=0)
        error('Error de checksum durante el comando gotomeasurement');
    else
        if (ack(3)~=17)
            error('Error en la secuencia de mensajes durante el comando gotomeasurement');
        end
    end
end
%bytes=(2+XBusMaster.Conf.Dev(1).DataLength*XBusMaster.Conf.DevNum);
%if (bytes>254)
%    bytes=bytes+6+1;
%else
%    bytes=bytes+4+1;
%end
% XBusMaster.puerto.BytesAvailableFcnCount=bytes;
leerXBusDatahandle=@leerXBusData;
XBusMaster.puerto.BytesAvailableFcn={leerXBusDatahandle, XBusMaster};
