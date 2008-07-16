% EVENTOSPIRAGUAS Detecta el evento principal de la palada (pala perpendicular al agua?)
% en base a la aceleración de avance de la piragua. Función Off-line
%
% EVENTOSPIRAGUAS Tomando como base las aceleraciones horizontales del COG de una piragua realiza un proceso de
% filtrado que le permite diferenciar cada palada. Actualmente se detecta
% un único evento por palada.
%
% Sintax: tiempos=eventospiraguas(AccHor,frecuencia)
%
% Parámetros de entrada:
%    AccHor        - vector con la aceleración antero-posterior
%    frecuencia    - entero indicando la frecuencia de muestreo
%
% Parámetros de salida:
%    tiempos: vector del mismo tamaño que los datos, con unos en las posiciones 
%             de los eventos y ceros el resto:
%             tiempos(:,1)=AccHor;
%             tiempos(:,2)=deteccion de palada
%
% Examples:
%
% See also:
%


% Historial de Modificaciones: 
% v1.0 Diego: Versión original 

function tiempos=eventospiraguas(AccHor,frecuencia)

if nargin<2
    frecuencia=100;
end

%%Estan reescaladas para comparar mas fácil con los eventos
tiempos(:,1)=AccHor;
tiempos(:,2)=0*AccHor;

%Puntos de palada
eventos=buscamaximosth(filtro0(AccHor,80,8/frecuencia),0);
tiempos(1:end-2,2)=eventos';


