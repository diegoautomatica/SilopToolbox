% GOTOCONFIG Pasa el dispositivo Xbus Master al estado config
%
% GOTOCONFIG Env�a al dispositivo Xbus Master un mensaje que le obliga
% pasar al modo config. Pueden perderse datos que existan en el buffer de
% entrada.
% 
% Syntax: error=gotoconfig(XBusMaster)
% 
% Input parameters:
%   XBusMaster->  Objeto con la informaci�n del dispositivo.
%
% Output parameters:
%   error  - 0 si no se produjo ning�n error y 1 en caso contrario.
%
% Examples:
% >> xb=creaxbusmaster('COM24',115200,50,0,1,2);
% >> error=gotoconfig(xb);
%
% See also: creaxbusmaster, gotomeasurement, pararcaptura, continuarcaptura,
%           destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           18.12.07    pasada a private por Diego. Se conserva .doc en private-SilopToolbox.doc

function error=gotoconfig(XBusMaster)

% Envia el mensaje GoToConfig al objeto XBusMaster
% error vale 1 si no se recibe el mensaje de ack
% El proceso se queda bloqueado hasta recibir el ack

% Cuerpo del mensaje (excepto el byte de checksum)
msg=[250,255,48,0];
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
%tout=XBusMaster.puerto.TimeOut;
XBusMaster.puerto.TimeOut=1;
fwrite(XBusMaster.puerto,msg,'uint8');
% Se espera a recibir la contestacion
% Se supone que el buffer de entrada esta vacio
%msg=[];
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
        if (ack(3)~=49)
            disp('Error en la secuencia de mensajes');
            error=1;
        end
    end
end
