function comandos = CreaComandos(C)
    nalgoritmos = length(C.ALGORITMOS);
    comandos = cell(1, nalgoritmos);


    for k=1:nalgoritmos
         alg = C.ALGORITMOS(k);
         posiciones = alg.Posiciones;
         nretornos = length(posiciones);


         subcad = [];

         if(nretornos>0)
             retornos = sprintf('[VENTANA(:, %d)', posiciones(1));
             for t = 2:nretornos
                 retornos = [retornos sprintf(', VENTANA(:, %d)', posiciones(t))];
             end;
             retornos = [retornos ']'];


             subcad = [retornos '='];

         end;


         subcad = [subcad sprintf('%s(', alg.Nombre)];


         if(nretornos>0)
             vsen = sprintf('%d, ', alg.Posiciones);

             retornos = sprintf('VENTANA(:,[%s])', vsen(1:end-2));
         else
             retornos = '[]';
         end;

         subcad = [subcad retornos ];

         %OJO, que falta el igual


         vsen = sprintf('%d, ', alg.Senhales);
         subcad = [subcad sprintf(', VENTANA(:, [%s])', vsen(1:end-2))];


          if(~isempty(alg.Parametros))
              cad_params = sprintf(', CONFIG.ALGORITMOS(%d).Parametros', k);
          else
              cad_params=[', []'];
          end;

          subcad = [subcad cad_params];

          if(~isempty(alg.Dependencias))
              l = length(alg.Dependencias);

               for t=1:l
                   deps = alg.Dependencias{t};
                   vsen = sprintf('%d, ', deps); 
                   subcad = [subcad sprintf(', VENTANA(:, %s)', vsen(1:end-2))];
               end;
          end;

          subcad = [subcad ');'];

          comandos{k} = subcad;

    end;
