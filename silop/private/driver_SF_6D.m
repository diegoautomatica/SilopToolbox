% DRIVER_SF_6D implementa todo el código necesario para el correcto funcionamiento del dispositivo
% Sparkfun Bluetooth 6DoF  IMU. 
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
%
% DRIVER_SF_6D implementa todo el código necesario para el correcto funcionamiento del dispositivo
% Sparkfun Bluetooth 6DoF IMU. 
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
% 
% Syntax: retorno=driver_SF_6D(operacion, parametros)
% 
% Output parameters:
%
% Examples:

function [retorno,senhales]=driver_SF_6D(operacion,parametros)
    senhales=[];
    switch operacion
        case 'create'
            retorno=creasf6d(parametros);
        case 'connect'
            retorno=connectsf6d(parametros);
        case 'configura'
            [retorno,senhales]=configurasf6d(parametros);
        case 'gotoconfig'
            retorno=sf6dgotoconfig(parametros);
        case 'gotomeasurement'
            retorno=sf6dgotomeasurement(parametros);
        case 'destruye'
            retorno=[];
            destruyesf6d(parametros);
        otherwise
            disp('el driver no soporta la operación indicada');
            retorno=[];
    end
end

function sf6d=creasf6d(parametros)
    source=parametros{1};
    freq=parametros{2};
    if (freq~=83)
        error('La única frecuencia soportada son 83Hz');
    end
    updateeach=parametros{3};
    ns=parametros{4};
    driver_opt=parametros{5};
    if (length(driver_opt)<1)
        bps=57600;
    else
         bps=driver_opt(1);
         if (bps~=57600)
            error('bps no soportados por el dispositivo');
         end
    end
    if (length(driver_opt)<2)
        modo=0;
    else
        modo=driver_opt(2);
        if (modo~=0)
            error('el driver tiene un único modo de funcionamiento');
        end
    end
    % Calculamos el numero de muestras almacenadas en el buffer
    sf6d.freq=freq;
    sf6d.buffer=updateeach*freq;
    if (ns>1)
        error('Los sparkfun 6DoF sólo tienen un sensor, se han especificado demasiados IMUS')
    end
    try
        sf6d.puerto=serial(source);
    catch ME
        disp ('Imposible conectarse al puerto serie');
        rethrow (ME);
    end
    sf6d.modo=modo;
    switch (sf6d.modo)
        case 0,
            sf6d.Data=13;
            sf6d.DataLength=69;%bytes de cada mensaje
    end;
    sf6d.bps=bps;
end

function sf6d=connectsf6d(parametros)
    sf6d=parametros;
    % Configurar el objeto serie
    sf6d.puerto.BaudRate=sf6d.bps;
    sf6d.puerto.DataBits=8;
    sf6d.puerto.FlowControl='none';
    sf6d.puerto.Parity='none';
    sf6d.puerto.StopBits=1;
    sf6d.puerto.ReadAsyncMode = 'continuous';
    sf6d.puerto.ByteOrder = 'littleEndian';
    sf6d.puerto.BytesAvailableFcnCount = sf6d.DataLength*sf6d.buffer;
    sf6d.puerto.BytesAvailableFcnMode = 'byte';
    sf6d.puerto.InputBufferSize = 2*sf6d.DataLength*sf6d.buffer;
    sf6d.puerto.OutputBufferSize = 512;
    sf6d.puerto.Tag = 'SparkFun_6D';
    sf6d.puerto.Timeout = 10;
    fopen(sf6d.puerto);
end

function [sf6d,senhales]=configurasf6d(parametros)
    sf6d=parametros{1};
    senhales=parametros{2};
    sensor=2;
    disp('Los sparkfun 6DoF no soportan reorientacion por hardware');
    disp('el driver podria implementarla por software en el futuro');
    disp('se ignora la orientacion especificada mediante addimu');
    posiciones=fieldnames(senhales);
    senhales.(posiciones{sensor}).Pitch = 1;
    disp(['Anadida senhal ',posiciones{sensor},'.Pitch']); 
    senhales.(posiciones{sensor}).Pitch_2_5 = 2;
    disp(['Anadida senhal ',posiciones{sensor},'.Pitch_2_5']); 
    senhales.(posiciones{sensor}).Pitch_temp = 3;
    disp(['Anadida senhal ',posiciones{sensor},'.Pitch_temp']); 
    senhales.(posiciones{sensor}).Roll = 4;
    disp(['Anadida senhal ',posiciones{sensor},'.Roll']); 
    senhales.(posiciones{sensor}).Roll_2_5 = 5;
    disp(['Anadida senhal ',posiciones{sensor},'.Roll_2_5']); 
    senhales.(posiciones{sensor}).Roll_temp = 6;
    disp(['Anadida senhal ',posiciones{sensor},'.Roll_temp']); 
    senhales.(posiciones{sensor}).Yaw = 7;
    disp(['Anadida senhal ',posiciones{sensor},'.Yaw']); 
    senhales.(posiciones{sensor}).Yaw_2_5 = 8;
    disp(['Anadida senhal ',posiciones{sensor},'.Yaw_2_5']); 
    senhales.(posiciones{sensor}).Yaw_temp = 9;
    disp(['Anadida senhal ',posiciones{sensor},'.Yaw_temp']); 
    senhales.(posiciones{sensor}).Acc_X = 10;
    disp(['Anadida senhal ',posiciones{sensor},'.Acc_X']); 
    senhales.(posiciones{sensor}).Acc_Y = 11;
    disp(['Anadida senhal ',posiciones{sensor},'.Acc_Y']); 
    senhales.(posiciones{sensor}).Acc_Z = 12;
    disp(['Anadida senhal ',posiciones{sensor},'.Acc_Z']); 
    senhales.(posiciones{sensor}).Batt = 13;
    disp(['Anadida senhal ',posiciones{sensor},'.Batt']); 
    senhales.NUMEROSENHALES=13;
end


function sf6d=destruyesf6d(sf6d)

    try 
        fclose(sf6d.puerto);
    catch %#ok<CTCH>
    end
    delete(sf6d.puerto);
    clear sf6d
    sf6d=[];
end

function sf6d=sf6dgotoconfig(sf6d)
    %Limpiamos todo lo que puede quedar en el buffer de medidas anteriores
    sf6d.puerto.Timeout=1;
    while (sf6d.puerto.BytesAvailable>0)
        % Vaciar el puerto 
        % OJO!!! Los datos se perderan
        disp(['>>> AVISO: Se descartaran ' int2str(sf6d.puerto.BytesAvailable) ' datos']);
        fread(sf6d.puerto, sf6d.puerto.BytesAvailable,'uint8');
    end

    % Envia el mensaje de paso a config. Espacio en blanco
    % Cuerpo del mensaje
    msg=[' '];  %#ok<NBRAK>
    % Se envia por el puerto serie 
    fwrite(sf6d.puerto,msg,'uint8','async');
    pause(1);
    %Ya deberiamos estar en modo config.
    %comprobamos la respuesta.
    [ack,cnt,msg]=fread(sf6d.puerto, sf6d.puerto.BytesAvailable, 'uint8');
    if (~isempty(msg))
        error('no se ha recibido la respuesta al comando gotoconfig');
    else
        if (sum(ack(end-11:end))~=812) 
            sum(ack(end-11:end))
            error('Error de checksum durante gotoconfig');
        end
    end
end



%Funcion para el paso a modo medida
function sf6d=sf6dgotomeasurement(sf6d)
    global SILOP_DATA_BUFFER;
    SILOP_DATA_BUFFER=[];

    % Cuerpo del mensaje (excepto el byte de checksum)
    msg=[7];  %Poner el número de ^g
    % Se envia por el puerto serie 
    if (sf6d.puerto.BytesAvailable>0)
        % OJO!!! Los datos se perderan
        disp(['>>> AVISO: Se descartaran ' int2str(sf6d.puerto.BytesAvailable) ' datos']);
        fread(sf6d.puerto,sf6d.puerto.BytesAvailable,'uint8');
    end
    % El valor del TimeOut se fija a 2 segundos. si llegamos a el será debido a
    % un error
    sf6d.puerto.Timeout=2;
    fwrite(sf6d.puerto,msg,'uint8','async');
    fread(sf6d.puerto,15,'uint8');%eliminamos la cadena exiting...
    leersf6dDatahandle=@leersf6dData;
    sf6d.puerto.BytesAvailableFcn={leersf6dDatahandle, sf6d};
end


%Funcion para laeer los datos del puerto serie. Llamada por una callback
function leersf6dData(obj,event,sf6d)  %#ok<INUSL>
    global SILOP_DATA_BUFFER;

    [data,cnt,msg]=fread(obj,[sf6d.DataLength sf6d.buffer],'uint8');
    if (~isempty(msg))
        disp(msg);
        error('error en la lectura de datos');
    end
    % Procesar los datos de 1 mensaje
    if (any(data(1,:)-'A'))
        disp('>>>> ERROR durante la captura de datos. Perdida A inicial de trama');
    end
    if (any(data(67,:)-'Z'))
        disp('>>>> ERROR durante la captura de datos. perdida Z final de trama');
    end
    % procesar la informacion
    for k=1:sf6d.buffer
        texto=char(data(:,k));
        SILOP_DATA_BUFFER=[SILOP_DATA_BUFFER; (strread(texto,'%*[^ ]%d','whitespace','bnr'))']; %#ok<AGROW>
    
    end
    disp(['leidos ', num2str(sf6d.buffer), ' datos']);
end

