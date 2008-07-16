% SF3DSETPERIOD Fija la frecuencia del dispositivo SF-3D
%
% % SF3DSETPERIOD Fija la frecuencia del dispositivo SF_3D
% 
% Syntax: sf3d=sf3dsetperiod(sf3d)
% 
% Input parameters:  sf3d-> Objeto codinformación del dispositivo.
%
% Output parameters:
%   sf3d-> Es el mismo objeto de entrada que puede haber sido
%               modificado durante la llamada.
%
% Examples:
%
% See also: creasf3d

function sf3d=sf3dsetperiod(sf3d)

freq=sf3d.freq;

if (sf3d.puerto.BytesAvailable>0)
    disp(['>>> AVISO: Se descartaran ' int2str(sf3d.puerto.BytesAvailable) ' datos']);
    fread(sf3d.puerto, sf3d.puerto.BytesAvailable,'uint8');
end
% Cuerpo del mensaje 
msg='3';
fwrite(sf3d.puerto,msg,'uint8','async');
% Se espera a recibir la contestacion
[ack,cnt,msg]=fread(sf3d.puerto,78,'uint8');
if (~isempty(msg))
    disp(msg);
    error('no se ha recibido respuesta al comando setperiod');
end
if (sf3d.puerto.BytesAvailable>0)
    fread(sf3d.puerto, sf3d.puerto.BytesAvailable,'uint8');
end
ack=ack(end-10:end-1);%Me quedo con los 10 penultimos, que se parecen al resto de respuestas
if ack(10)=='H'
    %solo dos cifras
    frecuencia=str2double(char(ack(8:9)));
else
    %tres cifras
    frecuencia=str2double(char(ack(8:10)));
end

while (frecuencia~=freq)
    if (frecuencia>freq)
        msg='-';
    else
        msg='+';
    end
    fwrite(sf3d.puerto,msg,'uint8','async');
    % Se espera a recibir la contestacion
    [ack,cnt,msg]=fread(sf3d.puerto,10,'uint8');
    if (~isempty(msg))
        disp(msg);
        error('no se ha recibido respuesta al comando setperiod');
    end
    if (sf3d.puerto.BytesAvailable>0)
        fread(sf3d.puerto, sf3d.puerto.BytesAvailable,'uint8');
    end
    if ack(8)=='H'
        %solo dos cifras
        frecuencia=str2double(char(ack(6:7)));
    else
        %tres cifras
        frecuencia=str2double(char(ack(6:8)));
    end
end

%Salimos del modo de frecuencia
msg='x';
fwrite(sf3d.puerto,msg,'uint8','async');
[ack,cnt,msg]=fread(sf3d.puerto, 196,'uint8');
if (~isempty(msg))
        disp(msg);
        error('no se ha recibido respuesta al comando setperiod');
end
if (sf3d.puerto.BytesAvailable>0)
        fread(sf3d.puerto, sf3d.puerto.BytesAvailable,'uint8');
end
