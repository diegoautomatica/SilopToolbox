% FRECUENCIAPALADAS Devuelve una señal con la frecuencia de palada. 
%
% FRECUENCIAPALADAS En base a un vector en el que esten marcados los instantes de palada,
% calcula las frecuencias de cada una.
%
% Sintax: frecuencias=frecuenciapaladas(tiempos, freq)
%
% Parámetros de entrada:
%    tiempos       - vector con unos en los puntos donde se detecto la
%                    palada y ceros en el resto
%    freq          - entero indicando la frecuencia de muestreo
%
% Parámetros de salida:
%    frecuencias   - vector con la frecuencia de paladas
%
% Examples:
%
% See also:
%


% Historial de Modificaciones: 
% v1.0 Diego: Versión original 

function frecuencias=frecuenciapaladas(tiempos,freq)

if (nargin<2)
    freq=100;
end
indices=find(tiempos);
frecuencias=60*freq./(indices(2:end)-indices(1:end-1));
