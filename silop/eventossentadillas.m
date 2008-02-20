% EVENTOSSENTADILLAS Detecta 3 eventos a partir de las acelerariones verticales
% del COG durante las sentadillas
%
% EVENTOSSENTADILLAS Tomando como base las aceleraciones verticales del COG durante las sentadillas
% realiza un proceso de filtrado que le permite identificar cada una. Una vez detectada una
% sentadilla, realiza un proceso de detección para identificar los eventos de inicio, fin y punto medio
%
% Sintax: tiempos=eventossentadillas(AccVert,frecuencia)
%
% Parámetros de entrada:
%    AccVert       - vector con la aceleración vertical. Puede ser de una
%                    sentadilla o de varias. No puede tener medias sentadillas. Puede
%                    contener instantes de tiempo en los que se está
%                    estático, pero no los correspondientes a movimientos
%                    distintos de la sentadilla
%    frecuencia    - entero indicando la frecuencia de muestreo. Por
%                    defecto vale 100Hz.
%
% Parámetros de salida:
%    tiempos: vector del mismo tamaño que los datos, con unos en las posiciones 
%             de los eventos y ceros el resto:
%             tiempos(:,1)=AccVert;
%             tiempos(:,2)=deteccion de inicio de sentadilla
%             tiempos(:,3)=deteccion de punto medio
%             tiempos(:,4)=deteccion de fin de sentadilla
%
% Examples:
%
% See also:
%


% Historial de Modificaciones: 
%  Desarrollado por Alberto Castañon.
%  Modificado por: Diego, 24-ene-07 -> adaptacion del codigo a siloptoolbox
%  Modificad por : Diego, 18-dic-07 -> adaptacion a v0.3 



function tiempos=eventossentadillas(AccVert,frecuencia)

if (nargin<2)
	frecuencia=100;
end

%filtro esos datos de aceleracion para evitar excesivos pico y facilitar el
%cálculo del número de sentadillas
acel_filt=filtro0(AccVert,60,2*2.5/frecuencia);

% Busca el número de máximos que se producen durante las  mediciones y que
% sean superiores a 11
maximos=buscamaximosth(acel_filt,11);
ind_max=find(maximos==1)+1;
% Obtiene el número definitivo de saltos
num_sentadillas=length(ind_max);

%Obtengo el minimo donde se logra la maxima velocidad durante el descenso
%de la sentadilla, eliminando los menores si hay mas de uno
for i=1:num_sentadillas
    datos_exc=-acel_filt(ind_max(i)-100:ind_max(i));
    min_ini=buscamaximosth(datos_exc,-9.5);
    ind_min_ini=find(min_ini==1)+ind_max(i)-100;
    if length(ind_min_ini)>1
        ind_minimo=ind_min_ini(1);
        for j=2:length(ind_min_ini)
            if acel_filt(ind_minimo)>acel_filt(ind_min_ini(j))
                ind_minimo=ind_min_ini(j);
            end
        end
        ind_min_ini=ind_minimo;
    end
    ind_inicio(i)=2*ind_min_ini - ind_max(i);
end
ind_inicio=ind_inicio
            


%Obtiene los puntos correspondientes a fin de santadilla atrasando un
%tiempo determinado desde el maximo identificador de sentadilla
ind_fin=ind_max +40;

% Ahora creo una matriz de eventos colocando las aceleraciones en la primera columna,
% los minimos hallados al principio en una columna, los pasos por g en otra,
% los maximos finales en la cuarta y los minimos cercanos a ellos en la quinta.
tiempos(:,1)=AccVert;
tiempos(:,2)=0*AccVert;
tiempos(:,3)=0*AccVert;
tiempos(:,4)=0*AccVert;
for n=ind_inicio
	tiempos(n,2)=1;
end
for n=ind_max
	tiempos(n,3)=1;
end
for n=ind_fin
	tiempos(n,4)=1;
end
