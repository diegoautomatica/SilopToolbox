%ALG_DET_EVENT Algoritmo para la detección de los eventos HS y TO
%
%ALG_DET_EVENT Algoritmo para la detección de los eventos HS y TO. Este algoritmo actua como 
%wrapper de la función eventos_RT.
%Se puede configurar mediante:
%    Config = AddAlgoritmo(Config, 'alg_det_event', 2, [COG.Acc_Z, COG.Acc.X], [], {});
%
%Parámetros: como todos los alg_ resultados anteriores, señales a usar, parametros(vacio en este caso)
% y dependencias(vacia en este caso)DEBERIA DEPENDER DE ALG_DET_MOV EN EL FUTURO

%Creado: 30-01-2008 por Diego

function [resultadohs, resultadoto] = alg_det_event(previos, senhales, params, dependencias)

        acel_z = senhales(:,1); %Hay dos señales 
	acel_x = senhales(:,2);
        resultadohs = previos(:,1);
	resultadoto = previos(:,2);
        
        mov_sin_calcular = find(isnan(resultadohs)); %Filas aún no procesadas
	is (~isempty(mov_sin_calcular))
        
        for k=mov_sin_calcular(1):mov_sin_calcular(end)
                [hs,to]=eventos_RT(acel_x(k),acel_z(k));
		resultadohs(k)=0;		
		if (hs~=0)
		      resultadohs(k-hs)=1;
		end
		resultadoto(k)=0;		
		if (to~=0)
		      resultadoto(k-to)=1;
		end					
        end;
        
	end;
