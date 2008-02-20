%ALG_PLOT_POS2D Algoritmo para la representacion de la posicion en 2d
%
%ALG_PLOT_SENHALES Algoritmo para la representacion de la posicion en 2d
%Se puede configurar mediante:
%    Config = addalgoritmo(Config, 'alg_plot_pos2d', 0, [], [], {'alg_est_2d'});
%
%Parámetros: como todos los alg_*. resultados anteriores, señales a usar{vacio en este caso}, 
% parametros(vacio en este caso) y dependencias{'alg_est_2d'}.

%Creado: 06-02-2008 por Diego

function alg_plot_pos2d(valores_actuales, senhales, params, dependencias)
%    C = AddAlgoritmo(C, 'alg_plot_pos2d', 0, [], [], {'alg_est_2d'}); 


	persistent mifigura
	if (isempty(mifigura))
    		mifigura=figure;
	end


    figure(mifigura);    
    
    indices=find(~isnan(dependencias(:,1)));
    plot(dependencias(indices,1), dependencias(indices,2));
    drawnow;

    %subplot(212);
    %bar(dependencias)

