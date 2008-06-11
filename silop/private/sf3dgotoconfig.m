% SF3DGOTOCONFIG Pasa el dispositivo al estado de configuracion
%
% SF3DGOTOCONFIG Envia al dispositivo un mensaje que le obliga
% a pasar al modo de configuracion. Pueden perderse datos que existan en el buffer de
% entrada.
% 
% Syntax: sf3dgotoconfig(sf3d)
% 
% Input parameters:
%   sf3d ->  Objeto con la informacion del dispositivo.
%
% Output parameters: Ninguno
%
% Examples:
% >> xb=creasf3d('COM24',9600);
% >> sf3dgotoconfig(xb);
%
% See also: creasf3d, sf3dgotomeasurement, destruyesf3d

% Author:   Diego Álvarez

function sf3d=sf3dgotoconfig(sf3d)

% Envia el mensaje GoToConfig al objeto XBusMaster
% error vale 1 si no se recibe el mensaje de ack
% El proceso se queda bloqueado hasta recibir el ack

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
    % Vaciar el puerto 
    % OJO!!! Los datos se perderan
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
