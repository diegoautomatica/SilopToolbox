% DRIVER_SF_3D implementa todo el código necesario para el correcto funcionamiento del dispositivo
% Sparkfun Serial 3D accelerometer. 
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
%
% DRIVER_SF_3D implementa todo el código necesario para el correcto funcionamiento del dispositivo
% Sparkfun Serial 3D accelerometer. 
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
% 
% Syntax: retorno=driver_SF_3D(operacion, parametros)
% 
% Output parameters:
%
% Examples:

function [retorno,senhales]=driver_SF_3D(operacion,parametros)
    senhales=[];
    switch operacion
        case 'create'
            retorno=creasf3d(parametros);
        case 'connect'
            retorno=connectsf3d(parametros);
        case 'configura'
            [retorno,senhales]=configurasf3d(parametros);
        case 'gotoconfig'
            retorno=sf3dgotoconfig(parametros);
        case 'gotomeasurement'
            retorno=sf3dgotomeasurement(parametros);
        case 'destruye'
            retorno=[];
            destruyesf3d(parametros);
        otherwise
            disp('error, el driver no soporta la operación indicada');
            retorno=[];
    end
end

function sf3d=creasf3d(parametros)
    source=parametros{1};
    freq=parametros{2};
    updateeach=parametros{3};
    ns=parametros{4};
    driver_opt=parametros{5};
    if (length(driver_opt)<1)
        bps=9600;
    else
         bps=driver_opt(1);
    end
    if (length(driver_opt)<2)
        modo=0;
    else
        modo=driver_opt(2);
    end
    % Calculamos el numero de muestras almacenadas en el buffer
    sf3d.freq=freq;
    sf3d.buffer=updateeach*freq;
    if (ns>1)
        error('Los sparkfun 3D sólo tienen un sensor, se han especificado demasiados IMUS')
    end
    try
        sf3d.puerto=serial(source);
    catch ME
        disp ('Imposible conectarse al puerto serie');
        rethrow (ME);
    end
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
end

function sf3d=connectsf3d(parametros)
    sf3d=parametros;
    % Configurar el objeto serie
    sf3d.puerto.BaudRate=sf3d.bps;
    sf3d.puerto.DataBits=8;
    sf3d.puerto.FlowControl='none';
    sf3d.puerto.Parity='none';
    sf3d.puerto.StopBits=1;
    sf3d.puerto.ReadAsyncMode = 'continuous';
    sf3d.puerto.ByteOrder = 'littleEndian';
    sf3d.puerto.BytesAvailableFcnCount = sf3d.DataLength*sf3d.buffer;
    sf3d.puerto.BytesAvailableFcnMode = 'byte';
    sf3d.puerto.InputBufferSize = 2*sf3d.DataLength*sf3d.buffer;
    sf3d.puerto.OutputBufferSize = 512;
    sf3d.puerto.Tag = 'SparkFun_3D';
    sf3d.puerto.Timeout = 10;
    fopen(sf3d.puerto);
end

function [sf3d,senhales]=configurasf3d(parametros)
    sf3d=parametros{1};
    senhales=parametros{2};
    sf3d=sf3dsetperiod(sf3d);
    numero=2;
    disp('Los sparkfun 3d no soportan reorientacion por hardware');
    disp('el driver podria implementarla por software en el futuro');
    disp('se ignora la orientacion especificada mediante addimu');
    posiciones=fieldnames(senhales);
    senhales.(posiciones{numero}).Acc_Z = 3;
    disp(['Anadida senhal ',posiciones{sensor},'.Acc_Z']); 
    senhales.(posiciones{numero}).Acc_Y = 2;
    disp(['Anadida senhal ',posiciones{sensor},'.Acc_Y']); 
    senhales.(posiciones{numero}).Acc_X = 1;
    disp(['Anadida senhal ',posiciones{sensor},'.Acc_X']); 
    senhales.NUMEROSENHALES=3;
end


function sf3d=destruyesf3d(sf3d)

    try 
        fclose(sf3d.puerto);
    catch %#ok<CTCH>
    end
    delete(sf3d.puerto);
    clear sf3d
    sf3d=[];
end

function sf3d=sf3dgotoconfig(sf3d)
    %Limpiamos todo lo que puede quedar en el buffer de medidas anteriores
    sf3d.puerto.Timeout=1;
    while (sf3d.puerto.BytesAvailable>0)
        % Vaciar el puerto 
        % OJO!!! Los datos se perderan
        disp(['>>> AVISO: Se descartaran ' int2str(sf3d.puerto.BytesAvailable) ' datos']);
        fread(sf3d.puerto, sf3d.puerto.BytesAvailable,'uint8');
    end

    % Envia el mensaje de paso a config. Codigo hexadecimal 13
    % Cuerpo del mensaje
    msg=[hex2dec('13')]; %#ok<NBRAK>
    % Se envia por el puerto serie 
    fwrite(sf3d.puerto,msg,'uint8','async');
    pause(1);
    %Ya deberiamos estar en modo config.
    %comprobamos la respuesta.
    [ack,cnt,msg]=fread(sf3d.puerto, sf3d.puerto.BytesAvailable, 'uint8');
    if (~isempty(msg))
        error('no se ha recibido la respuesta al comando gotoconfig');
    else
        if (sum(ack(end-11:end))~=859)
            error('Error de checksum durante gotoconfig');
        end
    end
end



%Funcion para el paso a modo medida
function sf3d=sf3dgotomeasurement(sf3d)
    global SILOP_DATA_BUFFER;
    SILOP_DATA_BUFFER=[];

    % Cuerpo del mensaje (excepto el byte de checksum)
    msg='x';
    % Se envia por el puerto serie 
    if (sf3d.puerto.BytesAvailable>0)
        % OJO!!! Los datos se perderan
        disp(['>>> AVISO: Se descartaran ' int2str(sf3d.puerto.BytesAvailable) ' datos']);
        fread(sf3d.puerto,sf3d.puerto.BytesAvailable,'uint8');
    end
    % El valor del TimeOut se fija a 2 segundos. si llegamos a el será debido a
    % un error
    sf3d.puerto.Timeout=2;
    fwrite(sf3d.puerto,msg,'uint8','async');
    leersf3dDatahandle=@leersf3dData;
    sf3d.puerto.BytesAvailableFcn={leersf3dDatahandle, sf3d};
end


%Funcion para laeer los datos del puerto serie. Llamada por una callback
function leersf3dData(obj,event,sf3d)  %#ok<INUSL>
    global SILOP_DATA_BUFFER;

    [data,cnt,msg]=fread(obj,[sf3d.DataLength sf3d.buffer],'uint8');
    if (~isempty(msg))
        disp(msg);
        error('error en la lectura de datos');
    end
    % Procesar los datos de 1 mensaje
    if (any(data(2,:)-'X'))
        disp('>>>> ERROR durante la captura de datos');
    end
    if (any(data(11,:)-'Y'))
        disp('>>>> ERROR durante la captura de datos');
    end
    if (any(data(20,:)-'Z'))
        disp('>>>> ERROR durante la captura de datos');
    end
    % procesar la informacion
    for k=1:sf3d.buffer
        ax=9.8*str2double(char(data(  4:  9,k)));
        ay=9.8*str2double(char(data(13:18,k)));
        az=9.8*str2double(char(data(22:27,k)));
        SILOP_DATA_BUFFER=[SILOP_DATA_BUFFER; ax ay az]; %#ok<AGROW>
    end
    disp('leido un segundo de datos');
end


function sf3d=sf3dsetperiod(sf3d)

    freq=sf3d.freq;
    if (sf3d.puerto.BytesAvailable>0)
        disp(['>>> AVISO: Se descartaran ' int2str(sf3d.puerto.BytesAvailable) ' datos']);
        fread(sf3d.puerto, sf3d.puerto.BytesAvailable,'uint8');
    end
    % Cuerpo del mensaje 
    msg='3';
    fwrite(sf3d.puerto,msg,'uint8','async');
    % Se espera a recibir la contestacion
    [ack,cnt,msg]=fread(sf3d.puerto,78,'uint8');
    if (~isempty(msg))
        disp(msg);
        error('no se ha recibido respuesta al comando setperiod');
    end
    if (sf3d.puerto.BytesAvailable>0)
        fread(sf3d.puerto, sf3d.puerto.BytesAvailable,'uint8');
    end
    ack=ack(end-10:end-1);%Me quedo con los 10 penultimos, que se parecen al resto de respuestas
    if ack(10)=='H'
        %solo dos cifras
        frecuencia=str2double(char(ack(8:9)));
    else
        %tres cifras
        frecuencia=str2double(char(ack(8:10)));
    end
    while (frecuencia~=freq)
        if (frecuencia>freq)
            msg='-';
        else
            msg='+';
        end
        fwrite(sf3d.puerto,msg,'uint8','async');
        % Se espera a recibir la contestacion
        [ack,cnt,msg]=fread(sf3d.puerto,10,'uint8');
        if (~isempty(msg))
            disp(msg);
            error('no se ha recibido respuesta al cambiar la frecuencia de muestreo');
        end
        if (sf3d.puerto.BytesAvailable>0)
            fread(sf3d.puerto, sf3d.puerto.BytesAvailable,'uint8');
        end
        if ack(8)=='H'
            %solo dos cifras
            frecuencia=str2double(char(ack(6:7)));
        else
            %tres cifras
            frecuencia=str2double(char(ack(6:8)));
        end
    end
    %Salimos del modo de frecuencia
    msg='x';
    fwrite(sf3d.puerto,msg,'uint8','async');
    [ack,cnt,msg]=fread(sf3d.puerto, 196,'uint8');
    if (~isempty(msg))
        disp(msg);
        error('no se ha recibido respuesta al salir del ajuste de frecuencia');
    end
    if (sf3d.puerto.BytesAvailable>0)
        fread(sf3d.puerto, sf3d.puerto.BytesAvailable,'uint8');
    end
end