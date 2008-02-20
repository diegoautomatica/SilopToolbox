%ALG_EST_DIST_ARCO Algoritmo para la estimaci�n de la longitud de los pasos mediante el m�todo de VTI
%
%ALG_EST_DIST_ARCO Algoritmo para la estimaci�n de la longitud de los pasos.Este algoritmo actua como 
%wrapper de la funci�n distancia_arco
%Se puede configurar mediante:
%    Config = addalgoritmo(Config, 'alg_est_dist_arco', 1, [COG.Acc_Z], [freq,pierna], {'alg_det_event'});
%
%Par�metros: como todos los alg_*. resultados anteriores, se�ales a usar, parametros(vacio en este caso)
% y dependencias.

%Creado: 01-02-2008 por Diego

function resultado = alg_est_dist_arco(previos, senhales, params, dependencias)

        acel_z = senhales;
	resultado = previos;
        
	if (length(params)<2)
		pierna=1;
		if (length(params)<1)
			freq=100;
		else freq=params(1);
		end
	else pierna=params(2);
	end
        eventos_hs=find(dependencias(1:end,1));
	eventos_hs=eventos_hs';
	if (~isempty(eventos_hs))
		viejoevento=eventos_hs(1);
		if (length(eventos_hs)>1)
        	   for k=[eventos_hs(2:end)]
			if (isnan(resultado(k)))
				if ((k-viejoevento)<200) %Menos de dos segundos un paso
					resultado(k)=distancia_arco(acel_z(viejoevento:k),freq,pierna);
				end
			end
			viejoevento=k;
		   end
		end
	end

        

