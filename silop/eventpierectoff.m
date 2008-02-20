%
% EVENTPIERECTOFF Deteccion de los eventos con un giro sobre el pie
%
% EVENTPIERECTOFF Hace la deteccion offline de los eventos del paso al 
% caminar en linea recta, a partir de la señal de un giroscopo situado en 
% el pie, sobre el metatarso. La señal del giro se integra para medir el 
% angulo del pie en el plano sagital. 
% Parte de las ideas de [Sabatini05] con un giro situado sobre el tarso.
% 
% Syntax: [tiempos]=eventpierectoff(giroY,freq,th1,th2,th3)
% 
% Input parameters:
%   giroY       - Vector con la señal del giro en el metatarso en deg/s
%                   sin ninguna correccion.
%   freq        - frecuencia de muestreo de los datos anteriores (en Hzs)
%
% Output parameters:
%   tiempos     - Matriz con instantes donde hubo detecciones. Cada columna
%                   es un vector del mismo tamano que los datos del giro, 
%                   con unos en las posiciones donde se detectaron eventos 
%                   y ceros el resto. Las columnas devueltas son:
%                       tiempos(:,1)=deteccion de heel off, HO;
%                       tiempos(:,2)=deteccion de Final Contact, FC;
%                       tiempos(:,3)=deteccion de mid-swing, MW;
%                       tiempos(:,4)=deteccion de Initial Contact, IC;
%                       tiempos(:,5)=deteccion de foot flat, FF;
%                       tiempos(:,6)=giro filtrado
% Examples:
% % Obtencion de los eventos de la senal migiro:
% >> mistiempos=eventpierectoff(migiro)
%
% See also: revisa_experimento, eventpierecton

% Author:   Juan C. Alvarez
% History:  18.05.06    creacion del archivo
%                       deteccion de IC y FC
%           22.07.06    deteccion del MS

%% Dependencias: buscamaximos.

function tiempos=eventpierectoff(giroY,frecuencia,Ths)

% Set standard threshold parameters:
   ThStandard = [60, 20, 20, 160];
   % [th_ICyFC th_FF th_HO th_MW] en deg/s.

% Check input parameters
   % At least the first 2 input parameters are necessary
   if nargin < 2,  error('Not enough input parameters (at least 2 parameters - giro and freq)'); end
   % The 3er input parameter is optional, default
   if nargin < 3,  Ths = ThStandard; end

   % When too many thrsholds are contained in InitOpt, issue a warning and 
   % shorten the parameter vector
   if length(Ths) > length(ThStandard), 
      Ths = Ths(1:length(ThStandard)); 
      warning(' Too many parameters in Threshols! Thesholds was shortened.');
   end
   % At least the first 2 input parameters are necessary
   if length(Ths) < 4,  error('Not enough thesholds selected (at least [th_ICyFC th_FF th_HO th_MW])'); end
   
% inicializamos la matriz de tiempos a ceros, por si acaso:
tiempos=zeros(size(giroY,1),6);

% hacemos el filtro del giro propuesto por Sabatini[05]. 
% Es un filtro paso bajo de orden 2 de corte (6/50)*(100/2)=6 Hzs 
[b,a]=butter(2,6/50,'low'); 
Datos_filt=filtfilt(b,a,giroY); 
tiempos(:,6)=Datos_filt;   %% uso provisional de esta variable...


%% Deteccion de los eventos IC y FC, corresponden a los máximos negativos
% y pronunciados (th>60deg/s) primero y segundo que se van encontrando 
%
mins=[buscamaximosth(-Datos_filt,Ths(1))];
mins=find(mins==1);

% Actualizamos la matriz de tiempos con los eventos encontrados:
ii=0; iii=0;
for i=1:length(mins)
        if (mod(i,2)+1)==1
           iii=iii+1;
           ic(iii)=mins(i);
           tiempos(ic(iii),4)=1; %% IC
        end
        if mod(i,2)==1
            ii=ii+1;
            fc(ii)=mins(i);
            tiempos(fc(ii),2)=1; %% FC
        end
end


%% Deteccion del evento FF: a partir del IC, cuando el giro cae
% por debajo de un threshold (20 deg/s):
%
ii=0;
for i=1:(length(ic)),
    th1=0;
    for t=ic(i):(ic(i)+30),   %% en la duracion de un paso...
        if ((abs(Datos_filt(t))<Ths(2)) & (th1==0))
            ii=ii+1;
            ff(ii)=t;
            tiempos(ff(ii),5)=1; %% FF
            th1=1;
        end
    end
end


%% Deteccion del evento HO: a partir del FC, yendo hacia atras, 
% cuando el girodi cae por debajo de un threshold (20 deg/s)
%
ii=0;
for i=1:(length(fc)),
    th1=0;
    for t=fc(i):-1:(fc(i)-20),   %% en la duracion de un paso...
        if ((abs(Datos_filt(t))<Ths(3)) & (th1==0))
            ii=ii+1;
            ho(ii)=t;
            tiempos(ho(ii),1)=1; %% HO
            th1=1;
        end
    end
end


%% Deteccion del evento MW, el mas caracteristico del giroscopo en el pie. 
% Es un punto en medio de la fase de midswing (MW), que servira para distinguir
% entre pasos consecutivos. 
% Es el unico maximo positivo mayor de 160 deg/s:
% 
maxs=[buscamaximosth(Datos_filt,Ths(4))];
maxs=find(maxs==1);
% Actualizamos la matriz de tiempos con los eventos encontrados:
ii=0;
for i=1:length(maxs)
       	if (Datos_filt(maxs(i))>160)
            ii=ii+1;
            mw(ii)=maxs(i);
            tiempos(mw(ii),3)=1; %% MW
        end
end

%%---- FIN DEL ARCHIVO -----
