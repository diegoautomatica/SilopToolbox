%ALG_BAR_SENHALES Algoritmo para la representacion de senhales mediante diagramas de barras.
%
%ALG_BAR_DEPENDENCIAS Algoritmo para la representacion de senhales mediante diagramas de barras.
% Util cuando se tienen datos aislados entre muchos NaN
%Se puede configurar mediante:
%    addalgoritmo('alg_bar_senhales', 0, {'senhales'}, []);
%
%Parametros: como todos los alg_*. resultados anteriores, señales a dibujar, parametros(vacio en este caso)

%Creado: 01-02-2008 por Diego

function alg_bar_senhales(valores_actuales, senhales, params) %#ok<INUSD,INUSL>


	persistent mifigura
	if (isempty(mifigura))
    		mifigura=figure;
	end


    figure(mifigura);    
    bar(senhales(:,:));
	drawnow;
