% CONNECTSILOP Conecta el sistema de procesamiento con los sensores previamente especificados
%
% CONNECTSILOP Conecta el sistema de procesamiento con los sensores previamente especificados, o en el caso de trabajar
% en modo simulación con el fichero en el que esté guardado un log capturado por los XSens
% 
% Syntax: 
%   CONFIG = connectsilop(CONFIG, simulacion,log);
%
%   Parámetros de entrada:
%		CONFIG     Estructura de configuración de los sensores y algoritmos
%		simulacion Parámetro que indica si se realiza la simulación o no. Por defecto vale 0 (no se simula)
%               log        Fichero del que leer los datos
%   Parámetros de salida: 
%	CONFIG  Estructura de configuración de los sensores y algoritmos de la aplicación	
% 
% Examples: 
%   
%
% See also: 

% Author:   Antonio López
% History:  24.01.2008  creado
%           24.01.2008 Incorporado a la toolbox
%

function CONFIG = connectsilop(conf, modo_simulacion, log, bps, freq, modo, buffer)
    
    if (nargin<2)
	modo_simulacion=1; %Cambiar en el futuro. Cuando tengamos el modo real funcionando.
	log='test.log';
    end	
    
    CONFIG=conf;
    global SILOP_DATA_BUFFER;
    SILOP_DATA_BUFFER = [];

    if(modo_simulacion)
        %Dejamos una simulación sólo de datos del COG para esta versión. 
        %En v0.7 tendrá que haber un formato de guardado y cargado de datos
        CONFIG.SENHALES.COG.Acc_Z = 2;
        CONFIG.SENHALES.COG.Acc_Y = 3;
        CONFIG.SENHALES.COG.Acc_X = 4;
        CONFIG.SENHALES.COG.G_Z = 5;
        CONFIG.SENHALES.COG.G_Y = 6;
        CONFIG.SENHALES.COG.G_X = 7;
        CONFIG.SENHALES.COG.MG_Z = 8;
        CONFIG.SENHALES.COG.MG_Y = 9;
        CONFIG.SENHALES.COG.MG_X = 10;
            
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
            % Hay un dispositivo en el Muslo izquierdo
            p=find(id_disp==CONFIG.SENHALES.COG.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al MUSLO IZDO no ha sido encontrado');
            else
               CONFIG.SENHALES.COG.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.COG.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.COG.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.COG.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.COG.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.COG.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.COG.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.COG.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.COG.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.MUSLO_DCHO.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.MUSLO_DCHO.MG_X;
               end
            end
        end

        if (CONFIG.SENHALES.MUSLO_DCHO.Serie~=-1)
            % Hay un dispositivo en el Muslo izquierdo
            p=find(id_disp==CONFIG.SENHALES.MUSLO_DCHO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al MUSLO IZDO no ha sido encontrado');
            else
               CONFIG.SENHALES.MUSLO_DCHO.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.MUSLO_DCHO.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.MUSLO_DCHO.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.MUSLO_DCHO.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.MUSLO_DCHO.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.MUSLO_DCHO.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.MUSLO_DCHO.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.MUSLO_DCHO.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.MUSLO_DCHO.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.MUSLO_DCHO.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.MUSLO_DCHO.MG_X;
               end
            end
        end

        if (CONFIG.SENHALES.MUSLO_IZDO.Serie~=-1)
            % Hay un dispositivo en el Muslo izquierdo
            p=find(id_disp==CONFIG.SENHALES.MUSLO_IZDO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al MUSLO IZDO no ha sido encontrado');
            else
               CONFIG.SENHALES.MUSLO_IZDO.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.MUSLO_IZDO.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.MUSLO_IZDO.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.MUSLO_IZDO.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.MUSLO_IZDO.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.MUSLO_IZDO.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.MUSLO_IZDO.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.MUSLO_IZDO.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.MUSLO_IZDO.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.MUSLO_IZDO.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.MUSLO_IZDO.MG_X;
               end
            end
        end
       
        if (CONFIG.SENHALES.TIBIA_DCHA.Serie~=-1)
            % Hay un dispositivo en el Muslo derecho
            p=find(id_disp==CONFIG.SENHALES.TIBIA_DCHA.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al TIBIA DCHA no ha sido encontrado');
            else
               CONFIG.SENHALES.TIBIA_DCHA.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.TIBIA_DCHA.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.TIBIA_DCHA.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.TIBIA_DCHA.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.TIBIA_DCHA.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.TIBIA_DCHA.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.TIBIA_DCHA.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.TIBIA_DCHA.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.TIBIA_DCHA.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.TIBIA_DCHA.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.TIBIA_DCHA.MG_X;
               end
            end
        end

        if (CONFIG.SENHALES.TIBIA_IZDA.Serie~=-1)
            % Hay un dispositivo en el Muslo derecho
            p=find(id_disp==CONFIG.SENHALES.TIBIA_IZDA.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al TIBIA IZDA no ha sido encontrado');
            else
               CONFIG.SENHALES.TIBIA_IZDA.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.TIBIA_IZDA.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.TIBIA_IZDA.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.TIBIA_IZDA.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.TIBIA_IZDA.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.TIBIA_IZDA.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.TIBIA_IZDA.MG_Z = factor*(p-1)+10;
               CONFIG.SENHALES.TIBIA_IZDA.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.TIBIA_IZDA.MG_X = factor*(p-1)+8;
               if (CONFIG.SENHALES.TIBIA_IZDA.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.TIBIA_IZDA.MG_X;
               end
            end
        end
       
        if (CONFIG.SENHALES.PIE_DCHO.Serie~=-1)
            % Hay un dispositivo en el Muslo derecho
            p=find(id_disp==CONFIG.SENHALES.PIE_DCHO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al PIE DCHO no ha sido encontrado');
            else
               CONFIG.SENHALES.PIE_DCHO.Acc_Z = factor*(p-1)+4;
               CONFIG.SENHALES.PIE_DCHO.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.PIE_DCHO.Acc_X = factor*(p-1)+2;
               CONFIG.SENHALES.PIE_DCHO.G_Z = factor*(p-1)+7;
               CONFIG.SENHALES.PIE_DCHO.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.PIE_DCHO.G_X = factor*(p-1)+5;
               CONFIG.SENHALES.PIE_DCHO.MG_Z = factor*(p-1)+8;
               CONFIG.SENHALES.PIE_DCHO.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.PIE_DCHO.MG_X = factor*(p-1)+10;
               if (CONFIG.SENHALES.PIE_DCHO.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.PIE_DCHO.MG_X;
               end
            end
        end

        if (CONFIG.SENHALES.PIE_IZDO.Serie~=-1)
            % Hay un dispositivo en el Muslo izquierdo
            p=find(id_disp==CONFIG.SENHALES.PIE_IZDO.Serie);
            if (isempty(p))
                error('SilopToolbox:connectsilop','El n�mero de serie del sensor asignado al PIE IZDO no ha sido encontrado');
            else
               CONFIG.SENHALES.PIE_IZDO.Acc_Z = factor*(p-1)+2;
               CONFIG.SENHALES.PIE_IZDO.Acc_Y = factor*(p-1)+3;
               CONFIG.SENHALES.PIE_IZDO.Acc_X = factor*(p-1)+4;
               CONFIG.SENHALES.PIE_IZDO.G_Z = factor*(p-1)+5;
               CONFIG.SENHALES.PIE_IZDO.G_Y = factor*(p-1)+6;
               CONFIG.SENHALES.PIE_IZDO.G_X = factor*(p-1)+7;
               CONFIG.SENHALES.PIE_IZDO.MG_Z = factor*(p-1)+8;
               CONFIG.SENHALES.PIE_IZDO.MG_Y = factor*(p-1)+9;
               CONFIG.SENHALES.PIE_IZDO.MG_X = factor*(p-1)+10;
               if (CONFIG.SENHALES.PIE_IZDO.MG_X>CONFIG.SENHALES.NUMEROSENHALES)
                   CONFIG.SENHALES.NUMEROSENHALES=CONFIG.SENHALES.PIE_IZDO.MG_X;
               end
            end
        end


    end % fin de modo xbusmaster

