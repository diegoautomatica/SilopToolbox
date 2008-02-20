%% function Y=filtro1 (datos,orden,corte)
%%
%% Implementacion de un filtro paso bajo de fase 0
%%
%% ->...: Datos a filtrar, orden del filtro y frec de corte normalizada
%% Frecuencias normales: 0.05 para filtrar a 2.5Hz con los datos a 50
%% <- Y: datos filtrados.     

%% Ultima modificaci—n: JC, 18-may-06 -> comentarios

function Y=filtro0 (datos,orden,corte)

[b,a]=butter(orden,corte,'low');

Y=filtfilt(b,a,datos);

