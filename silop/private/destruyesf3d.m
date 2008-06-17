% DESTRUYESF3D Destruye el objeto Sparkfun 3D creado por una llamada a
% creasf3d
%
% DESTRUYESF3D Destruye el objeto Sparklfun 3D creado por una llamada a
% creasf3d. Cerrando por tanto la conexioon con el dispositivo  y 
% liberando los puertos serie. No elimina los datos capturados, que se 
% siguen manteniendo en SILOP_DATA_BUFFER
% 
% Syntax: sf3d=destruyesf3d(sf3d)
% 
% Input parameters:
%   sf3d-> Objeto con la informacion del dispositivo.
%
% Output parameters:
%   sf3d- Es el mismo objeto de entrada que habra sido
%               modificado durante la llamada.
%
% Examples:
% >> sf=creasf3d('COM24',57600,50);
% >> sf=sf3dgotomeasurement(sf);
% >> sf=destruyesf3d(sf);
%
% See also: creasf3d, destruyesf3d

function sf3d=destruyesf3d(sf3d)

try 
	fclose(sf3d.puerto);
catch
end
delete(sf3d.puerto);
clear sf3d
sf3d=[];
