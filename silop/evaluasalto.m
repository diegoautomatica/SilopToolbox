% EVALUASALTO Estima la duración de cada salto individual en función de los datos devueltos
% por eventossalto
%
% EVALUASALTO Tomando como base los resultados obtenidos por eventossalto, permite estimar
% las duraciones de cada salto individual, así como la altura del salto, y la energía asociada al mismo.
%
% Sintax: [duracion,altura,energia]=evaluasalto(tiempos, frecuencia, peso)
%
% Parámetros de entrada:
%    tiempos       - vector de eventos proporcionado por eventossalto
%    frecuencia    - entero indicando la frecuencia de muestreo. Por
%                    defecto vale 100Hz.
%    peso          - entero con la suma del peso del atleta y la masa levantada
%                    por defecto vale 75Kg
%
% Parámetros de salida:
%    duracion      - vector con la duración de cada salto (en segundos)
%    altura        - vector con la altura de cada salto (en metros)
%    energía       - vector con la energía aplicada en cada salto (en Julios)
%
% Examples:
%
% See also:
%


% Historial de Modificaciones: 
%  Desarrollado por Alberto Castañon.
%  Modificado por: Diego, 24-ene-07 -> adaptacion del codigo a siloptoolbox
%  Modificad por : Diego, 18-dic-07 -> adaptacion a v0.3 
%                  ampliado para indicar altura y energía.



function [duracion,altura,energia]=evaluasalto(tiempos,frecuencia,peso)

if (nargin<3)
    peso=75;
    if (nargin<2)
        frecuencia=100;
    end
end

inicios=find(tiempos(:,2)==1);
finales=find(tiempos(:,4)==1);

duracion=finales-inicios; %Duraciones medidas en n�mero de muestras
duracion=duracion/frecuencia; %Medidas en tiempos

if (nargout>1)
    altura=9.81*duracion.*duracion/8;
end
if (nargout>2)
    energia=peso*9.81*altura;
end
