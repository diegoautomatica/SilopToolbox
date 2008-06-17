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

%Limpiamos todo lo que puede quedar en el buffer de medidas anteriores
sf3d.puerto.Timeout=1;
while (sf3d.puerto.BytesAvailable>0)
    % Vaciar el puerto 
    % OJO!!! Los datos se perderan
    disp(['>>> AVISO: Se descartaran ' int2str(sf3d.puerto.BytesAvailable) ' datos']);
    fread(sf3d.puerto, sf3d.puerto.BytesAvailable,'uint8');
end

% Envia el mensaje de paso a config. Codigo hexadecimal 13
% Cuerpo del mensaje
msg=[hex2dec('13')]; %#ok<NBRAK>
% Se envia por el puerto serie 
fwrite(sf3d.puerto,msg,'uint8','async');
pause(1);
%Ya deberiamos estar en modo config.
%comprobamos la respuesta.
[ack,cnt,msg]=fread(sf3d.puerto, sf3d.puerto.BytesAvailable, 'uint8');
if (~isempty(msg))
    error('no se ha recibido la respuesta al comando gotoconfig');
else
    if (sum(ack(end-11:end))~=859)
        error('Error de checksum durante gotoconfig');
    end
end
