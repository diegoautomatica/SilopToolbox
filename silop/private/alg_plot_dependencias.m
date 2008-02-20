%ALG_PLOT_DEPENDENCIAS Algoritmo para la representacion de resultados de otros algoritmos
%
%ALG_PLOT_DEPENDENCIAS Algoritmo para la representacion de resultados de otros algoritmos
%Se puede configurar mediante:
%    Config = addalgoritmo(Config, 'alg_plot_dependencias', 0, [], [], {'dependencia'});
%
%Parámetros: como todos los alg_*. resultados anteriores, señales a usar, parametros(vacio en este caso)
% y dependencias{un algoritmo}.

%Creado: 01-02-2008 por Diego

function alg_plot_dependencias(valores_actuales, senhales, params, dependencias)


	persistent mifigura
	if (isempty(mifigura))
    		mifigura=figure;
	end


    figure(mifigura);    
    plot(dependencias(:,:));
	drawnow;

