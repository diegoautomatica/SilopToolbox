% LEERSF3DDATA Lee datos desde el dispositivo Sparkfun 3D
%
% LEERSF3DDATA Lee datos desde el dispositivo Sparkfun 3D. Esta función
% está pensada para ser usada desde una callback, y no directamente desde
% una función/script
% 
% Syntax: leersf3dData(obj,event,sf3d)
% 
% Input parameters:
%     obj 	-> Parámetro 1 de la callback
%     event     -> Parámetro 2 de la callback
%     sf3d-> Objeto con la información del dispositivo.
%
% Output parameters:
%   Ninguno, los datos obtenidos quedan en la variable global SILOP_DATA_BUFFER
%
% Examples:
%
% See also: creasf3d, destruyesf3d, sf3dgotomeasurement

%Lee datos del buffer. Llamada por una callback
function leersf3dData(obj,event,sf3d)  %#ok<INUSL>

global SILOP_DATA_BUFFER;

[data,cnt,msg]=fread(obj,[sf3d.DataLength sf3d.buffer],'uint8');
if (~isempty(msg))
    disp(msg);
    error('error en la lectura de datos');
end
% Procesar los datos de 1 mensaje
if (any(data(2,:)-'X'))
    disp('>>>> ERROR durante la captura de datos');
end
if (any(data(11,:)-'Y'))
    disp('>>>> ERROR durante la captura de datos');
end
if (any(data(20,:)-'Z'))
    disp('>>>> ERROR durante la captura de datos');
end
% procesar la informacion
for k=1:sf3d.buffer
    ax=9.8*str2double(char(data(  4:  9,k)));
    ay=9.8*str2double(char(data(13:18,k)));
    az=9.8*str2double(char(data(22:27,k)));
    SILOP_DATA_BUFFER=[SILOP_DATA_BUFFER; ax ay az]; %#ok<AGROW>
end

disp('leido un segundo de datos');
