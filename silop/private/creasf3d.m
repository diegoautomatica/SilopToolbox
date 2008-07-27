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

function sf3d=creasf3d(freq,buffer,sf3d)

global SILOP_DATA_BUFFER;

% Calculamos el numero de muestras almacenadas en el buffer
sf3d.freq=freq;
sf3d.buffer=buffer*freq;

% Configurar el objeto serie
sf3d.puerto.BaudRate=sf3d.bps;
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
