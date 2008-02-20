%ALG_BAR_DEPENDENCIAS Algoritmo para la representacion de resultados de otros mediante diagramas de barras.
%
%ALG_BAR_DEPENDENCIAS Algoritmo para la representacion de resultados de otros mediante diagramas de barras.
% Util cuando se tienen datos aislados entre muchos NaN
%Se puede configurar mediante:
%    Config = addalgoritmo(Config, 'alg_bar_dependencias', 0, [], [], {'dependencia'});
%
%Parámetros: como todos los alg_*. resultados anteriores, señales a usar, parametros(vacio en este caso)
% y dependencias{un algoritmo}.

%Creado: 01-02-2008 por Diego

function alg_bar_dependencias(valores_actuales, senhales, params, dependencias)


	persistent mifigura
	if (isempty(mifigura))
    		mifigura=figure;
	end


    figure(mifigura);    
    bar(dependencias(:,:));
	drawnow;
