%ALG_EJES_ANATOMICOS Algoritmo para la reorientaci�n de las matrices de datos
%
%ALG_EJES_ANATOMICOS Algoritmo para la reorientaci�n de las matrices de datos del COG a los 
%  ejes anat�micos.
%Se puede configurar mediante:
%    Config = AddAlgoritmo(Config, 'alg_ejes_anatomicos', 3, [COG.Acc_X,COG.Acc_Y,COG.Acc_Z], [], {});
%
%Par�metros: como todos los alg_ resultados anteriores, 
% se�ales a usar (las aceleraciones son obligatorias,giros y campo opcionales)
%,parametros(vacio en este caso) y dependencias(vacia en este caso)

%Creado: 19-02-2008 by Diego �lvarez

function corregido = alg_ejes_anatomicos(previos, senhales, params, dependencias)

	persistent RR;
	
	corregido=previos;
        mov_sin_calcular = find(isnan(previos)); %Filas a�n no procesadas
	[filas,cols]=size(senhales);
	[filas2,cols2]=size(previos);
	if ((filas~=filas2) or (cols~=cols2))
		error('las se�ales a corregir no coinciden con las se�ales pasadas a alg_ejes_anatomicos')
	end
	if ((cols~=3) and (cols~=6) and (cols~=9)
		error('n�mero de se�ales inconsistente en alg_ejes_anatomicos')
	end
	    
	if (isempty(RR)
		if (length(mov_sin_calcular)>=200)
			[corregido(mov_sin_calcular,1:3),RR]=ejes_anatomicos(senhales(mov_sin_calcular,1:3),senhales(mov_sin_calcular,1:3),[1,2,3]);
			if (cols>3)
	            	   corregido(mov_sin_calcular,4:6)=senhales(mov_sin_calcular,4:6)*RR';		
			end
	    		if (cols>6)
	            	   corregido(mov_sin_calcular,7:9)=senhales(mov_sin_calcular,7:9)*RR';		
	    		end
		end
	else
            corregido(mov_sin_calcular,1:3)=senhales(mov_sin_calcular,1:3)*RR';
	    if (cols>3)
	            corregido(mov_sin_calcular,4:6)=senhales(mov_sin_calcular,4:6)*RR';		
	    end
	    if (cols>6)
	            corregido(mov_sin_calcular,7:9)=senhales(mov_sin_calcular,7:9)*RR';		
	    end
        end;
