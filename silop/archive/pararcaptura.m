% PARARCAPTURA Detiene la adquisici�n de datos, pero mantiene el equipo
% listo para reiniciar la captura
%
% PARARCAPTURA Detiene la adquisici�n de datos, pero mantiene el equipo
% listo para reiniciar la captura
% 
% Syntax: XBusMaster=pararcaptura(XBusMaster)
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
% >> xb=pararcaptura(xb);
%
% See also: creaxbusmaster, iniciacaptura, continuarcaptura,
%           destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           19.12.07    incorporada a la toolbox

function XBusMaster=pararcaptura(XBusMaster)

stopasync(XBusMaster.puerto) %Esto no tendría que deshacerse en continuarcaptura?
XBusMaster.puerto.RequestToSend='off';
