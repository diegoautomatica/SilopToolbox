%ALG_EST_ORIENT_COMPAS Algoritmo para la estimacion de la orientacion mediante la br�jula
%
%ALG_EST_ORIENT_COMPAS Algoritmo para la estimacion de la orientacion mediante la br�jula. 
% Este algoritmo actua como wrapper de la funcion orientacionbrujula.
%Se puede configurar mediante:
%    addalgoritmo('alg_est_orien_compast', {'COG.Orient'}, {'COG.MG_X','COG.MG_Y','COG.MG_Z'}, []);
%
%Parametros: como todos los alg_ resultados anteriores, senhales a usar, parametros(se puede indicar 
% unicamente la frecuencia de muestreo)

%Creado: 12-02-2008 por Diego

function resultado = alg_est_orient_compas(previos, senhales, params) %#ok<INUSD>

    Campox = senhales(:,1);
    Campoy = senhales(:,2);
    Campoz = senhales(:,3);
	resultado = previos;
        
    mov_sin_calcular = find(isnan(resultado)); %Filas aun no procesadas
    if (~isempty(mov_sin_calcular))
        if (isempty(params))
            resultado(mov_sin_calcular)=orientacioncompas(Campox(mov_sin_calcular),Campoy(mov_sin_calcular),Campoz(mov_sin_calcular));        
        else 
            resultado(mov_sin_calcular)=orientacioncompas(Campox(mov_sin_calcular),Campoy(mov_sin_calcular),Campoz(mov_sin_calcular),params); 
        end
    end

