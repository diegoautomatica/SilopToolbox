%ALG_EST_HOMBRO Algoritmo para la estimacion de los Ã¡ngulos del hombro
% mediante la tecnica del sensor virtual
%
%Se puede configurar mediante:
%    addalgoritmo('alg_est_hombro', {'Hombro.a','Hombro.b','Hombro.c'}, {'a.Acc_X','a.Acc_Y','a.Acc_Z','a.MG_X','a.MG_Y','a.MG_Z','b.Acc_X','b.Acc_Y','b.Acc_Z','b.MG_X','b.MG_Y','b.MG_Z'}, []);
%
%Parametros: como todos los alg_ resultados anteriores, senales a usar y
%parametros (vacio)

%Creado: 

function [abd,flex,rot] = alg_est_hombro(previos, senhales, params) %#ok<INUSD>

    abd=previos(:,1);
    flex=previos(:,2);
    rot=previos(:,3);
    angulo_sin_calcular = find(isnan(previos(:,1))); %#ok<EFIND> %Filas aï¿½n no procesadas
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
        
        R=v*inv(V);
        
        %Estimacion antigua del hombro
        angle_flex=atan2(R(2,1),R(2,2));
        angle_abd=atan2(-R(1,3),R(3,3));
        %X=mean([R(2,1)/sin(angle_flex),R(2,2)/cos(angle_flex),-R(1,3)/sin(angle_abd),R(3,3)/cos(angle_abd)]);
        if (abs(angle_flex<pi/4))
            X=R(2,2)/cos(angle_flex);
        else
            X=R(2,1)/sin(angle_flex);
        end
        angle_rot=atan2(R(2,3),X);
        
        %Correccion del hombro sin testear. Para despues de la reunion
        %angle_flex=atan2(-R(1,2),R(1,1));
        %angle_rot=atan2(R(2,3),R(3,3));
        %if (abs(angle_flex)<pi/4) %si menor de 45º usamos el coseno de la flexion para despejar
        %    X=R(1,1)/cos(angle_flex);
        %else
        %    X=-R(1,2)/sin(angle_flex);
        %end
            %X=mean([R(1,1)/cos(angle_flex),-R(1,2)/sin(angle_flex),R(2,3)/sin(angle_rot),R(3,3)/cos(angle_rot)]);
        %angle_abd=atan2(-R(1,3),X);
        
        abd(indice)=angle_abd*180/pi;
        flex(indice)=angle_flex*180/pi;
        rot(indice)=angle_rot*180/pi;

    end
