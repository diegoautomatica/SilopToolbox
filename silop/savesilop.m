% SAVESILOP Guarda los datos en un fichero de almacenamiento .sl.
%
% SAVESILOP Guarda los datos de un fichero de almacenamiento .sl.
% Los se toman de las variables captura y CONFIG
% 
% Syntax: 
%   savesilop(fichero, config, captura);
%
%   Parámetros de entrada: El nombre del fichero que se tiene que cargar,
%   la estructura de configuración de los datos y los datos capturados.
%   Parámetros de salida:  Ninguno
% 
% Examples: 
% [config,captura]=loadsilop('exterior1.sl');
% orden=[-3,-2,-1];
% Rot=zeros(3,3);
% for k=1:3
%    Rot(k,abs(orden(k)))=sign(orden(k));
% end;
% captura(:,config.SENHALES.COG.Acc_X:config.SENHALES.COG.Acc_Z)=captura(:,config.SENHALES.COG.Acc_X:config.SENHALES.COG.Acc_Z)*Rot';
%
% savesilop('exterior1modificado.sl',config,captura)%   
%
% See also: loadsilop 

% Author:   Diego Álvarez
% History:  13.02.2008  creado
%


function savesilop(fichero,SILOP_CONFIG, captura)

if (nargin<3)
	error('se debe incluir el nombre del fichero, la estruct de configuracion y los datos de captura como parámetros');
end

save ('config.mat','SILOP_CONFIG');
save ('datos.log','captura','-ASCII');
zip(fichero,{'config.mat','datos.log'});
delete ('config.mat');
delete ('datos.log');
movefile ([fichero,'.zip'], fichero, 'f');

