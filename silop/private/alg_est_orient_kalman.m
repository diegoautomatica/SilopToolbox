%ALG_EST_ORIENT_KALMAN Algoritmo para la estimacion de la orientacion mediante la br�jula y el compas
%
%ALG_EST_ORIENT_KALMAN Algoritmo para la estimacion de la orientacion mediante la br�jula y el compas. 
% Este algoritmo actua como wrapper de la funcion orientacionkalman.
%Se puede configurar mediante:
%    addalgoritmo('alg_est_orien_kalman', {'COG.Orient'}, {'COG.G_Z','COG.MG_X','COG.MG_Y','COG.MG_Z'}, []);
%
%Parametros: como todos los alg_ resultados anteriores, senhales a usar, parametros(se puede indicar 
% unicamente la frecuencia de muestreo) y dependencias(vacia en este caso)

%Creado: 12-02-2008 por Diego

function resultado = alg_est_orient_kalman(previos, senhales, params) %#ok<INUSD>

    Giro = senhales(:,1);
	Campox = senhales(:,2);
    Campoy = senhales(:,3);
    Campoz = senhales(:,4);
	resultado = previos;
        
    mov_sin_calcular = find(isnan(resultado)); %Filas a�n no procesadas
    if (~isempty(mov_sin_calcular))
        if (isempty(params))
            resultado(mov_sin_calcular)=orientacionkalman(Giro(mov_sin_calcular),Campox(mov_sin_calcular),Campoy(mov_sin_calcular),Campoz(mov_sin_calcular));        
        else 
            resultado(mov_sin_calcular)=orientacionkalman(Giro(mov_sin_calcular),Campox(mov_sin_calcular),Campoy(mov_sin_calcular),Campoz(mov_sin_calcular),params); 
        end       
    end
