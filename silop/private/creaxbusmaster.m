% CREAXBUSMASTER Crea un objeto XbusMaster para controlar la captura de
% datos desde el dispositivo Xbus Master
%
% CREAXBUSMASTER Crea un objeto XbusMaster para controlar la captura de
% datos desde el dispositivo Xbus Master. El objeto XBusMaster es una
% estructura que contiene informaci�n sobre el puerto serie utilizado para
% la comunicaci�n con el dispositivo, as� como de la configuraci�n del
% propio dispositivo.
% 
% Syntax: XBusMaster=creaxbusmaster(puerto,bps,freq,modo,buffer,ns)
% 
% Input parameters:
%   puerto->  Cadena con el nombre del puerto al que est� conectado el
%             XBusMaster (por defecto 'COM24')
%   bps->     Velocidad de transferencia (por defecto 115200 bps)
%   freq->    Frecuencia de muestreo (por defecto 100Hz)
%   modo->    Conjunto de datos que va a capturar (por defecto 0)
%             0-> Calibrated Data
%             1-> Calibrated Data+Quaternion
%             2-> Calibrated Data+RotationMatrix
%   buffer->  Tamanio del bloque de catpura de datos en segundos (por defecto 1 seg)
%   ns->      Numero de sensores conectados (por defecto 1)
%
% Output parameters:
%   XBusMaster  - Estructura que almacena toda la informaci�n relacionada con la
%                 captura de datos desde el dispositivo Xbus Master.
%
% Examples:
% >> xb=creaxbusmaster('COM24',115200,50,0,1,2)
%
% See also: iniciacaptura, pararcaptura, continuarcaptura,
%           destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           18.12.07    incorporada a la toolbox por Diego. Renombrado variable global
%           18.01.08    reset de la variable global al salir
%           12.02.08    modificaciones para las aplicaciones silop

function XBusMaster=creaxbusmaster(puerto,bps,freq,modo,buffer,ns)

global SILOP_DATA_BUFFER;

% asignamos los valores por defecto de las variables
if (nargin<1)
    puerto='COM24';
end
if (nargin<2)
    bps=115200; %460800
end
if (nargin<3)
    freq=100;
end
if (nargin<4)
    modo=0;
end
if (nargin<5)
    buffer=1;
end
if (nargin<6)
    ns=1;
end

% XBusMaster.nm=nm;
XBusMaster.ns=ns;

%Creamos el objeto serial asociado al puerto de comunicaciones
XBusMaster.puerto=serial(puerto);

% Calculamos el numero de muestras almacenadas en el buffer
XBusMaster.freq=freq;
XBusMaster.buffer=buffer*freq;
XBusMaster.nm=XBusMaster.buffer; % Inicialmente estaba previsto que el
                                 % hubiese un buffer con un historico de
                                 % los ultimos datos capturados. En la
                                 % practica ha resultado mas conveniente no
                                 % mantener dicho historico por lo que el
                                 % parametro .nm coincide con .buffer

XBusMaster.modo=modo;
switch (XBusMaster.modo)
    case 0,
        XBusMaster.DataLength=ns*36+2;
        XBusMaster.Data=1+9*ns;
    case 1,
        XBusMaster.DataLength=ns*(36+16)+2;
        XBusMaster.Data=1+(9+4)*ns;
    case 2,
        XBusMaster.DataLength=ns*(36+36)+2;
        XBusMaster.Data=1+(9+9)*ns;
end;

SILOP_DATA_BUFFER=zeros(XBusMaster.buffer,XBusMaster.Data); %#ok<NASGU>

if (XBusMaster.DataLength>254)
    XBusMaster.DataLength=XBusMaster.DataLength+7; % se incluye la cabecera y el checksum
else
    XBusMaster.DataLength=XBusMaster.DataLength+5; % Se incluye la cabecera y el checksum
end

XBusMaster.bps=bps;

% Configurar el objeto serie
XBusMaster.puerto.BaudRate=bps;
XBusMaster.puerto.DataBits=8;
XBusMaster.puerto.FlowControl='none';
XBusMaster.puerto.Parity='none';
XBusMaster.puerto.StopBits=2;
XBusMaster.puerto.ReadAsyncMode = 'continuous';

    
XBusMaster.puerto.ByteOrder = 'littleEndian';
XBusMaster.puerto.BytesAvailableFcnCount = XBusMaster.DataLength*XBusMaster.nm;
SILOP_DATA_BUFFER=zeros(XBusMaster.puerto.BytesAvailableFcnCount,XBusMaster.buffer); %#ok<NASGU>
XBusMaster.puerto.BytesAvailableFcnMode = 'byte';
XBusMaster.puerto.InputBufferSize = XBusMaster.DataLength*100;
XBusMaster.puerto.OutputBufferSize = 512;
XBusMaster.puerto.Tag = 'XBus_Master';
XBusMaster.puerto.Timeout = 10;
% Abrir el puerto de comunicaciones
%Tenemos que tener cuidado no dejar el serial en mal estado, porque aún no 
%estamos en condiciones de detener el proceso a alto nivel
try
   fopen(XBusMaster.puerto);

   % Ir a modo configuracion
   gotoconfig(XBusMaster);
   XBusMaster=InitBus(XBusMaster);
   if (XBusMaster.ndisp~=ns)
      error('SilopToolbox:creaxbusmaster','El numero de sensores conectados es distinto del numero de sensores declarados');
   end

	XBusMaster=ReqConfiguration(XBusMaster);
	XBusMaster=SetPeriod(XBusMaster,XBusMaster.freq);
catch
  s=lasterror();
  disp(s.message);
  delete (XBusMaster.puerto);
  rethrow(s); 
end

switch (modo)
    case 0,
        XBusMaster=SetMTOutputMode(XBusMaster,0);
    case 1,
        XBusMaster=SetMTOutputMode(XBusMaster,1);
    case 2,
        XBusMaster=SetMTOutputMode(XBusMaster,3);
end
SILOP_DATA_BUFFER=[];
