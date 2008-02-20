%ALG_EST_DIST_R4 Algoritmo para la estimación de la longitud de los pasos mediante el método de la raiz cuarta
%
%ALG_EST_DIST_R4 Algoritmo para la estimación de la longitud de los pasos.Este algoritmo actua como 
%wrapper de la función distancia_raizcuarta
%Se puede configurar mediante:
%    Config = addalgoritmo(Config, 'alg_est_dist_r4', 1, [COG.Acc_Z], [], {'alg_det_event'});
%
%Parámetros: como todos los alg_*. resultados anteriores, señales a usar, parametros(vacio en este caso)
% y dependencias.

%Creado: 01-02-2008 por Diego

function resultado = alg_est_dist_r4(previos, senhales, params, dependencias)

        acel_z = senhales;
	resultado = previos;
        
        eventos_hs=find(dependencias(1:end,1));
	eventos_hs=eventos_hs';
	if (~isempty(eventos_hs))
		viejoevento=eventos_hs(1);
		if (length(eventos_hs)>1)
        	   for k=[eventos_hs(2:end)]
			if (isnan(resultado(k)))
				if ((k-viejoevento)<200) %Menos de dos segundos un paso
					resultado(k)=distancia_raizcuarta(acel_z(viejoevento:k));
				end
			end
			viejoevento=k;
		   end
		end
	end

        

