%ALG_EJES_ANATOMICOS Algoritmo para la calibracion fina de los datos
%procedentes del Xsens.  
%
%ALG_EJES_ANATOMICOS Algoritmo para la calibracion fina de los datos procedentes del Xsens. 
%  No funciona con simulaciones desde un .log. Si se desea trabajar en simulacion con datos que tengan 
%  calibracion fina se deben emplear ficheros .tana o .sl, que ya están
%  correctamente calibrados.
%Se puede configurar mediante:
%    addalgoritmo('alg_ejes_anatomicos', 0, {'COG.Acc_X','COG.Acc_Y','COG.Acc_Z'}, {'COG'}, {});
%
%Parametros: como todos los alg_ resultados anteriores, 
% señales a usar (las tres aceleraciones de cada sensor a calibrar)
% parametros(lista con los nombres de los sensores a calibrar, en el mismo orden que las señales) 
% y dependencias(vacia en este caso)

%Creado: 19-02-2008 by Diego �lvarez


%Aviso para los programadores. Este es un algoritmo MUY especial, al
%necesitar acceso al dispositivo XbusMaster. No se debe usar como modelo de
%programación de algoritmos.

function corregido = alg_ejes_anatomicos(previos, senhales, params, dependencias) %#ok<STOUT,INUSD,INUSL>

    global SILOP_CONFIG
    persistent done
    
    if (isempty(done))
        done=0;
    end
    
    [filas,columnas]=size(senhales);
    if ((~done)&&(filas>=200)) %Si tenemos datos y aun no hemos actualizado
        %Se comprueba que se tengan datos
        if (columnas==0)
            error('no se han proporcionado señales a alg_ejes_anatomicos');
        end
        if (isempty(params))
            error('no se indica el lugar al que corresponden las señales en alg_ejes_anatomicos');
        end
        %En primer lugar comprobamos si estamos en modo Xbus
        if (SILOP_CONFIG.BUS.Xbus~=-1)
            id_disp=zeros(1,SILOP_CONFIG.BUS.Xbus.ndisp);
            for k=1:SILOP_CONFIG.BUS.Xbus.ndisp
                id_disp(k)=eval(SILOP_CONFIG.BUS.Xbus.sensores.Cadena(:,k));
            end
    	
            num_sensor=1;
            for donde=params %lista de sensores a corregir
                %Buscamos el dispositivo en cada punto
                if (eval(['SILOP_CONFIG.SENHALES.',donde{1},'.Serie~=-1']))
                    p=eval(['find(id_disp==SILOP_CONFIG.SENHALES.',donde{1},'.Serie)']);
                    %Se calcula la matriz de correccion
                    [filas,columnas]=size(senhales);
                    if (columnas<3*num_sensor)
                        [basura,Rot]=ejes_anatomicos(senhales(:,3*num_sensor-2:3*num_sensor),senhales(:,3*num_sensor-2:3*num_sensor),[1,2,3]);
                        SetObjectAlignment(SILOP_CONFIG.BUS.Xbus,p,Rot); %O la transpuesta, no estoy seguro                                                                                             
                    else
                        error('el numero de señales en alg_ejes_anatomicos es insuficiente');
                    end
                else 
                    error('No existe el sensor indicado en alg_ejes_anatomicos');
                end
                num_sensor=num_sensor+1;
            end
            done=1;
        else
            error('se esta usando una funcion de calibracion fina que solo esta disponible con el XbusMaster');
        end
    end