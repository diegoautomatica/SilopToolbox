%ALG_EJES_ANATOMICOS Algoritmo para la calibracion fina de los datos
%procedentes del Xsens.  
%
%ALG_EJES_ANATOMICOS Algoritmo para la calibracion fina de los datos procedentes del Xsens. 
%  No funciona con simulaciones desde un .log. Si se desea trabajar en simulacion con datos que tengan 
%  calibracion fina se deben emplear ficheros .tana o .sl, que ya están
%  correctamente calibrados.
%Se puede configurar mediante:
%    addalgoritmo('alg_ejes_anatomicos', 0, {'COG.Acc_X','COG.Acc_Y','COG.Acc_Z'}, {'COG'});
%
%Parametros: como todos los alg_ resultados anteriores, 
% señales a usar (las tres aceleraciones de cada sensor a calibrar)
% parametros(lista con los nombres de los sensores a calibrar, en el mismo
% orden que las señales). 

%Creado: 19-02-2008 by Diego �lvarez


%Aviso para los programadores. Este es un algoritmo MUY especial, al
%necesitar acceso al dispositivo XbusMaster. No se debe usar como modelo de
%programación de algoritmos.

function corregido = alg_ejes_anatomicos(previos, senhales, params) %#ok<STOUT,INUSD,INUSL>

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
        if (isfield(SILOP_CONFIG.BUS,'Xbus'))
            id_disp=zeros(1,SILOP_CONFIG.BUS.Xbus.ndisp);
            for k=1:SILOP_CONFIG.BUS.Xbus.ndisp
                id_disp(k)=SILOP_CONFIG.BUS.Xbus.sensores.Cadena(:,k);
            end
    	
            num_sensor=1;
            for donde=params %lista de sensores a corregir
                %Buscamos el dispositivo en cada punto
                if (SILOP_CONFIG.SENHALES.(donde{1}).Serie~=-1)
                    p=find(id_disp==SILOP_CONFIG.SENHALES.(donde{1}).Serie);
                    %Se calcula la matriz de correccion
                    [filas,columnas]=size(senhales);
                    if (columnas>=3*num_sensor)
                        driver_Xbus('gotoconfig',SILOP_CONFIG.BUS.Xbus);
                        SILOP_CONFIG.BUS.Xbus=ReqObjectAlignment(SILOP_CONFIG.BUS.Xbus,p);
                        Rot1=SILOP_CONFIG.BUS.Xbus.Conf.Dev(p).Orientacion;%Rotacion original
                        nocero=find(senhales(:,3*num_sensor)~=0);
                        [basura,Rot2]=ejes_anatomicos(senhales(nocero,3*num_sensor-2:3*num_sensor),senhales(nocero,3*num_sensor-2:3*num_sensor),[1,2,3]);
                        SetObjectAlignment(SILOP_CONFIG.BUS.Xbus,p,Rot2*Rot1); %Comprobar si no sería Rot2'*Rot1
                        SILOP_CONFIG.BUS.Xbus =  driver_Xbus('gotomeasurement',SILOP_CONFIG.BUS.Xbus);
                        SILOP_CONFIG.SENHALES.(donde{1}).Rotacion=Rot2*Rot1';
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
