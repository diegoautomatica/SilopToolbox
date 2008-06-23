% CONNECTSILOP Conecta el sistema de procesamiento con los sensores previamente especificados
%
% CONNECTSILOP Conecta el sistema de procesamiento con los sensores
% previamente especificados, o en el caso de trabajar
% en modo simulacion con el fichero en el que esta guardado un log capturado por los XSens
% 
% Syntax: 
%   connectsilop(modo, source, bps, freq, modo, buffer)
%
%   Parametros de entrada:
%		modo:  Parametro que indica el modo de funcionamiento
%               0:   sensor xbus (por defecto)
%               1:   simulacion
%               2:   SparkFun 3D
%       source     Fichero del que leer los datos(en simulacion) o puerto serie al que conectar(en RT)
%                        valor por defecto: 'test.log' o 'COM24' por defecto(respectivamente). 
%                        El fichero para la simulacion  puede se un .log de Xsens, un .tana de Xsens
%			             calibrado, o un .sl de la propia toolbox
%       bps        Velocidad a la que conectarse 460800bps por defecto
%		freq       Frecuencia de muestreo. 100Hz por defecto
%       modo	   Conjunto de datos a capturar si se usa el xbus o el sf3d (por defecto callibrated) 
%       buffer     Tamanho (en segundos) del buffer de datos
%
%   Parametros de salida: Ninguno 
% 
% Examples: 
%   
%
% See also: 

% Author:   Antonio Lopez
% History:  24.01.2008  creado
%           24.01.2008 Incorporado a la toolbox
%           20.02.2008 modificaciones de Rafa para la conexion al xbusmaster
%           21.02.2008 Modificaciones de diego para simular desde .sl y .tana+comprobar que solo se use el cog en .log
%           21.02.2008 Pruebas iniciales de reorientacion de los datos. s�lo para R positiva

function connectsilop(modo_simulacion, log, bps, freq, modo, buffer)
    
    if (nargin<1)
        modo_simulacion=0; 
    end	
    
    global SILOP_DATA_BUFFER;
    SILOP_DATA_BUFFER = [];
    global SILOP_CONFIG;
    
    %Comprobamos si existen señales
    posiciones=fieldnames(SILOP_CONFIG.SENHALES);
    numerodeimus=length(posiciones)-1;
    if (numerodeimus==0)
        error('no se ha indicado ningún IMU mediante addimu');
    end
    
    if(modo_simulacion==1)
        if (nargin<2)
            log='test.log';
        else 
            existe=dir(log);
            if (isempty(existe))
                error('no se encuentra el fichero');
            end	
        end
        %Si se toman datos de un .log
        if (strcmp(log(end-3:end),'.log'))
            conectar_a_log(log);
        %Si se toman datos de un .tana
        elseif (strcmp(log(end-4:end),'.tana'))
            conectar_a_tana(log);
        %Si se toman los datos de un .sl tenemos que comprobar el config de ese fichero
        elseif (strcmp(log(end-2:end),'.sl'))
            conectar_a_sl(log);
        else error('formato de archivo desconocido. Solo se soportan ficheros .log, .tana y .sl');
        end        
        t = timer('TimerFcn', {@simula_muestreo, log}, 'Period', 1.0, 'ExecutionMode', 'fixedRate');
        SILOP_CONFIG.BUS.Temporizador = t;
         
    elseif (modo_simulacion==0)
        if (nargin<2)
            puerto='COM24';
        else
            puerto=log;
        end
        if (nargin<3)
            bps=460800;
        end
        if (nargin<4)
            freq=100;
        end
        if (nargin<5)
            modo=0;
        end
        if (nargin<6)
            buffer=1;
        end

        conectar_a_xbus(puerto, bps, freq, modo, buffer);
    elseif (modo_simulacion==2)
        if (nargin<2)
            puerto='COM24';
        else
            puerto=log;
        end
        if (nargin<3)
            bps=9600;
        end
        if (nargin<4)
            freq=100;
        end
        if (nargin<5)
            modo=0;
        end
        if (nargin<6)
            buffer=1;
        end
        conectar_a_SF_3D(puerto, bps, freq, modo, buffer);
    else
        error('modo de funcionamiento no soportado');
    end
end




function []=conectar_a_log(log)
    global SILOP_CONFIG
    global SILOP_DATA_LOG
    
    posiciones=fieldnames(SILOP_CONFIG.SENHALES);
    numerodeimus=length(posiciones)-1;
    if (numerodeimus>1)
        error('Solo se puede tener un IMU en la simulacion desde un .log');
    end
    sensor=2;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_Z = 4;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_Y = 3;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_X = 2;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_Z = 7;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_Y = 6;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_X = 5;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_Z = 10;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_Y = 9;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_X = 8;
    SILOP_CONFIG.SENHALES.NUMEROSENHALES = 10;
	
    SILOP_DATA_LOG=load(log);
    orden=SILOP_CONFIG.SENHALES.COG.R;
    Rot=zeros(3,3);
    for k=1:3
        Rot(k,abs(orden(k)))=sign(orden(k));
    end;
    SILOP_DATA_LOG(:,2:4)=SILOP_DATA_LOG(:,2:4)*Rot';
    SILOP_DATA_LOG(:,5:7)=SILOP_DATA_LOG(:,5:7)*Rot';
    SILOP_DATA_LOG(:,8:10)=SILOP_DATA_LOG(:,8:10)*Rot';
end

function  []=conectar_a_tana(log)
    global SILOP_CONFIG
    global SILOP_DATA_LOG
    posiciones=fieldnames(SILOP_CONFIG.SENHALES);
    numerodeimus=length(posiciones)-1;
    if (numerodeimus>1)
        error('Solo se puede tener un IMU en la simulacion desde un .tana');
    end
    sensor=2;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_Z = 3;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_Y = 2;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).Acc_X = 1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_Z = -1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_Y = -1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).G_X = -1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_Z = -1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_Y = -1;
    SILOP_CONFIG.SENHALES.(posiciones{sensor}).MG_X = -1;
    SILOP_CONFIG.SENHALES.NUMEROSENHALES = 5; %3 aceleraciones y 2!! tiempos
		
	SILOP_DATA_LOG=load(log); 
end

function  []=conectar_a_sl(log)
    global SILOP_CONFIG
    global SILOP_DATA_LOG
    unzip(log);
    tmp=load('config.mat');
     %Comprobamos que el log tenga los sensores solicitados
    posiciones=fieldnames(SILOP_CONFIG.SENHALES);
    numerodeimus=length(posiciones)-1;
    
    SILOP_CONFIG.SENHALES.NUMEROSENHALES = tmp.SILOP_CONFIG.SENHALES.NUMEROSENHALES;
    for numero=2:numerodeimus+1
        %la segunda condicion es para mantener compatibilidad con ficheros
        %viejos, que tenían -1 en las señales no usadas.
         if  (~isfield(tmp.SILOP_CONFIG.SENHALES, posiciones{numero}) ||  (tmp.SILOP_CONFIG.SENHALES.(posiciones{numero}).Serie==-1  ))
                 error(['no se encuentra el sensor del ',posiciones{numero}]);
         end
             SILOP_CONFIG.SENHALES.(posiciones{numero})= tmp.SILOP_CONFIG.SENHALES.(posiciones{numero});
    end    
     %Ya no necesitamos mas el .mat ni tampoco los resultados de algoritmos previos.
     delete ('config.mat');
     existe=dir('datos_alg.log');
     if (~isempty(existe))
         delete ('datos_alg.log');
     end
      SILOP_DATA_LOG=load('datos.log'); 
     delete ('datos.log');
end



function conectar_a_xbus(puerto, bps, freq, modo, buffer)
        global SILOP_CONFIG
        
        % Calcular el numero de dispositivos por defecto
        posiciones=fieldnames(SILOP_CONFIG.SENHALES);
        ns=length(posiciones)-1;
                        
        % Crear el objeto xbusmaster
        try 
           xbus=creaxbusmaster(puerto,bps,freq,modo,buffer,ns);
        catch
            rethrow (lasterror());
        end
        SILOP_CONFIG.BUS.Xbus=xbus;
        
        % Actualizar los valores de las se�ales
        switch (xbus.modo)
            case 0,
                factor=9; %#ok<NASGU>
            case 1,
                factor=9+4; %#ok<NASGU>
            case 2,
                factor=9+9; %#ok<NASGU>
        end;
        
        % Identificar sensores y asignar los valores de las columnas
        % correspondientes
        id_disp=zeros(1,xbus.ndisp);
        for k=1:xbus.ndisp
            id_disp(k)=eval(xbus.sensores.Cadena(:,k));
        end
    
        try
            for numero=2:ns+1
                %Buscamos el dispositivo en cada punto
                p=(find(id_disp==SILOP_CONFIG.SENHALES.(posiciones{numero}).Serie));
                if (isempty(p))
                    error('SilopToolbox:connectsilop',['El numero de serie del sensor asignado al ',posiciones{numero},' no ha sido encontrado']);
                else
                    orden=SILOP_CONFIG.SENHALES.(posiciones{numero}).R;
                    Rot=zeros(3,3);
                    for k=1:3
                        Rot(k,abs(orden(k)))=sign(orden(k));
                    end;
                    SetObjectAlignment(SILOP_CONFIG.BUS.Xbus,p,Rot);
                    SILOP_CONFIG.SENHALES.(posiciones{numero}).Acc_Z = factor*(p-1)+4;
                    SILOP_CONFIG.SENHALES.(posiciones{numero}).Acc_Y = factor*(p-1)+3;
                    SILOP_CONFIG.SENHALES.(posiciones{numero}).Acc_X = factor*(p-1)+2;
                    SILOP_CONFIG.SENHALES.(posiciones{numero}).G_Z = factor*(p-1)+7;
                    SILOP_CONFIG.SENHALES.(posiciones{numero}).G_Y = factor*(p-1)+6;
                    SILOP_CONFIG.SENHALES.(posiciones{numero}).G_X = factor*(p-1)+5;
                    SILOP_CONFIG.SENHALES.(posiciones{numero}).MG_Z = factor*(p-1)+10;
                    SILOP_CONFIG.SENHALES.(posiciones{numero}).MG_Y = factor*(p-1)+9;
                    SILOP_CONFIG.SENHALES.(posiciones{numero}).MG_X = factor*(p-1)+8;
                    if (SILOP_CONFIG.SENHALES.(posiciones{numero}).MG_Z>SILOP_CONFIG.SENHALES.NUMEROSENHALES)
                        SILOP_CONFIG.SENHALES.NUMEROSENHALES=SILOP_CONFIG.SENHALES.(posiciones{numero}).MG_Z;
                    end    
                end
            end
        catch
			s=lasterror();
    		disp(s.message);
			stopsilop();
            rethrow(s);
        end
    end % fin de modo xbusmaster

    
    
            
function conectar_a_SF_3D(puerto, bps, freq, modo, buffer)
        global SILOP_CONFIG
        
        % Calcular el numero de dispositivos por defecto
        posiciones=fieldnames(SILOP_CONFIG.SENHALES);
        ns=length(posiciones)-1;
        if (ns>1)
            error('Los sparkfun 3D sólo tienen un sensor, se han especificado demasiados IMUS')
        end
        % Crear el objeto xbusmaster
        try 
           sf3d=creasf3d(puerto,bps,freq,modo,buffer);
        catch
            rethrow (lasterror());
        end
        SILOP_CONFIG.BUS.SF_3D=sf3d;               
        numero=2;
        disp('Los sparkfun 3d no soportan reorientacion por hardware');
        disp('el driver podria implementarla por software en el futuro');
        disp('se ignora la orientacion especificada mediante addimu');
        SILOP_CONFIG.SENHALES.(posiciones{numero}).Acc_Z = 3;
        SILOP_CONFIG.SENHALES.(posiciones{numero}).Acc_Y = 2;
        SILOP_CONFIG.SENHALES.(posiciones{numero}).Acc_X = 1;
        SILOP_CONFIG.SENHALES.(posiciones{numero}).G_Z = -1;
        SILOP_CONFIG.SENHALES.(posiciones{numero}).G_Y = -1;
        SILOP_CONFIG.SENHALES.(posiciones{numero}).G_X = -1;
        SILOP_CONFIG.SENHALES.(posiciones{numero}).MG_Z = -1;
        SILOP_CONFIG.SENHALES.(posiciones{numero}).MG_Y = -1;
        SILOP_CONFIG.SENHALES.(posiciones{numero}).MG_X = -1;
        SILOP_CONFIG.SENHALES.NUMEROSENHALES=3;
    end % fin de modo SF_3D
