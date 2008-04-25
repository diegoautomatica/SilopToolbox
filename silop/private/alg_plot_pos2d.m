%ALG_PLOT_POS2D Algoritmo para la representacion de la posicion en 2d
%
%ALG_PLOT_SENHALES Algoritmo para la representacion de la posicion en 2d
%Se puede configurar mediante:
%    addalgoritmo('alg_plot_pos2d', 0, [], [], {'alg_est_2d'});
%
%Parámetros: como todos los alg_*. resultados anteriores, señales a usar{vacio en este caso}, 
% parametros(vacio en este caso) y dependencias{'alg_est_2d'}.

%Creado: 06-02-2008 por Diego

function yadibujado=alg_plot_pos2d(resultados, senhales, params, dependencias) %#ok<INUSL>



	persistent mifigura
    persistent midata
    if (isempty(mifigura))
    		mifigura=figure;
            midata=[0,0];
    end
    try
        basura=get(mifigura);   %#ok<NASGU> %Intentamos pillar la figura
    catch                % si no existe
        midata=[0,0];    % los datos antiguos no tienen sentido
    end
 
    figure(mifigura);
    ultimodibujado=find(~isnan(resultados),1,'last');
    if (isempty(ultimodibujado))
        ultimodibujado=1;
    end
    indices=find(~isnan(dependencias(ultimodibujado+1:end,1)))+ultimodibujado;
    yadibujado=resultados;
    if (~isempty(indices))
        yadibujado(1:max(indices))=1;
        midata=[midata;dependencias(indices,1), dependencias(indices,2)];
        plot(midata(:,1),midata(:,2));
        drawnow;
    end








% Old working code
%function alg_plot_pos2d(valores_actuales, senhales, params, dependencias) %#ok<INUSL>
%     persistent mifigura
% 	if (isempty(mifigura))
%     		mifigura=figure;
% 	end
% 
% 
%     figure(mifigura);    
%     
%     indices=find(~isnan(dependencias(:,1)));
%     plot(dependencias(indices,1), dependencias(indices,2));
%     drawnow;

