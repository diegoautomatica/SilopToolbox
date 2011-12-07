%ALG_EST_MUNECA Algoritmo para la estimacion de los ángulos de la muñeca
% mediante la tecnica del sensor virtual
%Cambio la colocacion del sensor. 
%  Flexion giro en z
%  Pronacion giro en x
% y elaboro mis propias formulas
%
%Se puede configurar mediante:
%    addalgoritmo('alg_est_muneca', {'Muneca.Flex','Muneca.Pron'}, {'a.Acc_X','a.Acc_Y','a.Acc_Z','a.MG_X','a.MG_Y','a.MG_Z','m.Acc_X','m.Acc_Y','m.Acc_Z','m.MG_X','m.MG_Y','m.MG_Z'}, []);
%
%Parametros: como todos los alg_ resultados anteriores, senales a usar y
%parametros (vacio)

%Creado: 

function [flex,abd] = alg_est_muneca(previos, senhales, params) %#ok<INUSD>

    flex=previos(:,1);
    abd=previos(:,2);
    angulo_sin_calcular = find(isnan(previos(:,1))); %#ok<EFIND> %Filas a�n no procesadas
    for indice=angulo_sin_calcular'
        %Base del antebrazo
        V1=senhales(indice,1:3)/norm(senhales(indice,1:3));
        tmp=senhales(indice,4:6)/norm(senhales(indice,4:6));
        V2=cross(V1,tmp);V2=V2/norm(V2);
        V3=cross(V1,V2);
        V=[V1',V2',V3'];
        
        %Base de la muñeca
        v1=senhales(indice,7:9)/norm(senhales(indice,7:9));
        tmp=senhales(indice,10:12)/norm(senhales(indice,10:12));
        v2=cross(v1,tmp);v2=v2/norm(v2);
        v3=cross(v1,v2);
        v=[v1',v2',v3'];
        
        %Rotacion
        Rot=v*inv(V);
        
        flexion=atan2(Rot(3,1),Rot(3,3));
        abduccion=atan2(Rot(1,2),Rot(2,2));
        %flexion=atan2(-Rot(1,3),Rot(3,3));
        %abduccion=atan2(-Rot(2,1),Rot(2,2));
        
        abd(indice)=abduccion*180/pi;
        %Para eliminar acoplamientos
        flex(indice)=(flexion*180/pi);%+(abduccion*180/pi*14/130);
        
        %Se supone que en el codo no tenemos rotación y
        %valores altos aquí significan una de dos
        % error en las medidas
        % error en toda la idea del cálculo
        %error_angulo_y=Rot(3,1)
        %E=sin(flex(indice));
        %F=cos(flex(indice));
        %C=mean(Rot(1,1)/E,Rot(2,1)/F);
        %A=Rot(3,3)/C;
        %D=Rot(3,1)/A;
        %angle_y=atan2(C,D)
        %disp(['error_residual de la muneca' num2str(Rot(2,3))])
    end
