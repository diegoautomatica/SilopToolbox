%ALG_EST_ORIENT_GYRO Algoritmo para la estimacion de la orientaci�n mediante el gir�scopo
%
%ALG_EST_ORIENT_GYRO Algoritmo para la estimaci�n de la orientaci�n mediante el gir�scopo. 
% Este algoritmo actua como wrapper de la funci�n orientaciongiroscopo.
%Se puede configurar mediante:
%    addalgoritmo('alg_est_orient_gyro', 1, {'COG.G_Z'}, [], {});
%
%Parametros: como todos los alg_ resultados anteriores, se�ales a usar, parametros(se puede indicar 
% unicamente la frecuencia de muestreo) y dependencias(vacia en este caso)

%Creado: 01-02-2008 por Diego

function resultado = alg_est_orient_gyro(previos, senhales, params, dependencias) %#ok<INUSD>

        giro = senhales;
	resultado = previos;
        
        mov_sin_calcular = find(isnan(resultado)); %Filas a�n no procesadas
	if (~isempty(mov_sin_calcular))
        
	if (isempty(params))
		resultado(mov_sin_calcular)=orientaciongiroscopo(giro(mov_sin_calcular));        
	else 
		resultado(mov_sin_calcular)=orientaciongiroscopo(giro(mov_sin_calcular),params); 
	end       
	end
        

