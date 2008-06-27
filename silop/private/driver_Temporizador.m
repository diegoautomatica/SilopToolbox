% DRIVER_Temporizador implementa todo el código necesario para el correcto
% funcionamiento de las simulaciones a partir de ficheros de log
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
%
% DRIVER_Temporizador implementa todo el código necesario para el correcto
% funcionamiento de las simulaciones a partir de ficheros de log
% No está pensado para llamarse por si mismo, sino para ser usado desde el
% sistema de captura de la toolbox.
%
% 
% Syntax: retorno=driver_Temporizador(operacion, parametros)
% 
% Output parameters:
%
% Examples:

function retorno=driver_Temporizador(operacion,parametros)

    switch operacion
        case 'create'
        case 'connect'
        case 'gotoconfig'
        case 'gotomeasurement'
            retorno=parametros;
            start(parametros);
        case 'destruye'
        otherwise
            disp('error, el driver no soporta la operación indicada');
            retorno=[];
    end
end