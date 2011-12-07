%ALG_EST_CODOv2 Algoritmo para la estimacion de los ángulos del codo izquierdo
% mediante la tecnica del sensor virtual
%Cambio la colocacion del sensor. 
%  Flexion giro en z
%  Pronacion giro en x
% y elaboro mis propias formulas
%
%Se puede configurar mediante:
%    addalgoritmo('alg_est_codo', {'Codo.Flex','Codo.Pron'}, {'a.Acc_X','a.Acc_Y','a.Acc_Z','a.MG_X','a.MG_Y','a.MG_Z','b.Acc_X','b.Acc_Y','b.Acc_Z','b.MG_X','b.MG_Y','b.MG_Z'}, []);
%
%Parametros: como todos los alg_ resultados anteriores, senales a usar y
%parametros (vacio)

%Creado: 12-02-2008 por Diego

function [flex,pron] = alg_est_codo_izq(previos, senhales, params) %#ok<INUSD>

    flex=previos(:,1);
    pron=previos(:,2);
    angulo_sin_calcular = find(isnan(previos(:,1))); %#ok<EFIND> %Filas a�n no procesadas
    for indice=angulo_sin_calcular'
        V1=senhales(indice,1:3)/norm(senhales(indice,1:3));
        tmp=senhales(indice,4:6)/norm(senhales(indice,4:6));
        V2=cross(V1,tmp);V2=V2/norm(V2);
        V3=cross(V1,V2);
        V=[V1',V2',V3'];
        
        v1=senhales(indice,7:9)/norm(senhales(indice,7:9));
        tmp=senhales(indice,10:12)/norm(senhales(indice,10:12));
        v2=cross(v1,tmp);v2=v2/norm(v2);
        v3=cross(v1,v2);
        v=[v1',v2',v3'];
        
        %Rot=V*inv(v);
        Rot=v*inv(V);
        
        %flexion=-atan2(Rot(2,1),Rot(1,1));
        %pronacion=atan2(Rot(3,2),Rot(3,3));
        flexion=atan2(Rot(1,2),Rot(1,1));
        pronacion=atan2(Rot(2,3),Rot(3,3));
        
        flex(indice)=flexion*180/pi;
        pron(indice)=pronacion*180/pi;
        
   
    end

    
