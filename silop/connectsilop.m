% CONNECTSILOP Conecta el sistema de procesamiento con los sensores previamente especificados
%
% CONNECTSILOP Conecta el sistema de procesamiento con los sensores
% previamente especificados, o en el caso de trabajar
% en modo simulacion con el fichero en el que esta guardado un log capturado por los XSens
% 
% Syntax: 
%   connectsilop(modo_simulacion, source, bps, freq, modo, buffer)
%
%   Parametros de entrada:
%		modo_simulacion  Parametro que indica si se realiza la simulacion o no. 
%			   Por defecto vale 0 (no se simula)
%               source     Fichero del que leer los datos(en simulacion)
%                          o puerto serie al que conectar(en RT)
%			   'test.log' o 'COM24' por defecto(respectivamente). 
%                          El fichero para la simulacion 
%			   puede se un .log de Xsens, un .tana de Xsens
%			   calibrado, o un .sl de la propia toolbox
%               bps        Velocidad a la que conectarse 460800bps por defecto
%		freq       Frecuencia de muestreo. 100Hz por defecto
%               modo	   Conjunto de datos a capturar (por defecto callibrated) 
%               buffer     Tamanho (en segundos) del buffer de datos
%
%   Parametros de salida: Ninguno 
% 
% Examples: 
%   
%
% See also: creaxbusmaster

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
    if (isempty(SILOP_CONFIG.SENHALES))
        error('no se ha indicado ningún IMU mediante addimu');
    end
    
    if(modo_simulacion)
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
        t = timer('TimerFcn', {@simula_muestreo, log}, 'Period', 3.0, 'ExecutionMode', 'fixedRate');
        SILOP_CONFIG.BUS.Temporizador = t;
        SILOP_CONFIG.BUS.Xbus=-1;
         
    else
        conectar_a_xbus(log, bps, freq, modo, buffer)
    end
end

function []=conectar_a_log(log)
    global SILOP_CONFIG
    global SILOP_DATA_LOG
    
    posiciones=fieldnames(SILOP_CONFIG.SENHALES);
    numerodeimus=length(posiciones)-1;
    if (numerodeimus>1)
        numeroreal=0;
        for numero=1:numerodeimus
            if (SILOP_CONFIG.SENHALES.(posiciones{numero}).Serie~=-1)
                numeroreal=numeroreal+1;
            end
        end
        if (numeroreal>1)
            error('Solo se puede tener un IMU en la simulacion desde un .log');
        end
    end
    SILOP_CONFIG.SENHALES.COG.Acc_Z = 4;
    SILOP_CONFIG.SENHALES.COG.Acc_Y = 3;
    SILOP_CONFIG.SENHALES.COG.Acc_X = 2;
    SILOP_CONFIG.SENHALES.COG.G_Z = 7;
    SILOP_CONFIG.SENHALES.COG.G_Y = 6;
    SILOP_CONFIG.SENHALES.COG.G_X = 5;
    SILOP_CONFIG.SENHALES.COG.MG_Z = 10;
    SILOP_CONFIG.SENHALES.COG.MG_Y = 9;
    SILOP_CONFIG.SENHALES.COG.MG_X = 8;
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
        numeroreal=0;
        for numero=1:numerodeimus
            if (SILOP_CONFIG.SENHALES.(posiciones{numero}).Serie~=-1)
                numeroreal=numeroreal+1;
            end
        end
        if (numeroreal>1)
            error('Solo se puede tener un IMU en la simulacion desde un .log');
        end
    end
    SILOP_CONFIG.SENHALES.COG.Acc_Z = 3;
    SILOP_CONFIG.SENHALES.COG.Acc_Y = 2;
    SILOP_CONFIG.SENHALES.COG.Acc_X = 1;
    SILOP_CONFIG.SENHALES.COG.G_Z = -1;
    SILOP_CONFIG.SENHALES.COG.G_Y = -1;
    SILOP_CONFIG.SENHALES.COG.G_X = -1;
    SILOP_CONFIG.SENHALES.COG.MG_Z = -1;
    SILOP_CONFIG.SENHALES.COG.MG_Y = -1;
    SILOP_CONFIG.SENHALES.COG.MG_X = -1;
    SILOP_CONFIG.SENHALES.NUMEROSENHALES = 5; %3 aceleraciones y 2!! tiempos
		
	SILOP_DATA_LOG=load(log); 
end

function  []=conectar_a_sl(log)
    global SILOP_CONFIG
    global SILOP_DATA_LOG
    unzip(log);
    tmp=load('config.mat');
     %Comprobamos que el log tenga los sensores solicitados
    for donde={'COG','PIE_IZDO','PIE_DCHO','MUSLO_IZDO','MUSLO_DCHO','TIBIA_IZDA','TIBIA_DCHA'}
         if ((eval(['SILOP_CONFIG.SENHALES.',donde{1},'.Serie~=-1'])) && (eval(['tmp.CONFIG.SENHALES.',donde{1},'.Serie==-1'])))
             error(['no se encuentra el sensor del ',donde{1}]);
         end
    end    
     %Incluimos toda la informaci�n de las se�ales. Puede haber de m�s, pero no molesta.
     SILOP_CONFIG.SENHALES=tmp.SILOP_CONFIG.SENHALES;
     %Ya no necesitamos mas el .mat ni tampoco los resultados de algoritmos previos.
     delete ('config.mat');
     existe=dir('datos_alg.log');
     if (~isempty(existe))
         delete ('datos_alg.log');
     end
      SILOP_DATA_LOG=load('datos.log'); 
     delete ('datos.log');
end



function conectar_a_xbus(log, bps, freq, modo, buffer)
        if (nargin<1)
            puerto='COM24';
        else
            puerto=log;
        end
        if (nargin<2)
            bps=460800;
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
        
        % Calcular el numero de dispositivos por defecto
        ns=0;
        for donde={'COG','PIE_IZDO','PIE_DCHO','MUSLO_IZDO','MUSLO_DCHO','TIBIA_IZDA','TIBIA_DCHA'}
                    if (eval(['SILOP_CONFIG.SENHALES.',donde{1},'.Serie~=-1'])) 
			            ns=ns+1;
                    end
        end
        
        % Crear el objeto xbusmaster
        try 
            xbus=creaxbusmaster(puerto,bps,freq,modo,buffer,ns);
        catch
            rethrow (lasterror());
        end
        SILOP_CONFIG.BUS.Xbus=xbus;
        SILOP_CONFIG.BUS.Temporizador=-1;
        
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
            for donde={'COG','PIE_IZDO','PIE_DCHO','MUSLO_IZDO','MUSLO_DCHO','TIBIA_IZDA','TIBIA_DCHA'}
            %Buscamos el dispositivo en cada punto
                if (eval(['SILOP_CONFIG.SENHALES.',donde{1},'.Serie~=-1']))
                    p=eval(['find(id_disp==SILOP_CONFIG.SENHALES.',donde{1},'.Serie)']);
                    if (isempty(p))
                        error('SilopToolbox:connectsilop',['El numero de serie del sensor asignado al ',donde{1},' no ha sido encontrado']);
                    else
                        orden=eval(['SILOP_CONFIG.SENHALES.',donde{1},'.R']);
                        Rot=zeros(3,3);
                        for k=1:3
                            Rot(k,abs(orden(k)))=sign(orden(k));
                        end;
                        SetObjectAlignment(SILOP_CONFIG.BUS.Xbus,p,Rot);
                        eval(['SILOP_CONFIG.SENHALES.',donde{1},'.Acc_Z = factor*(p-1)+4;']);
                        eval(['SILOP_CONFIG.SENHALES.',donde{1},'.Acc_Y = factor*(p-1)+3;']);
                        eval(['SILOP_CONFIG.SENHALES.',donde{1},'.Acc_X = factor*(p-1)+2;']);
                        eval(['SILOP_CONFIG.SENHALES.',donde{1},'.G_Z = factor*(p-1)+7;']);
                        eval(['SILOP_CONFIG.SENHALES.',donde{1},'.G_Y = factor*(p-1)+6;']);
                        eval(['SILOP_CONFIG.SENHALES.',donde{1},'.G_X = factor*(p-1)+5;']);
                        eval(['SILOP_CONFIG.SENHALES.',donde{1},'.MG_Z = factor*(p-1)+10;']);
                        eval(['SILOP_CONFIG.SENHALES.',donde{1},'.MG_Y = factor*(p-1)+9;']);
                        eval(['SILOP_CONFIG.SENHALES.',donde{1},'.MG_X = factor*(p-1)+8;']);
                        if (eval(['SILOP_CONFIG.SENHALES.',donde{1},'.MG_Z'])>SILOP_CONFIG.SENHALES.NUMEROSENHALES)
                            SILOP_CONFIG.SENHALES.NUMEROSENHALES=eval(['SILOP_CONFIG.SENHALES.',donde{1},'.MG_Z']);
                        end    
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