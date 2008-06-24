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

function retorno=driver_SF_3D(operacion,parametros)

    switch operacion
        case 'create'
        case 'connect'
        case 'gotoconfig'
        case 'gotomeasurement'
            retorno=sf3dgotomeasurement(parametros);
        case 'destruye'
        otherwise
            disp('error, el driver no soporta la operación indicada');
            retorno=[];
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