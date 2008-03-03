%ALG_PLOT_SENHALES Algoritmo para la representacion de señales
%
%ALG_PLOT_SENHALES Algoritmo para la representación de tres señales.
%Se puede configurar mediante:
%    addalgoritmo('alg_plot_senhales', 0, {lista de señales}, [], {});
%
%Parámetros: como todos los alg_*. resultados anteriores, señales a usar, parametros(vacio en este caso)
% y dependencias{vacio en este caso}.

%Creado: 01-02-2008 por Diego

function alg_plot_senhales(valores_actuales, senhales, params, dependencias) %#ok<INUSD,INUSL>
%    C = AddAlgoritmo(C, 'alg_plot_senhales', 0, [COG.Acc_X COG.Acc_Y COG.Acc_Z], [], {'det_mov_pot_acc_v_cog'}); 


	persistent mifigura
	if (isempty(mifigura))
    		mifigura=figure;
	end


    figure(mifigura);    
    %subplot(211)
    plot(senhales(:,:));%, hold on, plot(senhales(:,2), 'r'), plot(senhales(:,3), 'g');
    

    %subplot(212);
    %bar(dependencias)
	drawnow
