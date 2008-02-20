% IDENT_ACT Identifica la actividad que se está realizando
%
% IDENT_ACT Identifica la actividad que se está realizando en base a una red neuronal previamente entrenada.
% Las actividades identificadas son caminar y  subir/bajar escaleras/rampas
%
% Sintax:
% identificacion=ident_act(redneuronal,parametros,datos)
%
% Parámetros de entrada:
%    redneuronal   - Variable que tiene almacenada la red neuronal, tal y como la proporciona entrena_ident_act
%    parametros    - VAriable con datos genericos de la señal, tal y como la proporciona entrena_ident_act
%    datos        - Matriz con los datos del perido en el que se quiere realizar la identificación.
%                    Tiene que tener 1 fila por muestra y las mismas columnas que las usadas en entrena_ident_act
%
% Parámetros de salida:
%    identificacion - Un vector que contien en cada elemento la actividad asociada con cada una de las muestras.
%                     (1=Bajar escaleras, 2=Bajar rampa, 3=Andar, 4=Subir rampa, 5=Subir escaleras)
%
% Examples:
%
% See also: entrena_ident_act
%

% Author:   Jesús E. Pérez Villegas 
% History:  12.12.2007  Fichero creado.
%           21.12.2007  Preparada para la toolbox
%           03.01.2008  Adaptada correctamente a la toolbox.(Diego)
%           21.01.2008  Usa energiawavelet en lugar de s_calcularenergiawavelet            

function identificacion=ident_act(redneuronal,parametros,matriz)



maxmtotalnor=parametros{1};
minmtotalnor=parametros{2};
valormediox=parametros{3};
valormedioy=parametros{4};
valormedioz=parametros{5};
datos1=parametros{6};



mov1='/bajarescaleras'; mov2='/bajarrampa'; mov3='/andar'; 
mov4='/subirrampa'; mov5='/subirescaleras';

R=[3 -2 1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%El tiempo esta en segundos
tiempo=(matriz(:,1))';
    
%La aceleracion se encuentra en m/(s^2)
aceleracionx=(matriz(:,2))';
aceleraciony=(matriz(:,3))';
aceleracionz=(matriz(:,4))';
    
%La velocidad angular se encuentra en rad/s
velocidadangularx=(matriz(:,5))';
velocidadangulary=(matriz(:,6))';
velocidadangularz=(matriz(:,7))';
   
%El campo magnético se encuentra en unidades arbitrarias, normalizadas
%con respecto a la fuerza del campo magnético
%campomagneticox=(matriz(:,8))';
%campomagneticoy=(matriz(:,9))';
%campomagneticoz=(matriz(:,10))';


%Se realizarán modificaciones en los ejes de las aceleraciones con la
%llamada a la función ejes_anatomicos
datos2=[aceleracionx;aceleraciony;aceleracionz]';
[datos_c,RR]=ejes_anatomicos(datos2,datos1,R);
    
datos_c=datos_c';
acejesmodx=datos_c(1,:);
acejesmody=datos_c(2,:);
acejesmodz=datos_c(3,:);
    
aceleracionx=acejesmodx/valormediox;
aceleraciony=acejesmody/valormedioy;
aceleracionz=acejesmodz/valormedioz;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Se hallan los datos de los vectores de aceleración
longitudmedida=length(tiempo);
Tmuestreo=tiempo(2)-tiempo(1);  % Tiempo de muestreo (en segundos)
Frecmuestreo=1/Tmuestreo;       % Frecuencia de muestreo (en Hz)
L = 128;                        % Longitud de la señal a tratar
t = (0:L-1)*Tmuestreo;          % Vector de tiempo
%La Frecuencia de muestreo ha de ser al menos el doble de la frecuencia
%máxima a estudiar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Representacion gráfica del movimiento
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% longitudmedida=length(tiempo);
% disp('El tiempo total de estudio es:')
% disp(tiempo(longitudmedida))
% 
% %Representación de los vectores de aceleración
% subplot(3,1,1)
% plot(tiempo,aceleracionx)
% title('Componente x de la aceleración en el dominio del tiempo')
% xlabel('tiempo (segundos)')
% 
% subplot(3,1,2)
% plot(tiempo,aceleraciony)
% title('Componente y de la aceleración en el dominio del tiempo')
% xlabel('tiempo (segundos)')
% 
% subplot(3,1,3)
% plot(tiempo,aceleracionz)
% title('Componente z de la aceleración en el dominio del tiempo')
% xlabel('tiempo (segundos)')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Bucle que tratará cada uno de los intervalos 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
matriztotal=[];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Llamada a la subrutina encargada de la descomposición de paquetes
%wavelet.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[energiawaveletx,desvstdwaveletx,valorRMSwaveletx]=energiawavelet(aceleracionx);
[energiawavelety,desvstdwavelety,valorRMSwavelety]=energiawavelet(aceleraciony);
[energiawaveletz,desvstdwaveletz,valorRMSwaveletz]=energiawavelet(aceleracionz);

matrizdatos=[energiawaveletx energiawavelety energiawaveletz];
matrizdatos=[matrizdatos desvstdwaveletx desvstdwavelety desvstdwaveletz];
matrizdatos=[matrizdatos valorRMSwaveletx valorRMSwaveletz];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
matriztotal=[matriztotal;matrizdatos];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Hay la posibilidad de realizar la dft de las señales de 
%aceleración s_realizaciondft(acelxbucle,acelybucle,acelzbucle)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Se hace una normalizacion de los datos
matriztotal=[matriztotal; minmtotalnor'; maxmtotalnor'];
matriztotal=matriztotal';
[matriztotaln,minmatriztotal,maxmatriztotal]=premnmx(matriztotal); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Aplicación de redes neuronales
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resultado=sim(redneuronal,matriztotaln);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Representación de las actividades estimadas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%En esta parte del programa se establecerá los intervalos de tiempo en que
%suceden cada uno de los tipos de movimiento, y se mostrará un mensaje del
%tipo : "Bajando escaleras", "bajando rampa",...

[fila,col]=size(resultado);

vectorestimacion=[];

maximosresultado=max(resultado);

for j=1:col-2
    if resultado(1,j)==maximosresultado(1,j)
        estadoactual=1;
        movimiento='Bajando escaleras';
    elseif resultado(2,j)==maximosresultado(1,j)
        estadoactual=2;
        movimiento='Bajando rampa';
    elseif resultado(3,j)==maximosresultado(1,j)
        estadoactual=3;
        movimiento='Andando';
    elseif resultado(4,j)==maximosresultado(1,j)
        estadoactual=4;
        movimiento='Subiendo rampa';
    else  estadoactual=5;
        movimiento='Subiendo escaleras';
    end
    vectorestimacion=[vectorestimacion estadoactual];
end
identificacion=vectorestimacion;
