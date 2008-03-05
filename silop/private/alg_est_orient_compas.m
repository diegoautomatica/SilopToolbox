%ALG_EST_ORIENT_COMPAS Algoritmo para la estimacion de la orientaci�n mediante la br�jula
%
%ALG_EST_ORIENT_COMPAS Algoritmo para la estimaci�n de la orientaci�n mediante la br�jula. 
% Este algoritmo actua como wrapper de la funci�n orientacionbr�jula.
%Se puede configurar mediante:
%    addalgoritmo('alg_est_orien_compast', 1, {'COG.MG_X','COG.MG_Y','COG.MG_Z'}, [], {});
%
%Par�metros: como todos los alg_ resultados anteriores, se�ales a usar, parametros(se puede indicar 
% �nicamente la frecuencia de muestreo) y dependencias(vacia en este caso)

%Creado: 12-02-2008 por Diego

function resultado = alg_est_orient_compas(previos, senhales, params, dependencias) %#ok<INUSD>

    Campox = senhales(:,1);
    Campoy = senhales(:,2);
    Campoz = senhales(:,3);
	resultado = previos;
        
    mov_sin_calcular = find(isnan(resultado)); %Filas a�n no procesadas
    if (~isempty(mov_sin_calcular))
        if (isempty(params))
            resultado(mov_sin_calcular)=orientacioncompas(Campox(mov_sin_calcular),Campoy(mov_sin_calcular),Campoz(mov_sin_calcular));        
        else 
            resultado(mov_sin_calcular)=orientacioncompas(Campox(mov_sin_calcular),Campoy(mov_sin_calcular),Campoz(mov_sin_calcular),params); 
        end
    end

