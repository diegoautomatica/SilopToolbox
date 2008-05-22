% CONTINUARCAPTURA Reanuda la adquisición de datos tras una llamada a
% pararcaptura
%
% CONTINUARCAPTURA Reanuda la adquisición de datos tras una llamada a
% pararcaptura
% 
% Syntax: XBusMaster=continuarcaptura(XBusMaster)
% 
% Input parameters:
%   XBusMaster-> Objeto con la información del dispositivo.
%
% Output parameters:
%   XBusMaster- Es el mismo objeto de entrada que puede haber sido
%               modificado durante la llamada.
%
% Examples:
% >> xb=creaxbusmaster('COM24',115200,50,0,1,2);
% >> [xb,error]=gotomeasurement(xb);
% >> xb=pararcaptura(xb);
% >> xb=continuarcaptura(xb);
%
% See also: creaxbusmaster, iniciacaptura, continuarcaptura,
%           destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           19.12.07    incorporada a la toolbox

function XBusMaster=continuarcaptura(XBusMaster)

XBusMaster.puerto.RequestToSend='on';
