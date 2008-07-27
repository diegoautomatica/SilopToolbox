% CONNECTSILOP Conecta el sistema de procesamiento con los sensores previamente especificados
%
% CONNECTSILOP Conecta el sistema de procesamiento con los sensores
% previamente especificados, o en el caso de trabajar
% en modo simulacion con el fichero en el que esta guardado un log
% capturado
% 
% Syntax: 
%   connectsilop(driver, source, freq, updateeach, driver_opt)
%
%   Parametros de entrada:
%		driver:  Cadena de texto que indica el modo de funcionamiento (nombre
%               del driver a usar). Por ejemplo: 
%               'Xbus':             sensor xbus (por defecto)
%               'Temporizador':     modo de simulacion
%               'SF_3D':            SparkFun 3D serial accelerometer
%                ...:               Consultar la lista de drivers en la
%                                   documentacion para ver otros dispositivos soportados
%       source     Puerto y/o fichero del que leer los datos
%                        Valor por defecto: 'COM24'
%                           El puerto de comunicaciones será tipicamente
%                           COMx en windows o /dev/ttyUSBX en linux
%                        El fichero para la simulacion  puede se un .log de Xsens, un .tana de Xsens
%			             calibrado, o un .sl de la propia toolbox
%		freq       Frecuencia de muestreo solicitada. Puede no coincidir con la real.
%                   100Hz por defecto
%       updateeach Tiempo tras el cual se realizará el procesamiento de los
%                   datos recibidos. Por defecto 1 segundo.
%       driver_opt Parametros especificos para cada driver, que se deben
%                   consultar en la documentacion del mismo.
%
%   Parametros de salida: Ninguno 
% 
% Examples: 
%   
%
% See also: 


function connectsilop(driver, source, freq, updateeach, driver_opt)
    
    if (nargin<1)
        driver='Xbus';
    end	
    if (nargin<2)
        source='COM24';
    end
    if (nargin<3)
        freq=100;
    end
    if (nargin<4)
        updateeach=1;
    end
    if (nargin<5)
        driver_opt=[];
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
    
    if (strcmp(driver,'Temporizador'))
        SILOP_CONFIG.BUS.Temporizador = driver_Temporizador('create',{source,updateeach});
        SILOP_CONFIG.BUS.Temporizador = driver_Temporizador('connect',SILOP_CONFIG.BUS.Temporizador);
        SILOP_CONFIG.BUS.Temporizador = driver_Temporizador('gotoconfig',SILOP_CONFIG.BUS.Temporizador);
        SILOP_CONFIG.BUS.Temporizador = driver_Temporizador('configura',{SILOP_CONFIG.BUS.Temporizador,source});
    elseif (strcmp(driver,'SF_3D'))
        SILOP_CONFIG.BUS.SF_3D = driver_SF_3D('create',{source,updateeach,driver_opt});
        SILOP_CONFIG.BUS.SF_3D = driver_SF_3D('connect',SILOP_CONFIG.BUS.SF_3D);
        %La llamada a connect aun no hace nada. Es necesario que tome casi
        %todo el codigo restante de creasf3d
                
        % Crear el objeto xbusmaster
        try 
           sf3d=creasf3d(freq,updateeach,SILOP_CONFIG.BUS.SF_3D);
        catch ME
            rethrow (ME);
        end
        SILOP_CONFIG.BUS.SF_3D=sf3d;               
        numero=2;
        disp('Los sparkfun 3d no soportan reorientacion por hardware');
        disp('el driver podria implementarla por software en el futuro');
        disp('se ignora la orientacion especificada mediante addimu');
        posiciones=fieldnames(SILOP_CONFIG.SENHALES);
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
    elseif (strcmp(driver,'Xbus'))
        conectar_a_xbus(source, freq, updateeach, driver_opt);
    else
        error('modo de funcionamiento no soportado');
    end
end



function conectar_a_xbus(puerto, freq, buffer, driver_opt)
        global SILOP_CONFIG
        
        if (length(driver_opt)<1)
            bps=460800;
        else
            bps=driver_opt(1);
        end
        if (length(driver_opt)<2)
            modo=0;
        else
            modo=driver_opt(2);
        end
        % Calcular el numero de dispositivos por defecto
        posiciones=fieldnames(SILOP_CONFIG.SENHALES);
        ns=length(posiciones)-1;
                        
        % Crear el objeto xbusmaster
        try 
           xbus=creaxbusmaster(puerto,bps,freq,modo,buffer,ns);
        catch ME
            rethrow (ME);
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
        catch ME
			disp(ME.message);
			stopsilop();
            rethrow(ME);
        end
    end % fin de modo xbusmaster

    
    
            
