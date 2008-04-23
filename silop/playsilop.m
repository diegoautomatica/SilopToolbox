% PLAYSILOP Realiza el procesamiento de acuerdo a los IMUS y algoritmos indicados
%
% PLAYSILOP Realiza el procesamiento de acuerdo a los IMUS y algoritmos indicados. Debe ser llamado despues de todos los
% comandos de configuracion. Opcionalmente guarda los datos en un fichero
% con extension .sl
% 
% Syntax: 
%   playsilop(salvar,fichero);
%
%   Parametros de entrada: 
%	    salvar  Indica si se deben guardar los datos a un archivo, 0=no, 1=las señales, 2=todos.
%               Por defecto no se guardan.
%       fichero Si se salvan los datos, este parametro permite especificar el fichero en el que se
%           guardaran los datos. Por defecto se guardan en datos.sl
%
%   Parametros de salida: Ninguno 
%
% Examples: 
%   
%
% See also: initsilop, connectsilop, addimu, addalgoritmo, stopsilop

% Author:   Diego Alvarez
% History:  29.01.2008  creado e Incorporado a la toolbox
%           12.02.2008  modificaciones de Rafa para arrancar los XBus Master mediante iniciacaptura().


function playsilop(salvar,fichero)

global SILOP_CONFIG
global SILOP_DATA_BUFFER;
	
VENTANA=zeros(1, SILOP_CONFIG.GLOBAL.COLUMNADISPONIBLE-1);

if (nargin<1)
	salvar=0;
end

if (salvar>0)
	SILOP_CONFIG.BUS.File=struct('Salvar',salvar);
	if (nargin<2)
		SILOP_CONFIG.BUS.File.Name='datos.sl';
	else
		SILOP_CONFIG.BUS.File.Name=fichero;			
	end
	save('config.mat','SILOP_CONFIG');
end

Comandos = creacomandos(SILOP_CONFIG);
%Se encarga de crear los comandos para la llamada a las funciones a partir de la informaci�n de algoritmos a procesar

if (SILOP_CONFIG.BUS.Temporizador~=-1)
    start(SILOP_CONFIG.BUS.Temporizador);
elseif (isstruct(SILOP_CONFIG.BUS.Xbus))
    [SILOP_CONFIG.BUS.Xbus]=iniciacaptura(SILOP_CONFIG.BUS.Xbus);
end

while(getkey()~=27) %tecla ESC
	hay_datos = ~isempty(SILOP_DATA_BUFFER);
	if(hay_datos)
       		if(isnan(SILOP_DATA_BUFFER)) 
			%En caso de emulación, el proceso simulado de muestro hace NaN la variable
			%cuando se acaban los datos
       			break;
       		end;
   
        	disp('procesando datos ...');
  
       		%%Lo primero que se hace es almacenar la captura en una variable
       		%%auxiliar y vaciar el buffer para dejar espacio a nuevas capturas.
       		datos_nuevos = SILOP_DATA_BUFFER;
        	SILOP_DATA_BUFFER = [];
         
       		%%Se actualiza la ventana de datos, y se mete la información muestreada 
		    %%en las primeras columnas. 
        	[fdn, cdn] = size(datos_nuevos);
       		VENTANA = desplaza(VENTANA, fdn, SILOP_CONFIG.GLOBAL.LONGITUDVENTANA);
       		[fv, cv] = size(VENTANA); %#ok<NASGU>
       		VENTANA(fv-fdn+1:end, 1:cdn) = datos_nuevos;

       		%Se procesan los comandos
       		ncomandos = length(Comandos);
       		for k=1:ncomandos
       	    		comando = Comandos{k};
       	    		eval(comando);
       		end;
		if (salvar>0)
			save('datos.log','datos_nuevos','-ASCII','-APPEND');
		end
		if (salvar>1)
			newalgo=VENTANA(fv-fdn+1:end, cdn+1:end); %#ok<NASGU>
			save('datos_alg.log','newalgo','-ASCII','-APPEND');		
		end        

	end
end;
stopsilop();




function comandos = creacomandos(C)
    nalgoritmos = length(C.ALGORITMOS);
    comandos = cell(1, nalgoritmos);

    for k=1:nalgoritmos
         alg = C.ALGORITMOS(k);
         posiciones = alg.posiciones;
         nretornos = length(posiciones);

         subcad = [];

         if(nretornos>0)
             retornos = sprintf('[VENTANA(:, %d)', posiciones(1));
             for t = 2:nretornos
                 retornos = [retornos sprintf(', VENTANA(:, %d)', posiciones(t))]; %#ok<AGROW>
             end;
             retornos = [retornos ']']; %#ok<AGROW>
             subcad = [retornos '='];
         end;

         subcad = [subcad sprintf('%s(', alg.nombre)]; %#ok<AGROW>

         if(nretornos>0)
             vsen = sprintf('%d, ', alg.posiciones);
             retornos = sprintf('VENTANA(:,[%s])', vsen(1:end-2));
         else
             retornos = '[]';
         end;

         subcad = [subcad retornos ]; %#ok<AGROW>
         %OJO, que falta el igual

         vsen = sprintf('%d, ', alg.senhales);
         subcad = [subcad sprintf(', VENTANA(:, [%s])', vsen(1:end-2))]; %#ok<AGROW>

          if(~isempty(alg.parametros))
              cad_params = sprintf(', SILOP_CONFIG.ALGORITMOS(%d).parametros', k);
          else
              cad_params=[', []']; %#ok<NBRAK>
          end;

          subcad = [subcad cad_params]; %#ok<AGROW>

          if(~isempty(alg.dependencias))
              l = length(alg.dependencias);

               for t=1:l
                   deps = alg.dependencias{t};
                   vsen = sprintf('%d, ', deps); 
                   subcad = [subcad sprintf(', VENTANA(:,[ %s])', vsen(1:end-2))]; %#ok<AGROW>
               end;

          end;

          subcad = [subcad ');']; %#ok<AGROW>

          comandos{k} = subcad;
    end;






function res = desplaza(mat, cuantos, long_maxima)

[f, c] = size(mat);
unos = ones(cuantos, c)*NaN;

if(f+cuantos<=long_maxima)
    res = [mat; unos];
else
    res = [mat(f-(long_maxima-cuantos)+1:end,:); unos];
end;
