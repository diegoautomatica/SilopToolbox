% CREASF3D Crea un objeto SF3D para controlar la captura de
% datos desde el dispositivo Sparkfun 3D
%
% CREASF3D Crea un objeto SF3D para controlar la captura de
% datos desde el dispositivo Sparkfun 3D. El objeto es una
% estructura que contiene informacion sobre el puerto serie utilizado para
% la comunicacion con el dispositivo, asi como de la configuracion del
% propio dispositivo.
% 
% Syntax: sf3d=creaxsf3d(puerto,bps,freq,modo,buffer)
% 
% Input parameters:
%   puerto->  Cadena con el nombre del puerto al que esta conectado el
%             (por defecto '/dev/ttyUSB0')
%   bps->     Velocidad de transferencia (por defecto 9600 bps)
%   freq->    Frecuencia de muestreo (por defecto 100Hz)
%   modo->    Conjunto de datos que va a capturar (por defecto 0)
%             0-> Calibrated (Gravity Data)
%             1-> Raw Data (No soportado luego por la toolbox)
%             2-> Binary (No soportado luego por la toolbox)
%   buffer->  Tamanio del bloque de catpura de datos en segundos (por
%                   defecto 1 seg)
%
% Output parameters:
%   sf3d  - Estructura que almacena toda la informacion relacionada con la
%                 captura de datos desde el dispositivo.
%
% Examples:
% >> sf=creasf3d('/dev/ttyUSB0',9600)
%
% See also:

% Author:   Diego Álvarez

function sf3d=creasf3d(puerto,bps,freq,modo,buffer)

global SILOP_DATA_BUFFER;

% asignamos los valores por defecto de las variables
if (nargin<1)
    puerto='/dev/ttyUSB0';
end
if (nargin<2)
    bps=9600; 
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

sf3d.puerto=serial(puerto);
% Calculamos el numero de muestras almacenadas en el buffer
sf3d.freq=freq;
sf3d.buffer=buffer*freq;

sf3d.modo=modo;
switch (sf3d.modo)
    case 0,
        sf3d.Data=3;
        sf3d.DataLength=29;%bytes de cada mensaje
    case 1,
        error('Modo aun no soportado');
    case 2,
        error('Modo aun no soportado');
    otherwise,
        error('Modo invalido');
end;

sf3d.bps=bps;

% Configurar el objeto serie
sf3d.puerto.BaudRate=bps;
sf3d.puerto.DataBits=8;
sf3d.puerto.FlowControl='none';
sf3d.puerto.Parity='none';
sf3d.puerto.StopBits=1;
sf3d.puerto.ReadAsyncMode = 'continuous';
   
sf3d.puerto.ByteOrder = 'littleEndian';
sf3d.puerto.BytesAvailableFcnCount = sf3d.DataLength*sf3d.buffer;
%SILOP_DATA_BUFFER=zeros(sf3d.puerto.BytesAvailableFcnCount, sf3d.buffer); %#ok<NASGU>
sf3d.puerto.BytesAvailableFcnMode = 'byte';
sf3d.puerto.InputBufferSize = 2*sf3d.DataLength*sf3d.buffer;
sf3d.puerto.OutputBufferSize = 512;
sf3d.puerto.Tag = 'SparkFun_3D';
sf3d.puerto.Timeout = 10;
% Abrir el puerto de comunicaciones
%Tenemos que tener cuidado no dejar el serial en mal estado, porque aún no 
%estamos en condiciones de detener el proceso a alto nivel
try
   fopen(sf3d.puerto);

   % Ir a modo configuracion
   sf3d=driver_SF_3D('gotoconfig',sf3d);
   sf3d=sf3dsetperiod(sf3d);
catch
  s=lasterror();
  disp(s.message);
  delete (sf3d.puerto);
  rethrow(s); 
end

SILOP_DATA_BUFFER=[];
