%ALG_DET_MOV Algoritmo para la detección del movimiento
%
%ALG_DET_MOV Algoritmo para la detección del movimiento basado en la aceleración vertical del COG.
%Se puede configurar mediante:
%    Config = AddAlgoritmo(Config, 'alg_det_mov', 1, [COG.Acc_Z], [], {});
%
%Parámetros: como todos los alg_ resultados anteriores, señales a usar, parametros(vacio en este caso)
% y dependencias(vacia en este caso)

%Creado: xx-01-2008 Antonio López
%        30-01-2008 Incorporado, editado y renombrado por Diego
%        06-02-2008 Revisado y comprobado por Diego, corregido para buscar contra la media.

function resultado = alg_det_mov(previos, senhales, params, dependencias)

        acel_z = senhales; %Hay una sola señal que es la aceleración Z del COG
        resultado = previos;
        
        mov_sin_calcular = find(isnan(resultado)); %Filas aún no procesadas
        
        if(length(mov_sin_calcular)>=50)
            for k=mov_sin_calcular(1):50:mov_sin_calcular(end)-50+1
                    tramo = acel_z(k:k+50-1)-mean(acel_z(k:k+50-1));
                    valor = sum(tramo.^2) ;%tramo*tramo'
                    resultado(k:k+50-1) = (valor > 3);
            end;
        end;


