% INICIACAPTURA Comienza la captura de datos
%
% INICIACAPTURA Env�a al dispositivo Xbus Master un mensaje que le obliga
% a comenzar la captura (pasar al modo measurement)
% 
% Syntax: [XBusMaster]=iniciacaptura(XBusMaster)
% 
% Input parameters:
%   XBusMaster-> Objeto con la informaci�n del dispositivo, tal y como se proporciona
%                por creaxbusmaster
%
% Output parameters:
%   XBusMaster- Es el mismo objeto de entrada que puede haber sido
%               modificado durante la llamada.
%
% Examples:
% >> xb=creaxbusmaster('COM24',115200,50,0,1,2);
% >> xb=gotomeasurement(xb);
%
% See also: creaxbusmaster, pararcaptura, continuarcaptura,
%           destruyexbusmaster

% Author:   Diego �lvarez
% History:  18.12.07    creacion del archivo

function XBusMaster=iniciacaptura(XBusMaster)

XBusMaster=gotomeasurement(XBusMaster);

