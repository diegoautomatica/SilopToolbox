%ALG_EST_DIST_R4 Algoritmo para la estimacion de la longitud de los pasos mediante el m�todo de la raiz cuarta
%
%ALG_EST_DIST_R4 Algoritmo para la estimacion de la longitud de los pasos.Este algoritmo actua como 
%wrapper de la funcion distancia_raizcuarta
%Se puede configurar mediante:
%    addalgoritmo('alg_est_dist_r4', {'COG.Dist'}, {'COG.Acc_Z','COG.HS'}, [], {});
%
%Parametros: como todos los alg_*. resultados anteriores, se�ales a usar, parametros(vacio en este caso)
% y dependencias.

%Creado: 01-02-2008 por Diego

function resultado = alg_est_dist_r4(previos, senhales, params, dependencias) %#ok<INUSD,INUSL>

        acel_z = senhales(:,1);
	resultado = previos;
        
        eventos_hs=find(senhales(:,2));
	eventos_hs=eventos_hs';
	if (~isempty(eventos_hs))
		viejoevento=eventos_hs(1);
		if (length(eventos_hs)>1)
            for k=eventos_hs(2:end)
                if (isnan(resultado(k)))
                    if ((k-viejoevento)<200) %Menos de dos segundos un paso
                        resultado(k)=distancia_raizcuarta(acel_z(viejoevento:k));
                    end
                end
                viejoevento=k;
            end
		end
	end

        

