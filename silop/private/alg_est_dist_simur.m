%ALG_EST_DIST_SIMUR Algoritmo para la estimacion de la longitud de los pasos mediante el modelo pendulo+desplazamiento
%
%ALG_EST_DIST_SIMUR Algoritmo para la estimacion de la longitud de los pasos.Este algoritmo actua como 
%wrapper de la funcion distancia_penduloparcial
%Se puede configurar mediante:
%    addalgoritmo('alg_est_dist_simur', 1, {'COG.Acc_Z'}, [freq,hsensor,pie], {'alg_det_event'});
%
%Parametros: como todos los alg_*. resultados anteriores, se�ales a usar, parametros(vacio en este caso)
% y dependencias.

%Creado: 01-02-2008 por Diego

function resultado = alg_est_dist_simur(previos, senhales, params, dependencias)

        acel_z = senhales;
	resultado = previos;
        
	if (length(params)<3)
		pie=0.15;
		if (length(params)<2)
			hsensor=0.8;
			if (length(params)<1)
				freq=100;
			else freq=params(1);
			end
		else hsensor=params(2);
		end
	else pie=params(3);
	end
 

        eventos_hs=find(dependencias(1:end,1));
	eventos_hs=eventos_hs';
	if (~isempty(eventos_hs))
		viejoevento=eventos_hs(1);
		if (length(eventos_hs)>1)
        	for k=eventos_hs(2:end) %#ok<ALIGN>
                if (isnan(resultado(k)))
                    if ((k-viejoevento)<200) %Menos de dos segundos un paso
                        to=find(dependencias(viejoevento:k,2));
                        if (isempty(to))
                            warning('Toe-Off no detectado. Se pierde un paso'); %#ok<WNTAG>
                        else
                            resultado(k)=distancia_pendulo(acel_z(viejoevento:k),to(1),freq,hsensor,pie);
                        end
                    end
                end
                viejoevento=k;
            end
		end
	end

        

