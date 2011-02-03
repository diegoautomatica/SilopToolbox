%ALG_CALIB Algoritmo para calibrar una señal
%
%ALG_CALIB Algoritmo para calibrar una señal
%Se puede configurar mediante:
%    addalgoritmo('alg_calib', {'COG.AccX'}, {'COG.AccXRaw'}, [s,o]);
%
%Parametros: como todos los alg_ resultados anteriores, senhales a usar, parametros(sensibilidad y offset) 
% 

%Creado: 

function resultado = alg_calib(previos, senhales, params) %#ok<INUSD>

    resultado = previos;
    s=params(1);
    o=params(2);
    sc = find(isnan(resultado)); %Filas aun no procesadas
    if (~isempty(sc))
        resultado(sc)=(senhales(sc)-o)/s;
    end

