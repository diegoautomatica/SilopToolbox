% SF3DGOTOMEASUREMENT Pasa el dispositivo Sparkfun 3D al estado measurement
%
% SF3DGOTOMEASUREMENT Envia al dispositivo Sparkfun 3D un mensaje que le obliga
% a pasar al modo measurement
% 
% Syntax: sf3d=sf3dgotomeasurement(sf3d)
% 
% Input parameters:
%   sf3d-> Objeto con la informacion del dispositivo.
%
% Output parameters:
%   sf3d- Es el mismo objeto de entrada que puede haber sido
%               modificado durante la llamada.
%
% Examples:
% >> xb=creasf3d('COM24',9600,50);
% >> xb=sf3dgotomeasurement(xb);
%
% See also: creasf3d, sf3dgotoconfig, destruyesf3d

function sf3d=sf3dgotomeasurement(sf3d)

global SILOP_DATA_BUFFER;

SILOP_DATA_BUFFER=[];

% Cuerpo del mensaje (excepto el byte de checksum)
msg='x';
% Se envia por el puerto serie 
if (sf3d.puerto.BytesAvailable>0)
    % OJO!!! Los datos se perderan
    disp(['>>> AVISO: Se descartaran ' int2str(sf3d.puerto.BytesAvailable) ' datos']);
    fread(sf3d.puerto,sf3d.puerto.BytesAvailable,'uint8');
end
% El valor del TimeOut se fija a 2 segundos. si llegamos a el será debido a
% un error
sf3d.puerto.Timeout=2;
fwrite(sf3d.puerto,msg,'uint8','async');
leersf3dDatahandle=@leersf3dData;
sf3d.puerto.BytesAvailableFcn={leersf3dDatahandle, sf3d};
