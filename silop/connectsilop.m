% CONNECTSILOP Conecta el sistema de procesamiento con los sensores previamente especificados
%
% CONNECTSILOP Conecta el sistema de procesamiento con los sensores previamente especificados, o en el caso de trabajar
% en modo simulacion con el fichero en el que esta guardado un log capturado por los XSens
% 
% Syntax: 
%   CONFIG = connectsilop(CONFIG, modo_simulacion, source, bps, freq, modo, buffer)
%
%   Parametros de entrada:
%		CONFIG     Estructura de configuracion de los sensores y algoritmos
%		modo_simulacion  Parametro que indica si se realiza la simulacion o no. 
%			   Por defecto vale 0 (no se simula)
%               source     Fichero del que leer los datos(en simulacion) o puerto serie al que conectar(en RT)
%			   'test.log' o 'COM24' por defecto(respectivamente)
%               bps        Velocidad a la que conectarse 460800bps por defecto
%		freq       Frecuencia de muestreo. 100Hz por defecto
%               modo	   Conjunto de datos a capturar (por defecto callibrated) 
%               buffer     Tamaño (en segundos) del buffer de datos
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

function CONFIG = connectsilop(CONFIG, modo_simulacion, log, bps, freq, modo, buffer)
    
    if (nargin<2)
	modo_simulacion=0; 
    end	
    
    global SILOP_DATA_BUFFER;
    SILOP_DATA_BUFFER = [];

    if(modo_simulacion)
	if (nargin<3)
		log='test.log';
	end
        %Dejamos una simulaciÃ³n sÃ³lo de datos del COG para esta versiÃ³n. 
        %En el futuro tendra que haber un formato de guardado y cargado de datos
	%Se permite especificar la orientación en el log
        CONFIG.SENHALES.COG.Acc_Z = CONFIG.SENHALES.COG.R(3)+1;
        CONFIG.SENHALES.COG.Acc_Y = CONFIG.SENHALES.COG.R(2)+1;
        CONFIG.SENHALES.COG.Acc_X = CONFIG.SENHALES.COG.R(1)+1;
        CONFIG.SENHALES.COG.G_Z = CONFIG.SENHALES.COG.R(3)+4;
        CONFIG.SENHALES.COG.G_Y = CONFIG.SENHALES.COG.R(2)+4;
        CONFIG.SENHALES.COG.G_X = CONFIG.SENHALES.COG.R(1)+4;
        CONFIG.SENHALES.COG.MG_Z = CONFIG.SENHALES.COG.R(3)+7;
        CONFIG.SENHALES.COG.MG_Y = CONFIG.SENHALES.COG.R(2)+7;
        CONFIG.SENHALES.COG.MG_X = CONFIG.SENHALES.COG.R(1)+7;
            
        CONFIG.SENHALES.NUMEROSENHALES = 10;
        
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
        
        % Actualizar los valores de las señales
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
                error('SilopToolbox:connectsilop','El número de serie del sensor asignado al COG no ha sido encontrado');
            else
               CONFIG.SENHALES.COG.Acc_Z = factor*(p-1)+CONFIG.SENHALES.COG.R(3)+1;
               CONFIG.SENHALES.COG.Acc_Y = factor*(p-1)+CONFIG.SENHALES.COG.R(2)+1;
               CONFIG.SENHALES.COG.Acc_X = factor*(p-1)+CONFIG.SENHALES.COG.R(1)+1;
               CONFIG.SENHALES.COG.G_Z = factor*(p-1)+CONFIG.SENHALES.COG.R(3)+4;
               CONFIG.SENHALES.COG.G_Y = factor*(p-1)+CONFIG.SENHALES.COG.R(2)+4;
               CONFIG.SENHALES.COG.G_X = factor*(p-1)+CONFIG.SENHALES.COG.R(1)+4;
               CONFIG.SENHALES.COG.MG_Z = factor*(p-1)+CONFIG.SENHALES.COG.R(3)+7;
               CONFIG.SENHALES.COG.MG_Y = factor*(p-1)+CONFIG.SENHALES.COG.R(2)+7;
               CONFIG.SENHALES.COG.MG_X = factor*(p-1)+CONFIG.SENHALES.COG.R(1)+7;
               if (CONFIG.SENHALES.MUSLO_DCHO.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.MUSLO_DCHO.MG_X;
               end
            end
        end

        if (CONFIG.SENHALES.MUSLO_DCHO.Serie~=-1)
            % Hay un dispositivo en el Muslo izquierdo
            p=find(id_disp==CONFIG.SENHALES.MUSLO_DCHO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El número de serie del sensor asignado al MUSLO DCHO no ha sido encontrado');
            else
               CONFIG.SENHALES.MUSLO_DCHO.Acc_Z = factor*(p-1)+CONFIG.SENHALES.MUSLO_DCHO.R(3)+1;
               CONFIG.SENHALES.MUSLO_DCHO.Acc_Y = factor*(p-1)+CONFIG.SENHALES.MUSLO_DCHO.R(2)+1;
               CONFIG.SENHALES.MUSLO_DCHO.Acc_X = factor*(p-1)+CONFIG.SENHALES.MUSLO_DCHO.R(1)+1;
               CONFIG.SENHALES.MUSLO_DCHO.G_Z = factor*(p-1)+CONFIG.SENHALES.MUSLO_DCHO.R(3)+4;
               CONFIG.SENHALES.MUSLO_DCHO.G_Y = factor*(p-1)+CONFIG.SENHALES.MUSLO_DCHO.R(2)+4;
               CONFIG.SENHALES.MUSLO_DCHO.G_X = factor*(p-1)+CONFIG.SENHALES.MUSLO_DCHO.R(1)+4;
               CONFIG.SENHALES.MUSLO_DCHO.MG_Z = factor*(p-1)+CONFIG.SENHALES.MUSLO_DCHO.R(3)+7;
               CONFIG.SENHALES.MUSLO_DCHO.MG_Y = factor*(p-1)+CONFIG.SENHALES.MUSLO_DCHO.R(2)+7;
               CONFIG.SENHALES.MUSLO_DCHO.MG_X = factor*(p-1)++CONFIG.SENHALES.MUSLO_DCHO.R(1)+7;
               if (CONFIG.SENHALES.MUSLO_DCHO.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.MUSLO_DCHO.MG_X;
               end
            end
        end

        if (CONFIG.SENHALES.MUSLO_IZDO.Serie~=-1)
            % Hay un dispositivo en el Muslo izquierdo
            p=find(id_disp==CONFIG.SENHALES.MUSLO_IZDO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El número de serie del sensor asignado al MUSLO IZDO no ha sido encontrado');
            else
               CONFIG.SENHALES.MUSLO_IZDO.Acc_Z = factor*(p-1)+CONFIG.SENHALES.MUSLO_IZDO.R(3)+1;
               CONFIG.SENHALES.MUSLO_IZDO.Acc_Y = factor*(p-1)+CONFIG.SENHALES.MUSLO_IZDO.R(2)+1;
               CONFIG.SENHALES.MUSLO_IZDO.Acc_X = factor*(p-1)+CONFIG.SENHALES.MUSLO_IZDO.R(1)+1;
               CONFIG.SENHALES.MUSLO_IZDO.G_Z = factor*(p-1)+CONFIG.SENHALES.MUSLO_IZDO.R(3)+4;
               CONFIG.SENHALES.MUSLO_IZDO.G_Y = factor*(p-1)+CONFIG.SENHALES.MUSLO_IZDO.R(2)+4;
               CONFIG.SENHALES.MUSLO_IZDO.G_X = factor*(p-1)+CONFIG.SENHALES.MUSLO_IZDO.R(1)+4;
               CONFIG.SENHALES.MUSLO_IZDO.MG_Z = factor*(p-1)+CONFIG.SENHALES.MUSLO_IZDO.R(3)+7;
               CONFIG.SENHALES.MUSLO_IZDO.MG_Y = factor*(p-1)+CONFIG.SENHALES.MUSLO_IZDO.R(2)+7;
               CONFIG.SENHALES.MUSLO_IZDO.MG_X = factor*(p-1)+CONFIG.SENHALES.MUSLO_IZDO.R(1)+7;
               if (CONFIG.SENHALES.MUSLO_IZDO.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.MUSLO_IZDO.MG_X;
               end
            end
        end
       
        if (CONFIG.SENHALES.TIBIA_DCHA.Serie~=-1)
            % Hay un dispositivo en el Muslo derecho
            p=find(id_disp==CONFIG.SENHALES.TIBIA_DCHA.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El número de serie del sensor asignado al TIBIA DCHA no ha sido encontrado');
            else
               CONFIG.SENHALES.TIBIA_DCHA.Acc_Z = factor*(p-1)+CONFIG.SENHALES.TIBIA_DCHA.R(3)+1;
               CONFIG.SENHALES.TIBIA_DCHA.Acc_Y = factor*(p-1)+CONFIG.SENHALES.TIBIA_DCHA.R(2)+1;
               CONFIG.SENHALES.TIBIA_DCHA.Acc_X = factor*(p-1)+CONFIG.SENHALES.TIBIA_DCHA.R(1)+1;
               CONFIG.SENHALES.TIBIA_DCHA.G_Z = factor*(p-1)+CONFIG.SENHALES.TIBIA_DCHA.R(3)+4;
               CONFIG.SENHALES.TIBIA_DCHA.G_Y = factor*(p-1)+CONFIG.SENHALES.TIBIA_DCHA.R(2)+4;
               CONFIG.SENHALES.TIBIA_DCHA.G_X = factor*(p-1)+CONFIG.SENHALES.TIBIA_DCHA.R(1)+4;
               CONFIG.SENHALES.TIBIA_DCHA.MG_Z = factor*(p-1)+CONFIG.SENHALES.TIBIA_DCHA.R(3)+7;
               CONFIG.SENHALES.TIBIA_DCHA.MG_Y = factor*(p-1)+CONFIG.SENHALES.TIBIA_DCHA.R(2)+7;
               CONFIG.SENHALES.TIBIA_DCHA.MG_X = factor*(p-1)+CONFIG.SENHALES.TIBIA_DCHA.R(1)+7;
               if (CONFIG.SENHALES.TIBIA_DCHA.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.TIBIA_DCHA.MG_X;
               end
            end
        end

        if (CONFIG.SENHALES.TIBIA_IZDA.Serie~=-1)
            % Hay un dispositivo en el Muslo derecho
            p=find(id_disp==CONFIG.SENHALES.TIBIA_IZDA.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El número de serie del sensor asignado al TIBIA IZDA no ha sido encontrado');
            else
               CONFIG.SENHALES.TIBIA_IZDA.Acc_Z = factor*(p-1)+CONFIG.SENHALES.TIBIA_IZDA.R(3)+1;
               CONFIG.SENHALES.TIBIA_IZDA.Acc_Y = factor*(p-1)+CONFIG.SENHALES.TIBIA_IZDA.R(2)+1;
               CONFIG.SENHALES.TIBIA_IZDA.Acc_X = factor*(p-1)+CONFIG.SENHALES.TIBIA_IZDA.R(1)+1;
               CONFIG.SENHALES.TIBIA_IZDA.G_Z = factor*(p-1)+CONFIG.SENHALES.TIBIA_IZDA.R(3)+4;
               CONFIG.SENHALES.TIBIA_IZDA.G_Y = factor*(p-1)+CONFIG.SENHALES.TIBIA_IZDA.R(2)+4;
               CONFIG.SENHALES.TIBIA_IZDA.G_X = factor*(p-1)+CONFIG.SENHALES.TIBIA_IZDA.R(1)+4;
               CONFIG.SENHALES.TIBIA_IZDA.MG_Z = factor*(p-1)+CONFIG.SENHALES.TIBIA_IZDA.R(3)+7;
               CONFIG.SENHALES.TIBIA_IZDA.MG_Y = factor*(p-1)+CONFIG.SENHALES.TIBIA_IZDA.R(2)+4;
               CONFIG.SENHALES.TIBIA_IZDA.MG_X = factor*(p-1)+CONFIG.SENHALES.TIBIA_IZDA.R(1)+4;
               if (CONFIG.SENHALES.TIBIA_IZDA.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.TIBIA_IZDA.MG_X;
               end
            end
        end
       
        if (CONFIG.SENHALES.PIE_DCHO.Serie~=-1)
            % Hay un dispositivo en el Muslo derecho
            p=find(id_disp==CONFIG.SENHALES.PIE_DCHO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El número de serie del sensor asignado al PIE DCHO no ha sido encontrado');
            else
               CONFIG.SENHALES.PIE_DCHO.Acc_Z = factor*(p-1)+CONFIG.SENHALES.PIE_DCHO.R(3)+1;
               CONFIG.SENHALES.PIE_DCHO.Acc_Y = factor*(p-1)+CONFIG.SENHALES.PIE_DCHO.R(2)+1;
               CONFIG.SENHALES.PIE_DCHO.Acc_X = factor*(p-1)+CONFIG.SENHALES.PIE_DCHO.R(1)+1;
               CONFIG.SENHALES.PIE_DCHO.G_Z = factor*(p-1)+CONFIG.SENHALES.PIE_DCHO.R(3)+4;
               CONFIG.SENHALES.PIE_DCHO.G_Y = factor*(p-1)+CONFIG.SENHALES.PIE_DCHO.R(2)+4;
               CONFIG.SENHALES.PIE_DCHO.G_X = factor*(p-1)+CONFIG.SENHALES.PIE_DCHO.R(1)+4;
               CONFIG.SENHALES.PIE_DCHO.MG_Z = factor*(p-1)+CONFIG.SENHALES.PIE_DCHO.R(3)+7;
               CONFIG.SENHALES.PIE_DCHO.MG_Y = factor*(p-1)+CONFIG.SENHALES.PIE_DCHO.R(2)+7;
               CONFIG.SENHALES.PIE_DCHO.MG_X = factor*(p-1)+CONFIG.SENHALES.PIE_DCHO.R(1)+7;
               if (CONFIG.SENHALES.PIE_DCHO.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.PIE_DCHO.MG_X;
               end
            end
        end

        if (CONFIG.SENHALES.PIE_IZDO.Serie~=-1)
            % Hay un dispositivo en el Muslo izquierdo
            p=find(id_disp==CONFIG.SENHALES.PIE_IZDO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El número de serie del sensor asignado al PIE IZDO no ha sido encontrado');
            else
               CONFIG.SENHALES.PIE_IZDO.Acc_Z = factor*(p-1)+CONFIG.SENHALES.PIE_IZDO.R(3)+1;
               CONFIG.SENHALES.PIE_IZDO.Acc_Y = factor*(p-1)+CONFIG.SENHALES.PIE_IZDO.R(2)+1;
               CONFIG.SENHALES.PIE_IZDO.Acc_X = factor*(p-1)+CONFIG.SENHALES.PIE_IZDO.R(1)+1;
               CONFIG.SENHALES.PIE_IZDO.G_Z = factor*(p-1)+CONFIG.SENHALES.PIE_IZDO.R(3)+4;
               CONFIG.SENHALES.PIE_IZDO.G_Y = factor*(p-1)+CONFIG.SENHALES.PIE_IZDO.R(2)+4;
               CONFIG.SENHALES.PIE_IZDO.G_X = factor*(p-1)+CONFIG.SENHALES.PIE_IZDO.R(1)+4;
               CONFIG.SENHALES.PIE_IZDO.MG_Z = factor*(p-1)+CONFIG.SENHALES.PIE_IZDO.R(3)+7;
               CONFIG.SENHALES.PIE_IZDO.MG_Y = factor*(p-1)+CONFIG.SENHALES.PIE_IZDO.R(2)+7;
               CONFIG.SENHALES.PIE_IZDO.MG_X = factor*(p-1)+CONFIG.SENHALES.PIE_IZDO.R(1)+7;
               if (CONFIG.SENHALES.PIE_IZDO.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.PIE_IZDO.MG_X;
               end
            end
        end


    end % fin de modo xbusmaster

