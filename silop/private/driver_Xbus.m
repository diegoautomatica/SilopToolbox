% DRIVER_Xbus implementa todo el código necesario para el correcto funcionamiento del dispositivo
% Xsens XBus Master y sus dispositovos MTx asociados
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
%
% DRIVER_Xbus implementa todo el código necesario para el correcto funcionamiento del dispositivo
% Xsens XBus Master y sus dispositovos MTx asociados
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
% 
% Syntax: retorno=driver_Xbus(operacion, parametros)
% 
% Output parameters:
%
% Examples:

function retorno=driver_Xbus(operacion,parametros)

    switch operacion
        case 'create'
            retorno=creaxbus(parametros);
        case 'connect'
            retorno=connectxbus(parametros);
        case 'configura'
            retorno=configuraxbus(parametros);
        case 'gotoconfig'
            retorno=gotoconfig(parametros);
        case 'gotomeasurement'
            retorno=gotomeasurement(parametros);
        case 'destruye'
            retorno=[];
            destruyexbusmaster(parametros);
        otherwise
            disp('error, el driver no soporta la operación indicada');
            retorno=[];
    end
end

function xbus=creaxbus(parametros)
    global SILOP_CONFIG
    source=parametros{1};
    driver_opt=parametros{3};
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
    xbus.ns=ns;
    try
        xbus.puerto=serial(source);
    catch ME
        disp ('Imposible conectarse al puerto serie');
        rethrow (ME);
    end
    xbus.modo=modo;
    switch (xbus.modo)
        case 0,
            xbus.DataLength=ns*36+2;
            xbus.Data=1+9*ns;
        case 1,
            xbus.DataLength=ns*(36+16)+2;
            xbus.Data=1+(9+4)*ns;
        case 2,
            xbus.DataLength=ns*(36+36)+2;
            xbus.Data=1+(9+9)*ns;
        otherwise,
            disp ('modo invalido');
            delete (xbus.puerto);
    end;
    if (xbus.DataLength>254)
        xbus.DataLength=xbus.DataLength+7; % se incluye la cabecera y el checksum
    else
        xbus.DataLength=xbus.DataLength+5; % Se incluye la cabecera y el checksum
    end

    xbus.bps=bps;
end

function xbus=connectxbus(parametros)
    xbus=parametros{1};
    freq=parametros{2};
    updateeach=parametros{3};
    % Calculamos el numero de muestras almacenadas en el buffer
    xbus.freq=freq;
    xbus.buffer=updateeach*freq;
    % Configurar el objeto serie
    xbus.puerto.BaudRate=xbus.bps;
    xbus.puerto.DataBits=8;
    xbus.puerto.FlowControl='none';
    xbus.puerto.Parity='none';
    xbus.puerto.StopBits=2;
    xbus.puerto.ReadAsyncMode = 'continuous';
    xbus.puerto.ByteOrder = 'littleEndian';
    xbus.puerto.BytesAvailableFcnCount = xbus.DataLength*xbus.buffer;
    xbus.puerto.BytesAvailableFcnMode = 'byte';
    xbus.puerto.InputBufferSize = xbus.DataLength*100;
    xbus.puerto.OutputBufferSize = 512;
    xbus.puerto.Tag = 'XBus_Master';
    xbus.puerto.Timeout = 10;
    % Abrir el puerto de comunicaciones
    fopen(xbus.puerto);
end

function xbus=configuraxbus(parametros)
    global SILOP_CONFIG
    xbus=parametros;
    xbus=InitBus(xbus);
    xbus=ReqConfiguration(xbus);
    xbus=SetPeriod(xbus,xbus.freq);
    switch (modo)
        case 0,
            xbus=SetMTOutputMode(xbus,0);
        case 1,
            xbus=SetMTOutputMode(xbus,1);
        case 2,
            xbus=SetMTOutputMode(xbus,3);
    end
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
    
    posiciones=fieldnames(SILOP_CONFIG.SENHALES);
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
end

function XBusMaster=destruyexbusmaster(xb)

    try 
        fclose(xb.puerto);
    catch %#ok<CTCH>
    end
    delete(xb.puerto);
    clear xb
    XBusMaster=[];
end

function XBusMaster=gotoconfig(XBusMaster)

    % Envia el mensaje GoToConfig al objeto XBusMaster
    % Cuerpo del mensaje (excepto el byte de checksum)
    msg=[250,255,48,0];
    % Se calcula el cheksum y se coloca al final
    msg=[msg 256-mod(sum(msg(2:end)),256)];
    % Se envia por el puerto serie 
    fwrite(XBusMaster.puerto,msg,'uint8','async');

    %Ya deberiamos estar en modo config.
    %Permitimos comunicaciones
    XBusMaster.puerto.RequestToSend='on';
    %y damos tiempo a que se termine cualquier trasmision en curso
    pause(1);

    %Limpiamos todo lo que puede quedar en el buffer de medidas anteriores
    XBusMaster.puerto.Timeout=10;
    while (XBusMaster.puerto.BytesAvailable>0)
        disp(['>>> AVISO: Se descartaran ' int2str(XBusMaster.puerto.BytesAvailable) ' datos']);
        fread(XBusMaster.puerto,XBusMaster.puerto.BytesAvailable,'uint8');
    end

    %Reenviamos el mensaje y esta vez comprobamos la respuesta.
    fwrite(XBusMaster.puerto,msg,'uint8','async');
    % Se espera a recibir la contestacion
    [ack,cnt,msg]=fread(XBusMaster.puerto,5,'uint8');
    if (~isempty(msg))
        error('no se ha recibido la respuesta al comando gotoconfig');
    else
        if (mod(sum(ack(2:end)),256)~=0)
            error('Error de checksum durante gotoconfig');
        else
            if (ack(3)~=49)
                error ('mensaje incorrecto recibido durante gotoconfig');
            end
        end
    end
end

%Funcion para el paso a modo medida
function xbus=gotomeasurement(xbus)
    global SILOP_DATA_BUFFER;
    SILOP_DATA_BUFFER=[];

    % Cuerpo del mensaje (excepto el byte de checksum)
    msg=[250,255,16,0];
    % Se calcula el cheksum y se coloca al final
    msg=[msg 256-mod(sum(msg(2:end)),256)];
    % Se envia por el puerto serie 
    if (xbus.puerto.BytesAvailable>0)
        % Vaciar el puerto 
        % OJO!!! Los datos se perderan
        disp(['>>> AVISO: Se descartaran ' int2str(xbus.puerto.BytesAvailable) ' datos']);
        fread(xbus.puerto, xbus.puerto.BytesAvailable,'uint8');
    end
    % El valor del TimeOut se fija a 1 segundo
    xbus.puerto.Timeout=1;
    fwrite(xbus.puerto,msg,'uint8','async');
    % Se espera a recibir la contestacion
    [ack,cnt,msg]=fread(xbus.puerto,5,'uint8');
    if (~isempty(msg))
        disp(msg);
        error('no se ha recibido respuesta al mensaje gotomeasurement');
    elseif (mod(sum(ack(2:end)),256)~=0)
        error('Error de checksum durante el comando gotomeasurement');
    elseif (ack(3)~=17)
                error('Error en la secuencia de mensajes durante el comando gotomeasurement');
    end
    leerXBusDatahandle=@leerXBusData;
    xbus.puerto.BytesAvailableFcn={leerXBusDatahandle, xbus};
end


% LEERXBUSDATA Lee datos desde el dispositivo Xbus Master
%Lee datos del buffer. Llamada por una callback
function leerXBusData(obj,event,XBusMaster) %#ok<INUSL>
    global SILOP_DATA_BUFFER;

    data=fread(obj,[XBusMaster.DataLength XBusMaster.nm],'uint8');
    % Procesar los datos de 1 mensaje
    %checksum
    if (any(mod(sum(data(2:end,:)),256)) )
        disp('>>>> ERROR de checksum durante la captura de datos');
    end
    % tipo de mensaje
    if (any(data(3,:)-50))
        disp('>>>> ERROR de tipo de mensaje durante la captura de datos');
    end
    % procesar la informacion
    muestra=([256 1]*data(5:6,:))';
    q=quantizer('Mode','single');
    SILOP_DATA_BUFFER=[];
    for k=1:XBusMaster.ns
        ax=hex2num(q,reshape(sprintf('%02X',data((7:10)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        ay=hex2num(q,reshape(sprintf('%02X',data((11:14)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        az=hex2num(q,reshape(sprintf('%02X',data((15:18)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        rx=hex2num(q,reshape(sprintf('%02X',data((19:22)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        ry=hex2num(q,reshape(sprintf('%02X',data((23:26)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        rz=hex2num(q,reshape(sprintf('%02X',data((27:30)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        mx=hex2num(q,reshape(sprintf('%02X',data((31:34)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        my=hex2num(q,reshape(sprintf('%02X',data((35:38)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        mz=hex2num(q,reshape(sprintf('%02X',data((39:42)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); 
        SILOP_DATA_BUFFER=[SILOP_DATA_BUFFER ax ay az rx ry rz mx my mz]; %#ok<AGROW>
    end
    SILOP_DATA_BUFFER=[muestra SILOP_DATA_BUFFER];
    disp(['leidos ' num2str([muestra(1) muestra(end)])])
end

