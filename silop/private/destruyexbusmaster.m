% DESTRUYEXBUSMASTER Destruye el objeto XBusMaster creado por una llamada a
% creaxbusmaster
%
% DESTRUYEXBUSMASTER Destruye el objeto XBusMaster creado por una llamada a
% creaxbusmaster. Cerrando por tanto la conexi�n con el dispositivo  y 
% liberando los puertos serie. No elimina los datos capturados, que se 
% siguen manteniendo en SILOP_DATA_BUFFER
% 
% Syntax: XBusMaster=destruyexbusmaster(XBusMaster)
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
% >> xb=destruyexbusmaster(xb);
%
% See also: creaxbusmaster,  destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           19.12.07    incorporada a la toolbox

function XBusMaster=destruyexbusmaster(xb)

XBusMaster=xb;
try 
	fclose(xb.puerto);
catch
end
delete(XBusMaster.puerto);
clear XBusMaster
XBusMaster=[];
