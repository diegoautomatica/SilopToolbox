% SETPERIOD Envía el mensaje SetPeriod al objeto XBusMaster
%
% SETPERIOD Envía el mensaje SetPeriod al objeto XBusMaster.
% El proceso se queda bloqueado hasta recibir la informacion
% 
% Syntax: [XBusMaster,error]=SetPeriod(XBusMaster, freq)
% 
% Input parameters:
%   XBusMaster-> Objeto con la información del dispositivo.
%   freq -> Nueva frecuencia, por defecto 100Hz
%
% Output parameters:
%   XBusMaster- Es el mismo objeto de entrada que puede haber sido
%               modificado durante la llamada.
%   error     - 0 si no se produjo ningún error y 1 si no se recibe el mensaje de ACK
%
% Examples:
%
% See also: creaxbusmaster, gotoconfig, pararcaptura, continuarcaptura,
%           destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           18.12.07    pasada a private por Diego.


function [XBusMaster,error]=SetPeriod(XBusMaster,freq)

% Envia el mensaje SetPeriod al objeto XBusMaster
% error vale 1 si no se recibe el mensaje de ACK
% El proceso se queda bloqueado hasta recibir la informacion
% Parametros:
% XBusMaster -> el objeto XBusMaster
% freq -> nueva frecuencia de muestreo (por defecto 100)

if (nargin<2)
    freq=100;
end

% Calcular la frecuencia de muestreo
fm=[fix(115200/freq/256) mod(115200/freq,256)];
% Cuerpo del mensaje (excepto el byte de checksum)
msg=[250,255,4,2,fm];
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
% Se espera a recibir la contestacion
% Se supone que el buffer de entrada esta vacio
msg=[];
[ack,cnt,msg]=fread(XBusMaster.puerto,5,'uint8');
error=0;
if (~isempty(msg))
    disp(msg);
    error=1;
    return;
else
    if (mod(sum(ack(2:end)),256)~=0)
        disp('>>> ERROR -> Error de checksum');
        error=1;
        return;
    else
        if (ack(3)~=5)
            disp('>>> ERROR -> Error en la secuencia de mensajes');
            error=1;
            return;
        end
    end
end
% Se actualiza la configuracion
[XBusMaster,error]=ReqConfiguration(XBusMaster);