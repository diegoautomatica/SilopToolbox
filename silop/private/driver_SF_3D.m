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