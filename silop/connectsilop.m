% CONNECTSILOP Conecta el sistema de procesamiento con los sensores previamente especificados
%
% CONNECTSILOP Conecta el sistema de procesamiento con los sensores
% previamente especificados, o en el caso de trabajar
% en modo simulacion con el fichero en el que esta guardado un log capturado por los XSens
% 
% Syntax: 
%   CONFIG = connectsilop(CONFIG, modo_simulacion, source, bps, freq, modo, buffer)
%
%   Parametros de entrada:
%		CONFIG     Estructura de configuracion de los sensores y algoritmos
%		modo_simulacion  Parametro que indica si se realiza la simulacion o no. 
%			   Por defecto vale 0 (no se simula)
%               source     Fichero del que leer los datos(en simulacion)
%                          o puerto serie al que conectar(en RT)
%			   'test.log' o 'COM24' por defecto(respectivamente). 
%                          El fichero para la simulaci�n 
%			   puede se un .log de Xsens, un .tana de Xsens
%			   calibrado, o un .sl de la propia toolbox
%               bps        Velocidad a la que conectarse 460800bps por defecto
%		freq       Frecuencia de muestreo. 100Hz por defecto
%               modo	   Conjunto de datos a capturar (por defecto callibrated) 
%               buffer     Tama�o (en segundos) del buffer de datos
%
%   Parametros de salida: 
%	CONFIG  Estructura de configuracion de los sensores y algoritmos de la aplicacion	
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

function CONFIG = connectsilop(CONFIG, modo_simulacion, log, bps, freq, modo, buffer)
    
    if (nargin<2)
	modo_simulacion=0; 
    end	
    
    global SILOP_DATA_BUFFER;
    SILOP_DATA_BUFFER = [];

    if(modo_simulacion)
	if (nargin<3)
		log='test.log';
	else 
		existe=dir(log);
		if (isempty(existe))
			error('no se encuentra el fichero');
		end	
	end
        
	%Si se toman datos de un .log se asume que s�lo contiene el COG
	if (log(end-3:end)=='.log')
		if ((CONFIG.SENHALES.MUSLO_DCHO.Serie ~= -1) | (CONFIG.SENHALES.MUSLO_IZDO.Serie ~= -1) | (CONFIG.SENHALES.TIBIA_DCHA.Serie ~= -1) | (CONFIG.SENHALES.TIBIA_IZDA.Serie ~= -1) | (CONFIG.SENHALES.PIE_DCHO.Serie ~= -1) | (CONFIG.SENHALES.PIE_IZDO.Serie ~= -1))
			error('s�lo se puede simular el COG desde un fichero .log');
	        end

        	CONFIG.SENHALES.COG.Acc_Z = 4;
        	CONFIG.SENHALES.COG.Acc_Y = 3;
        	CONFIG.SENHALES.COG.Acc_X = 2;
        	CONFIG.SENHALES.COG.G_Z = 7;
        	CONFIG.SENHALES.COG.G_Y = 6;
        	CONFIG.SENHALES.COG.G_X = 5;
        	CONFIG.SENHALES.COG.MG_Z = 10;
        	CONFIG.SENHALES.COG.MG_Y = 9;
        	CONFIG.SENHALES.COG.MG_X = 8;
            	CONFIG.SENHALES.NUMEROSENHALES = 10;
		global SILOP_DATA_LOG; %Variable para leer el fichero
		SILOP_DATA_LOG=load(log);
                orden=CONFIG.SENHALES.COG.R;
                Rot=zeros(3,3);
                for k=1:3
                    Rot(k,abs(orden(k)))=sign(orden(k));
                end;
                SILOP_DATA_LOG(:,2:4)=SILOP_DATA_LOG(:,2:4)*Rot';
                SILOP_DATA_LOG(:,5:7)=SILOP_DATA_LOG(:,5:7)*Rot';
                SILOP_DATA_LOG(:,8:10)=SILOP_DATA_LOG(:,8:10)*Rot';
	%Si se toman datos de un .tana se asume que s�lo contiene aceleraciones del COG
	elseif (log(end-4:end)=='.tana')
		if ((CONFIG.SENHALES.MUSLO_DCHO.Serie ~= -1) | (CONFIG.SENHALES.MUSLO_IZDO.Serie ~= -1) | (CONFIG.SENHALES.TIBIA_DCHA.Serie ~= -1) | (CONFIG.SENHALES.TIBIA_IZDA.Serie ~= -1) | (CONFIG.SENHALES.PIE_DCHO.Serie ~= -1) | (CONFIG.SENHALES.PIE_IZDO.Serie ~= -1))
			error('s�lo se puede simular el COG desde un fichero .tana');
	        end

        	CONFIG.SENHALES.COG.Acc_Z = 3;
        	CONFIG.SENHALES.COG.Acc_Y = 2;
        	CONFIG.SENHALES.COG.Acc_X = 1;
        	CONFIG.SENHALES.COG.G_Z = -1;
        	CONFIG.SENHALES.COG.G_Y = -1;
        	CONFIG.SENHALES.COG.G_X = -1;
        	CONFIG.SENHALES.COG.MG_Z = -1;
        	CONFIG.SENHALES.COG.MG_Y = -1;
        	CONFIG.SENHALES.COG.MG_X = -1;
            	CONFIG.SENHALES.NUMEROSENHALES = 5; %3 aceleraciones y 2!! tiempos
		global SILOP_DATA_LOG; %Variable para leer el fichero
		SILOP_DATA_LOG=load(log); 
	%Si se toman los datos de un .sl tenemos que comprobar el config de ese fichero
	elseif (log(end-2:end)=='.sl')
		unzip(log);
		tmp=load('config.mat');
		%Comprobamos que el log tenga los sensores solicitados
        	if ((CONFIG.SENHALES.COG.Serie~=-1) & (tmp.CONFIG.SENHALES.COG.Serie==-1))
			error('no se encuentra el sensor del COG');
		end
	        if ((CONFIG.SENHALES.MUSLO_DCHO.Serie ~= -1) & (tmp.CONFIG.SENHALES.MUSLO_DCHO.Serie == -1))
			error('no se encuentra el sensor del Muslo Derecho');
        	end
        	if ((CONFIG.SENHALES.MUSLO_IZDO.Serie ~= -1) & (tmp.CONFIG.SENHALES.MUSLO_IZDO.Serie == -1))
			error('no se encuentra el sensor del Muslo Izquierdo');
	        end
	        if ((CONFIG.SENHALES.TIBIA_DCHA.Serie ~= -1) & (tmp.CONFIG.SENHALES.TIBIA_DCHA.Serie == -1))
			error('no se encuentra el sensor de la tibia derecha');
	        end
	        if ((CONFIG.SENHALES.TIBIA_IZDA.Serie ~= -1) & (tmp.CONFIG.SENHALES.TIBIA_IZDA.Serie == -1))
		        error('no se encuentra el sensor de la tibia izquierda');
        	end
        	if ((CONFIG.SENHALES.PIE_DCHO.Serie ~= -1) & (tmp.CONFIG.SENHALES.PIE_DCHO.Serie == -1))
			error('no se encuentra el sensor del pie derecho');
	        end
        	if ((CONFIG.SENHALES.PIE_IZDO.Serie ~= -1) & (tmp.CONFIG.SENHALES.PIE_IZDO.Serie == -1))
			error('no se encuentra el sensor del pie izquierdo');
	        end
		%Incluimos toda la informaci�n de las se�ales. Puede haber de m�s, pero no molesta.
		CONFIG.SENHALES=tmp.CONFIG.SENHALES;
		%Ya no necesitamos mas el .mat ni tampoco los resultados de algoritmos previos.
		delete ('config.mat');
		existe=dir('datos_alg.log');
		if (~isempty(existe))
		    delete ('datos_alg.log');
		end
		global SILOP_DATA_LOG %Variable para leer el fichero
		SILOP_DATA_LOG=load('datos.log'); 
		delete ('datos.log');
	else error('formato de archivo desconocido. Solo se soportan ficheros .log y .sl');
	end
        
    global t
        t = timer('TimerFcn', {@simula_muestreo, log}, 'Period', 3.0, 'ExecutionMode', 'fixedRate');
        CONFIG.BUS.Temporizador = t;
        CONFIG.BUS.Xbus=-1;
         
    else
        if (nargin<3)
            puerto='COM24';
        else
            puerto=log;
        end
        if (nargin<4)
            bps=460800;
        end
        if (nargin<5)
            freq=100;
        end
        if (nargin<6)
            modo=0;
        end
        if (nargin<7)
            buffer=1;
        end
        
        % Calcular el numero de dispositivos por defecto
        ns=0;
        if (CONFIG.SENHALES.COG.Serie ~= -1)
            ns=ns+1;
        end
        if (CONFIG.SENHALES.MUSLO_DCHO.Serie ~= -1)
            ns=ns+1;
        end
        if (CONFIG.SENHALES.MUSLO_IZDO.Serie ~= -1)
            ns=ns+1;
        end
        if (CONFIG.SENHALES.TIBIA_DCHA.Serie ~= -1)
            ns=ns+1;
        end
        if (CONFIG.SENHALES.TIBIA_IZDA.Serie ~= -1)
            ns=ns+1;
        end
        if (CONFIG.SENHALES.PIE_DCHO.Serie ~= -1)
            ns=ns+1;
        end
        if (CONFIG.SENHALES.PIE_IZDO.Serie ~= -1)
            ns=ns+1;
        end

        % Crear el objeto xbusmaster
	xbus=creaxbusmaster(puerto,bps,freq,modo,buffer,ns);
        CONFIG.BUS.Xbus=xbus;
        CONFIG.BUS.Temporizador=-1;
        
        % Actualizar los valores de las se�ales
        switch (xbus.modo)
            case 0,
                factor=9;
            case 1,
                factor=9+4;
            case 2,
                factor=9+9;
        end;
        
        % Identificar sensores y asignar los valores de las columnas
        % correspondientes
        id_disp=zeros(1,xbus.ndisp);
        for k=1:xbus.ndisp
            id_disp(k)=eval(xbus.sensores.Cadena(:,k));
        end
        if (CONFIG.SENHALES.COG.Serie~=-1)
            % Hay un dispositivo en el COG
            p=find(id_disp==CONFIG.SENHALES.COG.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al COG no ha sido encontrado');
            else
	       orden=CONFIG.SENHALES.COG.R;
               Rot=zeros(3,3);
               for k=1:3
                    Rot(k,abs(orden(k)))=sign(orden(k));
               end;
	       SetObjectAlignment(CONFIG.BUS.Xbus,p,Rot);
               CONFIG.SENHALES.COG.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.COG.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.COG.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.COG.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.COG.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.COG.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.COG.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.COG.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.COG.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.COG.MG_Z>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.COG.MG_Z;
               end
            end
        end

        if (CONFIG.SENHALES.MUSLO_DCHO.Serie~=-1)
            % Hay un dispositivo en el Muslo izquierdo
            p=find(id_disp==CONFIG.SENHALES.MUSLO_DCHO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al MUSLO DCHO no ha sido encontrado');
            else
	       orden=CONFIG.SENHALES.MUSLO_DCHO.R;
               Rot=zeros(3,3);
               for k=1:3
                    Rot(k,abs(orden(k)))=sign(orden(k));
               end;
	       SetObjectAlignment(CONFIG.BUS.Xbus,p,Rot);
               CONFIG.SENHALES.MUSLO_DCHO.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.MUSLO_DCHO.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.MUSLO_DCHO.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.MUSLO_DCHO.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.MUSLO_DCHO.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.MUSLO_DCHO.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.MUSLO_DCHO.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.MUSLO_DCHO.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.MUSLO_DCHO.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.MUSLO_DCHO.MG_Z>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.MUSLO_DCHO.MG_Z;
               end
            end
        end

        if (CONFIG.SENHALES.MUSLO_IZDO.Serie~=-1)
            % Hay un dispositivo en el Muslo izquierdo
            p=find(id_disp==CONFIG.SENHALES.MUSLO_IZDO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al MUSLO IZDO no ha sido encontrado');
            else
	       orden=CONFIG.SENHALES.MUSLO_IZDO.R;
               Rot=zeros(3,3);
               for k=1:3
                    Rot(k,abs(orden(k)))=sign(orden(k));
               end;
	       SetObjectAlignment(CONFIG.BUS.Xbus,p,Rot);
               CONFIG.SENHALES.MUSLO_IZDO.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.MUSLO_IZDO.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.MUSLO_IZDO.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.MUSLO_IZDO.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.MUSLO_IZDO.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.MUSLO_IZDO.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.MUSLO_IZDO.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.MUSLO_IZDO.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.MUSLO_IZDO.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.MUSLO_IZDO.MG_Z>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.MUSLO_IZDO.MG_Z;
               end
            end
        end
       
        if (CONFIG.SENHALES.TIBIA_DCHA.Serie~=-1)
            % Hay un dispositivo en el Muslo derecho
            p=find(id_disp==CONFIG.SENHALES.TIBIA_DCHA.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al TIBIA DCHA no ha sido encontrado');
            else
	       orden=CONFIG.SENHALES.TIBIA_DCHA.R;
               Rot=zeros(3,3);
               for k=1:3
                    Rot(k,abs(orden(k)))=sign(orden(k));
               end;
	       SetObjectAlignment(CONFIG.BUS.Xbus,p,Rot);
               CONFIG.SENHALES.TIBIA_DCHA.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.TIBIA_DCHA.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.TIBIA_DCHA.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.TIBIA_DCHA.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.TIBIA_DCHA.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.TIBIA_DCHA.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.TIBIA_DCHA.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.TIBIA_DCHA.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.TIBIA_DCHA.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.TIBIA_DCHA.MG_Z>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.TIBIA_DCHA.MG_Z;
               end
            end
        end

        if (CONFIG.SENHALES.TIBIA_IZDA.Serie~=-1)
            % Hay un dispositivo en el Muslo derecho
            p=find(id_disp==CONFIG.SENHALES.TIBIA_IZDA.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al TIBIA IZDA no ha sido encontrado');
            else
	       orden=CONFIG.SENHALES.TIBIA_IZDA.R;
               Rot=zeros(3,3);
               for k=1:3
                    Rot(k,abs(orden(k)))=sign(orden(k));
               end;
	       SetObjectAlignment(CONFIG.BUS.Xbus,p,Rot);
               CONFIG.SENHALES.TIBIA_IZDA.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.TIBIA_IZDA.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.TIBIA_IZDA.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.TIBIA_IZDA.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.TIBIA_IZDA.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.TIBIA_IZDA.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.TIBIA_IZDA.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.TIBIA_IZDA.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.TIBIA_IZDA.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.TIBIA_IZDA.MG_Z>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.TIBIA_IZDA.MG_Z;
               end
            end
        end
       
        if (CONFIG.SENHALES.PIE_DCHO.Serie~=-1)
            % Hay un dispositivo en el Muslo derecho
            p=find(id_disp==CONFIG.SENHALES.PIE_DCHO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al PIE DCHO no ha sido encontrado');
            else
	       orden=CONFIG.SENHALES.PIE_DCHO.R;
               Rot=zeros(3,3);
               for k=1:3
                    Rot(k,abs(orden(k)))=sign(orden(k));
               end;
	       SetObjectAlignment(CONFIG.BUS.Xbus,p,Rot);
               CONFIG.SENHALES.PIE_DCHO.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.PIE_DCHO.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.PIE_DCHO.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.PIE_DCHO.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.PIE_DCHO.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.PIE_DCHO.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.PIE_DCHO.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.PIE_DCHO.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.PIE_DCHO.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.PIE_DCHO.MG_Z>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.PIE_DCHO.MG_Z;
               end
            end
        end

        if (CONFIG.SENHALES.PIE_IZDO.Serie~=-1)
            % Hay un dispositivo en el Muslo izquierdo
            p=find(id_disp==CONFIG.SENHALES.PIE_IZDO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El numero de serie del sensor asignado al PIE IZDO no ha sido encontrado');
            else
	       orden=CONFIG.SENHALES.PIE_IZDO.R;
               Rot=zeros(3,3);
               for k=1:3
                    Rot(k,abs(orden(k)))=sign(orden(k));
               end;
	       SetObjectAlignment(CONFIG.BUS.Xbus,p,Rot);
               CONFIG.SENHALES.PIE_IZDO.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.PIE_IZDO.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.PIE_IZDO.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.PIE_IZDO.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.PIE_IZDO.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.PIE_IZDO.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.PIE_IZDO.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.PIE_IZDO.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.PIE_IZDO.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.PIE_IZDO.MG_Z>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.PIE_IZDO.MG_Z;
               end
            end
        end


    end % fin de modo xbusmaster

