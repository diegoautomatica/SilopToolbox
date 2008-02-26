%ALG_EST_ORIENT_COMPAS Algoritmo para la estimacion de la orientación mediante la brújula
%
%ALG_EST_ORIENT_COMPAS Algoritmo para la estimación de la orientación mediante la brújula. 
% Este algoritmo actua como wrapper de la función orientacionbrújula.
%Se puede configurar mediante:
%    Config = addalgoritmo(Config, 'alg_est_orien_compast', 1, [COG.MG_X,COG.MG_Y,COG.MG_Z], [], {});
%
%Parámetros: como todos los alg_ resultados anteriores, señales a usar, parametros(se puede indicar 
% únicamente la frecuencia de muestreo) y dependencias(vacia en este caso)

%Creado: 12-02-2008 por Diego

function resultado = alg_est_orient_compas(previos, senhales, params, dependencias)

        Campox = senhales(:,1);
        Campoy = senhales(:,2);
        Campoz = senhales(:,3);
	resultado = previos;
        
        mov_sin_calcular = find(isnan(resultado)); %Filas aún no procesadas
	if (~isempty(mov_sin_calcular))
        
	if (isempty(params))
		resultado(mov_sin_calcular)=orientacioncompas(Campox(mov_sin_calcular),Campoy(mov_sin_calcular),Campoz(mov_sin_calcular));        
	else 
		resultado(mov_sin_calcular)=orientacioncompas(Campox(mov_sin_calcular),Campoy(mov_sin_calcular),Campoz(mov_sin_calcular),params); 
	end       
        end

