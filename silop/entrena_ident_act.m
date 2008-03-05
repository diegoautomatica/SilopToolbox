% ENTRENA_IDENT_ACT permite entrenar una red neuronal que identificar� las actividades realizadas por un individuo.
%
% ENTRENA_IDENT_ACT Ajusta los par�metros de una red neuronal para que realice la identificaci�n del movimiento realizado por
% un individuo, en base a un conjunto de datos patr�n previamente capturados. La frecuencia de muestreo debe ser OBLIGATORIAMENTE de 
% 50Hz
%
% Sintax:
% [redneuronal,parametros]=entrena_ident_act(datos_bajarescaleras,datos_bajarrampa,datos_andar,datos_subirrampa,datos_subirescaleras)
%
% Par�metros de entrada:
%    datos_bajarescaleras  - variable tipo cell array dentro de la cu�l cada uno
%                           de los elementos es una matriz con los datos correspondientes a 
%                           un tramo en el que el individuo se encontraba bajando escaleras.
%    datos_bajarrampa      - variable tipo cell array dentro de la cu�l cada uno
%                           de los elementos es una matriz con los datos correspondientes a
%                           un tramo en el que el individuo se encontraba bajando una rampa.
%    datos_andar           - variable tipo cell array dentro de la cu�l cada uno
%                           de los elementos es una matriz con los datos correspondientes a
%                           un tramo en el que el individuo se encontraba andando.
%    datos_subirrampa      - variable tipo cell array dentro de la cu�l cada uno
%                           de los elementos es una matriz con los datos correspondientes a
%                           un tramo en el que el individuo se encontraba subiendo una rampa.
%    datos_subirescaleras  - variable tipo cell array dentro de la cu�l cada uno
%                           de los elementos es una matriz con los datos correspondientes a 
%                           un tramo en el que el individuo se encontraba subiendo escaleras.
%	Cada una de las matrices de datos que se encuentran en las variables cell array
%   	tiene que tener al menos 256 filas (muestras) y 4 columnas.
%   	Las columnas de estas matrices se corresponden con las habitualmente disponibles en los Xsens
%   		1: El tiempo
%   		2: La aceleraci�n en el eje x
%	   	3: La aceleraci�n en el eje y
%   		4: La aceleraci�n en el eje z
%   		5: Gir�scopo en el eje x (opcional)
%   		6: Gir�scopo en el eje y (opcional)
%   		7: Gir�scopo en el eje z (opcional)
%   		8: Campo magn�tico en el eje x (opcional)
%   		9: Campo magn�tico en el eje y (opcional)
%   		10: Campo magn�tico en el eje z (opcional)
%
%
% Par�metros de salida:
%    redneuronal   - Variable que tiene almacenada la red neuronal
%    parametros    - Variable con datos genericos sobre la se�al, necesarios para ident_act.
%
% Examples:
% 
% See also: ident_act

% Author:   Jes�s E. P�rez Villegas 
% History:  20.11.2007  Fichero creado.
%           28.12.2007  Preparaci�n para la toolbox
%           03.01.2008  Adaptada correctamente a la toolbox. (Diego)
%           21.01.2008  Incluye anidada s_separardatosvector() y s_tomardatosfichero()
%                       Usa energiawavelet en lugar de s_calculaenergiawavelet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [redneuronal,parametros]=entrena_ident_act(datos_bajarescaleras,datos_bajarrampa,datos_andar,datos_subirrampa,datos_subirescaleras)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hallar los valores medios de las aceleraciones
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Llamada al programa que tratar� los datos almacenados en el fichero
[tiempo,aceleracionx,aceleraciony,aceleracionz]=s_tomardatosfichero(datos_andar{1,1});

datos1=[aceleracionx;aceleraciony;aceleracionz]';
datos2=datos1;
R=[3 -2 1];
    
datos_c=ejes_anatomicos(datos1,datos2,R);
    
datos_c=datos_c';
aceleracionejesmodifx=datos_c(1,:);
aceleracionejesmodify=datos_c(2,:);
aceleracionejesmodifz=datos_c(3,:);

%longitudmedida=length(tiempo);
valormediox=mean(aceleracionejesmodifx);
valormedioy=mean(aceleracionejesmodify);
valormedioz=mean(aceleracionejesmodifz);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matriztotal=[];
matrizresultadoacciones=[];

iteraciones=size(datos_bajarescaleras,2)+size(datos_bajarrampa,2)+size(datos_andar,2)+size(datos_subirrampa,2)+size(datos_subirescaleras,2);
liminf1=1; limsup1=size(datos_bajarescaleras,2);
liminf2=1+size(datos_bajarescaleras,2);
limsup2=size(datos_bajarescaleras,2)+size(datos_bajarrampa,2);
liminf3=1+size(datos_bajarescaleras,2)+size(datos_bajarrampa,2);
limsup3=size(datos_bajarescaleras,2)+size(datos_bajarrampa,2)+size(datos_andar,2);
liminf4=1+size(datos_bajarescaleras,2)+size(datos_bajarrampa,2)+size(datos_andar,2);
limsup4=size(datos_bajarescaleras,2)+size(datos_bajarrampa,2)+size(datos_andar,2)+size(datos_subirrampa,2);
liminf5=1+size(datos_bajarescaleras,2)+size(datos_bajarrampa,2)+size(datos_andar,2)+size(datos_subirrampa,2);



for indice=1:iteraciones
    if indice>=liminf1 && indice<=limsup1
        matrizamedir=datos_bajarescaleras{1,indice-liminf1+1};
        accion=1;
    elseif indice>=liminf2 && indice<=limsup2
        matrizamedir=datos_bajarrampa{1,indice-liminf2+1};
        accion=2;
    elseif indice>=liminf3 && indice<=limsup3
        matrizamedir=datos_andar{1,indice-liminf3+1};
        accion=3;
    elseif indice>=liminf4 && indice<=limsup4
        matrizamedir=datos_subirrampa{1,indice-liminf4+1};
        accion=4;
    else
        matrizamedir=datos_subirescaleras{1,indice-liminf5+1};
        accion=5;
    end


    [tiempo,aceleracionx,aceleraciony,aceleracionz]=s_tomardatosfichero(matrizamedir);
    
    
    datos2=[aceleracionx;aceleraciony;aceleracionz]';
    datos_c=ejes_anatomicos(datos2,datos1,R);
    
    datos_c=datos_c';
    acejesmodx=datos_c(1,:);
    acejesmody=datos_c(2,:);
    acejesmodz=datos_c(3,:);
    
    aceleracionx=acejesmodx/valormediox;
    aceleraciony=acejesmody/valormedioy;
    aceleracionz=acejesmodz/valormedioz;
    
    
    longitudmedida=length(tiempo);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Se hallan los datos de los vectores de aceleraci�n
	%Tmuestreo=tiempo(2)-tiempo(1);   % Tiempo de muestreo (en segundos)
	%Frecmuestreo=1/Tmuestreo;        % Frecuencia de muestreo (en Hz)
	L = 128;                         % Longitud de la se�al a tratar
	%t = (0:L-1)*Tmuestreo;           % Vector de tiempo

    %La Frecuencia de muestreo ha de ser al menos el doble de la frecuencia
    %m�xima a estudiar
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %En el caso de que el individuo se encuentre subiendo o bajando
    %escaleras se tomar�n datos desde la muestra en t=0,64 segundos hasta
    %la muestra en t=tiempototal-0,64 segundos.
    %En el resto de los casos las muestras con las que se entrenar� la red
    %neuronal se tomar�n desde t=1,28 segundos hasta
    %t=tiempototal-1,28 segundos.
    if accion~=1 && accion~=5
        i=1+L/2;
        limite=3*L/2;
    else
        i=L/4;
        limite=5*L/4;
    end
    %Se considera la primera muestra err�nea y por eso no se contabilizar�

    while i <= longitudmedida+1-limite
        %La �ltima muestra tambi�n se considerar� err�nea y por eso tampoco
        %se tomar�
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Llamada a subrutina que se encargar� de tomar los datos principales
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [tiempobucle,acelxbucle,acelybucle,acelzbucle]=s_separardatosvector(tiempo,aceleracionx,aceleraciony,aceleracionz,i);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Llamada a la subrutina encargada de la descomposici�n de paquetes
        %wavelet.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [energiawaveletx,desvstdwaveletx,valorRMSwaveletx]=energiawavelet(acelxbucle);
        [energiawavelety,desvstdwavelety,valorRMSwavelety]=energiawavelet(acelybucle); %#ok<NASGU>
        [energiawaveletz,desvstdwaveletz,valorRMSwaveletz]=energiawavelet(acelzbucle);


        matrizdatos=[energiawaveletx energiawavelety energiawaveletz];
        matrizdatos=[matrizdatos desvstdwaveletx desvstdwavelety desvstdwaveletz]; %#ok<AGROW>
		matrizdatos=[matrizdatos valorRMSwaveletx valorRMSwaveletz]; %#ok<AGROW>
        %El valorRMSwavelety no se usar� ya que esos valores en esa
        %direcci�n del espacio (medio-lateral) resultan in�tiles.
        
        matriztotal=[matriztotal ; matrizdatos]; %#ok<AGROW>
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Creacion de la matriz objetivo
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Se les da valores normalizados, entre -1 y 1
        if (accion==1) 
            vectoraccion=[1 -1 -1 -1 -1]; 
        end
        if (accion==2) 
            vectoraccion=[-1 1 -1 -1 -1]; 
        end
        if (accion==3) 
            vectoraccion=[-1 -1 1 -1 -1]; 
        end
        if (accion==4) 
            vectoraccion=[-1 -1 -1 1 -1]; 
        end
        if (accion==5) 
            vectoraccion=[-1 -1 -1 -1 1]; 
        end

        matrizresultadoacciones=[matrizresultadoacciones; vectoraccion]; %#ok<AGROW>
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        i=i+L/2; %De esta forma se avanza superponiendo ventanas
    end
    
end


matriztotal=matriztotal';
matrizresultadoacciones=matrizresultadoacciones';
size(matriztotal)
size(matrizresultadoacciones)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Normalizacion de las matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[matriztotaln,minmatriztotal,maxmatriztotal]=premnmx(matriztotal);

% minmatriztotal=minmatriztotal/1.5;
% maxmatriztotal=maxmatriztotal*1.5;


%No es necesario hacer uso del comando premnmx para matrizresultadoacciones
%puesto que ya se encuentra entre los valores -1 y 1 (ya est� normalizado)
[matrizresultadoaccionesn,minmatrizresultadoacciones,maxmatrizresultadoacciones]=premnmx(matrizresultadoacciones); %#ok<NASGU>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


mtotalnor=matriztotaln;
maccionesnor=matrizresultadoaccionesn;
minmtotalnor=minmatriztotal;
maxmtotalnor=maxmatriztotal;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creaci�n de la red neuronal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creaci�n de la matriz con los m�nimos y los m�ximos
% matrizminmax=[(min(mtotalnor'))' (max(mtotalnor'))'];

matrizminmax=[(min(mtotalnor'*1.5))' (max(mtotalnor'*1.5))'];

%Vector con el n�mero de neuronas: 10 en la 1� y 2� capas y 5 en la 3�
nneuronas=[10 10 5];

redneuronal=newff(matrizminmax, nneuronas, {'tansig' 'tansig' 'tansig'},'traingdx');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Entrenamiento de la red neuronal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redneuronal.trainParam.epochs=8000;      %Se realizar�n 1000 pasadas
redneuronal.trainParam.show=25;          %Cada 25 pasadas se realizar� un display
%redneuronal.trainParam.goal=1e-5;       %Precisi�n del objetivo
%redneuronal.trainParam.min_grad=0;      %Gradiente m�nimo

redneuronal=train(redneuronal,mtotalnor,maccionesnor);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Almacenamiento de la red neuronal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Se guardar� la variable redneuronal en el fichero red_XXXX.mat, siendo
%XXXX la cadena almacenada en la variable indiv (que en estos casos siempre
%es el nombre de la persona cuyos datos ayudan a generar la red neuronal.
%Gracias a esta forma ya se tendr� salvada la variable para su utilizaci�n
%en otros programas.

% fichero=['./redneuronal/red_',individuo,'.mat'];
% save(fichero,'redneuronal','minmtotalnor','maxmtotalnor');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parametros={maxmtotalnor,minmtotalnor,valormediox,valormedioy,valormedioz,datos1};
%    maxmtotalnor  - Un vector con los m�ximos que pose�an las variables
%                    antes de ser normalizadas.
%    minmtotalnor  - Un vector con los m�nimos que pose�an las variables
%                    antes de ser normalizadas.
%    valormediox   - El valor medio de la se�al de aceleraci�n en el eje x
%    valormedioy   - El valor medio de la se�al de aceleraci�n en el eje y
%    valormedioz   - El valor medio de la se�al de aceleraci�n en el eje z
%    datos1        - Valores necesarios para la correcci�n de los ejes
%                    anat�micos.






%Funci�n anidada
%Divide  los vectores de aceleracion y de tiempo en intervalos de 128 muestras
function [tbucle,acelxbucle,acelybucle,acelzbucle]=s_separardatosvector(t,acelx,acely,acelz,i)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%s_separardatosvector
%Programa que se encarga de dividir los vectores de aceleracion y de tiempo
%en intervalos de 128 muestras

%Entrada:
%t->Vector de tiempo.
%acelx->Vector de aceleraciones en el eje x
%acely->Vector de aceleraciones en el eje y
%acelz->Vector de aceleraciones en el eje z

%Salida:
%tbucle->Vector de tiempo en el intervalo que se quiere medir
%acelxbucle->Vector de aceleraci�n en el eje x en el intervalo que se 
%quiere medir
%acelybucle->Vector de aceleraci�n en el eje y en el intervalo que se 
%quiere medir
%acelzbucle->Vector de aceleraci�n en el eje z en el intervalo que se 
%quiere medir

%Desarrollado por Jesus.
%Coautor Antonio L�pez
% Incorporado a la toolbox el 03.01.2008, para ser incluido en v0.4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tbucle=t(i:i+128);
acelxbucle=acelx(i:i+128);
acelybucle=acely(i:i+128);
acelzbucle=acelz(i:i+128);










%Funci�n anidada
%toma de una matriz los valores del tiempo y de tres ejes de aceleraci�n
function [tiempo,aceleracionx,aceleraciony,aceleracionz]=s_tomardatosfichero(matriz)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%s_tomardatosfichero
%Programa que se encarga de tomar de una matriz los valores del tiempo y de
%los tres ejes de aceleraci�n.

%Entrada:
%matriz->Nombre de la matriz que contiene los datos

%Salida:
%tiempo->Vector de tiempo
%aceleracionx->Vector de aceleraci�n en el eje x
%aceleraciony->Vector de aceleraci�n en el eje y
%aceleracionz->Vector de aceleraci�n en el eje z

%Desarrollado por Jesus.
%Coautor Antonio L�pez
% Incorporado a la toolbox el 03.01.2008, para ser incluido en v0.4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Toma de datos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Se mira el n�mero de filas que pose�a el fichero original

tiempo=(matriz(:,1))';
aceleracionx=(matriz(:,2))';
aceleraciony=(matriz(:,3))';
aceleracionz=(matriz(:,4))';

%La velocidad angular se encuentra en rad/s
%velocidadangularx(i)=(matriz(:,5))';
%velocidadangulary(i)=(matriz(:,6))';
%velocidadangularz(i)=(matriz(:,7))';
    
%El campo magn�tico se encuentra en unidades arbitrarias, normalizadas
%con respecto a la fuerza del campo magn�tico
%campomagneticox(i)=(matriz(:,8))';
%campomagneticoy(i)=(matriz(:,9))';
%campomagneticoz(i)=(matriz(:,10))';
