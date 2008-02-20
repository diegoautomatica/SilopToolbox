% EVALUASENTADILLAS Calcula los parámetros más relevantes de un conjunto de sentadillas en función de los datos devueltos
% por eventossentadillas
%
% EVALUASENTADILLAS Tomando como base los resultados obtenidos por eventossentadillas, permite estimar
% el desplazamiento realizado, así como las velocidades, fuerzas y potencias medias y máximas de cada sentadilla
%
% Sintax: 
% [desplazamiento,velmax,velmed,fmax,fmed,potmax,potmed]=evaluasentadillas(tiempos,frecuencia,peso)
%
% Parámetros de entrada:
%    tiempos       - vector de eventos proporcionado por eventossentadillas
%    frecuencia    - entero indicando la frecuencia de muestreo. Por
%                    defecto vale 100Hz.
%    peso          - entero con la suma del peso del atleta y la masa levantada
%                    por defecto vale 75Kg
%
% Parámetros de salida:
%    desplazamiento - vector con el desplazamiento correspondiente a cada sentadilla(en metros)
%    velmax         - matriz nx2 con las velocidades máximas de cada sentadilla (excéntrica y concéntrica)
%    velmed         - matriz nx2 con las velocidades medias de cada sentadilla (excéntrica y concéntrica)
%    fmax           - matriz nx2 con las fuerzas máximas de cada sentadilla (excéntrica y concéntrica)
%    fmed           - matriz nx2 con las fuerzas medias de cada sentadilla (excéntrica y concéntrica)
%    potmax         - matriz nx2 con las potencias máximas de cada sentadilla (excéntrica y concéntrica)
%    potmed         - matriz nx2 con las potencias medias de cada sentadilla (excéntrica y concéntrica)
%
% Examples:
% Detectamos los eventos de un grupo de saltos y representamos gráficamente los resultados.
% >> tiempos=eventossentadillas(datos,50);
% >> evaluasentadillas(tiempos,50)
%
% See also: eventossentadillas
%


% Historial de Modificaciones: 
%  Desarrollado por Alberto Castañon.
%  Modificado por: Diego, 24-ene-07 -> adaptacion del codigo a siloptoolbox
%  Modificad por : Diego, 18-dic-07 -> adaptacion a v0.3 
%                  ampliado para indicar velocidades, fuerzas y potencias. 
%  Modificado por: Incorporado correctamente a la toolbox. Se colo una versiónantigua en la 0.3

%las distancias descendidas en las sentadillas
function [desplazamiento,velmax, velmed, fmax, fmed, potmax, potmed]=evaluasentadillas(tiempos,frecuencia,peso)

if (nargin<3)
   peso=75;
   if (nargin<2)
	frecuencia=100;
   end
end

frec=frecuencia;

aceleracion=tiempos(:,1);

ind_inicio=find(tiempos(:,2)==1);
ind_fin=find(tiempos(:,4)==1);
num_sent=length(ind_inicio);

%Los puntos dados por los vectores ind_inicio e ind_fin son el principio y 
%el fin de la sentadilla, obtenidos en la funcion de detectar eventos de
%sentadilla
velocidad(1:ind_inicio(1))=zeros(ind_inicio(1),1);
for i=1:num_sent
    velocidad(ind_inicio(i):ind_fin(i))=[cumsum(aceleracion(ind_inicio(i):ind_fin(i))-mean(aceleracion(ind_inicio(i):ind_fin(i))))/frec];
    if i<num_sent
        velocidad(ind_fin(i):ind_inicio(i+1))=[zeros(ind_inicio(i+1)-ind_fin(i)+1,1)];
    end
end
velocidad=velocidad';

posicion(1:ind_inicio(1))=zeros(ind_inicio(1),1);
for i=1:num_sent
    posicion(ind_inicio(i):ind_fin(i))=[cumsum(velocidad(ind_inicio(i):ind_fin(i))-mean(velocidad(ind_inicio(i):ind_fin(i))))/frec];
    if i<num_sent
        posicion(ind_fin(i):ind_inicio(i+1))=[zeros(ind_inicio(i+1)-ind_fin(i)+1,1)];
    end
end
posicion=posicion';

fuerza=peso*aceleracion(1:length(velocidad))-mean(aceleracion);
potencia=fuerza.*velocidad;


%Se dibujaran las graficas de aceleracion, velocidad y posicion en cada
%instante en las sentadillas
if (nargout<1)
   subplot(5,1,1), plot(aceleracion(1:length(velocidad))); title('aceleración');
   hold on;
   subplot(5,1,2), plot(velocidad); title('velocidad');
   subplot(5,1,3), plot(posicion); title('desplazamiento');
   subplot(5,1,4), plot(fuerza); title('fuerza');
   subplot(5,1,5), plot(potencia); title('potencia');
end


%Se va a hallar un vector con la distancias descendidas en cada una de las
%sentadillas, para lo cual se invertira el vector de posiciones y se
%calcularan los máximos
posicion_aux=-posicion;
minimos=buscamaximosth(posicion_aux,0.01);
ind_dist=find(minimos==1)+1;
tam=length(ind_dist);
for i=1:tam
    dist(i)=posicion(ind_dist(i));
end

% Se hallan las velocidades, fuerzas y potencias medias de los movimientos
% excentricos y concentricos

for i=1:num_sent
    veloc_exc(i)=sum(velocidad(ind_inicio(i):ind_dist(i)))/(ind_dist(i)-ind_inicio(i)+1);
    veloc_max_exc(i)=max(abs(velocidad(ind_inicio(i):ind_dist(i))));
    veloc_conc(i)=sum(velocidad(ind_dist(i):ind_fin(i)))/(ind_fin(i)-ind_dist(i)+1);
    veloc_max_conc(i)=max(abs(velocidad(ind_dist(i):ind_fin(i))));
end

for i=1:num_sent
    fuerza_exc(i)=sum(fuerza(ind_inicio(i):ind_dist(i)))/(ind_dist(i)-ind_inicio(i)+1);
    fuerza_max_exc(i)=max(abs(fuerza(ind_inicio(i):ind_dist(i))));
    fuerza_conc(i)=sum(fuerza(ind_dist(i):ind_fin(i)))/(ind_fin(i)-ind_dist(i)+1);
    fuerza_max_conc(i)=max(abs(fuerza(ind_dist(i):ind_fin(i))));
end

for i=1:num_sent
    potencia_exc(i)=sum(potencia(ind_inicio(i):ind_dist(i)))/(ind_dist(i)-ind_inicio(i)+1);
    potencia_max_exc(i)=max(abs(potencia(ind_inicio(i):ind_dist(i))));
    potencia_conc(i)=sum(potencia(ind_dist(i):ind_fin(i)))/(ind_fin(i)-ind_dist(i)+1);
    potencia_max_conc(i)=max(abs(potencia(ind_dist(i):ind_fin(i))));
end

desplazamiento=dist;
velmax=[veloc_max_exc,veloc_max_conc];
velmed=[veloc_exc,veloc_conc];
fmax=[fuerza_max_exc,fuerza_max_conc];
fmed=[fuerza_exc,fuerza_conc];
potmax=[potencia_max_exc,potencia_max_conc];
potmed=[potencia_exc,potencia_conc];

