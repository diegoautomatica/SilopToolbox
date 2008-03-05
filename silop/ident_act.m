% IDENT_ACT Identifica la actividad que se est� realizando
%
% IDENT_ACT Identifica la actividad que se est� realizando en base a una red neuronal previamente entrenada.
% Las actividades identificadas son caminar y  subir/bajar escaleras/rampas
%
% Sintax:
% identificacion=ident_act(redneuronal,parametros,datos)
%
% Par�metros de entrada:
%    redneuronal   - Variable que tiene almacenada la red neuronal, tal y como la proporciona entrena_ident_act
%    parametros    - VAriable con datos genericos de la se�al, tal y como la proporciona entrena_ident_act
%    datos        - Matriz con los datos del perido en el que se quiere realizar la identificaci�n.
%                    Tiene que tener 1 fila por muestra y las mismas columnas que las usadas en entrena_ident_act
%
% Par�metros de salida:
%    identificacion - Un vector que contien en cada elemento la actividad asociada con cada una de las muestras.
%                     (1=Bajar escaleras, 2=Bajar rampa, 3=Andar, 4=Subir rampa, 5=Subir escaleras)
%
% Examples:
%
% See also: entrena_ident_act
%

% Author:   Jes�s E. P�rez Villegas 
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



R=[3 -2 1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%El tiempo esta en segundos
%tiempo=(matriz(:,1))';
    
%La aceleracion se encuentra en m/(s^2)
aceleracionx=(matriz(:,2))';
aceleraciony=(matriz(:,3))';
aceleracionz=(matriz(:,4))';
    
%Se realizar�n modificaciones en los ejes de las aceleraciones con la
%llamada a la funci�n ejes_anatomicos
datos2=[aceleracionx;aceleraciony;aceleracionz]';
datos_c=ejes_anatomicos(datos2,datos1,R);
    
datos_c=datos_c';
acejesmodx=datos_c(1,:);
acejesmody=datos_c(2,:);
acejesmodz=datos_c(3,:);
    
aceleracionx=acejesmodx/valormediox;
aceleraciony=acejesmody/valormedioy;
aceleracionz=acejesmodz/valormedioz;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Se hallan los datos de los vectores de aceleraci�n
%longitudmedida=length(tiempo);
%Tmuestreo=tiempo(2)-tiempo(1);  % Tiempo de muestreo (en segundos)
%L = 128;                        % Longitud de la se�al a tratar
%t = (0:L-1)*Tmuestreo;          % Vector de tiempo
%La Frecuencia de muestreo ha de ser al menos el doble de la frecuencia
%m�xima a estudiar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Representacion gr�fica del movimiento
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% longitudmedida=length(tiempo);
% disp('El tiempo total de estudio es:')
% disp(tiempo(longitudmedida))
% 
% %Representaci�n de los vectores de aceleraci�n
% subplot(3,1,1)
% plot(tiempo,aceleracionx)
% title('Componente x de la aceleraci�n en el dominio del tiempo')
% xlabel('tiempo (segundos)')
% 
% subplot(3,1,2)
% plot(tiempo,aceleraciony)
% title('Componente y de la aceleraci�n en el dominio del tiempo')
% xlabel('tiempo (segundos)')
% 
% subplot(3,1,3)
% plot(tiempo,aceleracionz)
% title('Componente z de la aceleraci�n en el dominio del tiempo')
% xlabel('tiempo (segundos)')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Bucle que tratar� cada uno de los intervalos 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
matriztotal=[];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Llamada a la subrutina encargada de la descomposici�n de paquetes
%wavelet.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[energiawaveletx,desvstdwaveletx,valorRMSwaveletx]=energiawavelet(aceleracionx);
[energiawavelety,desvstdwavelety,valorRMSwavelety]=energiawavelet(aceleraciony); %#ok<NASGU>
[energiawaveletz,desvstdwaveletz,valorRMSwaveletz]=energiawavelet(aceleracionz);

matrizdatos=[energiawaveletx energiawavelety energiawaveletz];
matrizdatos=[matrizdatos desvstdwaveletx desvstdwavelety desvstdwaveletz];
matrizdatos=[matrizdatos valorRMSwaveletx valorRMSwaveletz];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
matriztotal=[matriztotal;matrizdatos];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Hay la posibilidad de realizar la dft de las se�ales de 
%aceleraci�n s_realizaciondft(acelxbucle,acelybucle,acelzbucle)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Se hace una normalizacion de los datos
matriztotal=[matriztotal; minmtotalnor'; maxmtotalnor'];
matriztotal=matriztotal';
[matriztotaln]=premnmx(matriztotal); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Aplicaci�n de redes neuronales
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resultado=sim(redneuronal,matriztotaln);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Representaci�n de las actividades estimadas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%En esta parte del programa se establecer� los intervalos de tiempo en que
%suceden cada uno de los tipos de movimiento, y se mostrar� un mensaje del
%tipo : "Bajando escaleras", "bajando rampa",...

[fila,col]=size(resultado);

vectorestimacion=[];

maximosresultado=max(resultado);

for j=1:col-2
    if resultado(1,j)==maximosresultado(1,j)
        estadoactual=1;
        %movimiento='Bajando escaleras';
    elseif resultado(2,j)==maximosresultado(1,j)
        estadoactual=2;
        %movimiento='Bajando rampa';
    elseif resultado(3,j)==maximosresultado(1,j)
        estadoactual=3;
        %movimiento='Andando';
    elseif resultado(4,j)==maximosresultado(1,j)
        estadoactual=4;
        %movimiento='Subiendo rampa';
    else  estadoactual=5;
        %movimiento='Subiendo escaleras';
    end
    vectorestimacion=[vectorestimacion estadoactual]; %#ok<AGROW>
end
identificacion=vectorestimacion;
