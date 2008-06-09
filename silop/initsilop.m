% INITSILOP Inicializa el sistema de procesamiento de las aplicaciones estandar de la toolbox
%
% INITSILOP Inicializa el sistema de procesamiento de las aplicaciones estandar de la toolbox. 
% Debe ser el primer comando usado en dichas aplicaciones.
% 
% Syntax: 
%   initsilop();
%
%   Parámetros de entrada: Ninguno
%   Parámetros de salida: Ninguno
% 
% Examples: 
%   
%
% See also: 

% Author:   Antonio López
% History:  24.01.2008  creado
%           24.01.2008 Incorporado a la toolbox
%


function initsilop()

global SILOP_CONFIG
if (~isempty(SILOP_CONFIG))
    if (isstruct(SILOP_CONFIG.BUS.File))
    	SILOP_CONFIG.BUS.File.Salvar=0;
    end
    stopsilop(1);
	SILOP_CONFIG=[];
end

%Tamaño de la ventana de datos
SILOP_CONFIG.GLOBAL.LONGITUDVENTANA = 1000;

%Números de serie y señales iniciales de todos los posibles sensores que se pueden usar
SILOP_CONFIG.SENHALES=[];
SILOP_CONFIG.SENHALES.NUMEROSENHALES = 0;

for sensor={'COG','PIE_IZDO','PIE_DCHO','MUSLO_IZDO','MUSLO_DCHO','TIBIA_IZDA','TIBIA_DCHA'}
for campo={'Serie','Acc_Z','Acc_Y','Acc_X','G_Z','G_Y','G_X','MG_Z','MG_Y','MG_X'}
    SILOP_CONFIG.SENHALES.(sensor{1}).(campo{1})=-1;
end
end


%Datos generales del bus
SILOP_CONFIG.BUS.Xbus = -1;
SILOP_CONFIG.BUS.SF_3D = -1;
SILOP_CONFIG.BUS.SF_6DOF = -1;
SILOP_CONFIG.BUS.Temporizador = -1;
SILOP_CONFIG.BUS.File = -1;

%Datos de los algoritmos usados
SILOP_CONFIG.ALGORITMOS = [];
SILOP_CONFIG.GLOBAL.COLUMNADISPONIBLE = -1;


