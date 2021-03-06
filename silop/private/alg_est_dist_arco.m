%ALG_EST_DIST_ARCO Algoritmo para la estimacion de la longitud de los pasos mediante el metodo de VTI
%
%ALG_EST_DIST_ARCO Algoritmo para la estimacion de la longitud de los pasos.Este algoritmo actua como 
%wrapper de la funcion distancia_arco
%Se puede configurar mediante:
%    addalgoritmo('alg_est_dist_arco', {'COG.Dist'}, {'COG.Acc_Z','COG.HS'}, [freq,pierna]);
%
%Parametros: como todos los alg_*. resultados anteriores, se�ales a usar, y parametros y dependencias.

%Creado: 01-02-2008 por Diego

function resultado = alg_est_dist_arco(previos, senhales, params) %#ok<INUSD>

        acel_z = senhales(:,1);
        heelstrikes= senhales(:,2);
	resultado = previos;
        
	if (length(params)<2)
		pierna=1;
		if (length(params)<1)
			freq=100;
		else freq=params(1);
		end
	else pierna=params(2);
	end
    eventos_hs=find(heelstrikes(:,1));
	eventos_hs=eventos_hs';
	if (~isempty(eventos_hs))
		viejoevento=eventos_hs(1);
		if (length(eventos_hs)>1)
            for k=eventos_hs(2:end)
                if (isnan(resultado(k)))
                    if ((k-viejoevento)<200) %Menos de dos segundos un paso
                        resultado(k)=distancia_arco(acel_z(viejoevento:k),freq,pierna);
                    end
                end
                viejoevento=k;
            end
		end
	end

        

