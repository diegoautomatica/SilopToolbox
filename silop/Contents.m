% InerSens Toolbox
% Version 0.13 16-05-2013
%Copyright (C) 2007-2008 Universidad de Oviedo
%Todos los derechos reservados
%
%Esta toolbox se distribuye de acuerdo con la licencia públic general GNU (GPL v3).
% SiLoP Toolbox, files in directory  silop/
%
%
% AutoAdd
% addalgoritmo  - ADDALGORITMO Añade un algoritmo al sistema de procesamiento de las aplicaciones estandar de la toolbox
% addimu        - ADDIMU Añade un IMU al sistema de procesamiento de las aplicaciones estandar de la toolbox
% buscamaximos  - BUSCAMAXIMOS Detecta todos los m�ximos de una se�al
% buscamaximosth - BUSCAMAXIMOS Detecta todos los m�ximos de una se�al despu�s de aplicar un threshold
% connectsilop  - CONNECTSILOP Conecta el sistema de procesamiento con los sensores previamente especificados
% datacrop      - DATACROP Elimina manualmente un rango de datos de un archivo de xsens.
% distancia_arco - DISTANCIA_ARCO Calcula la distancia recorrida en un paso basandose en el modelo de movimiento angular 
% distancia_pendulo - DISTANCIA_PENDULO Calcula la distancia recorrida en un paso mediante el modelo del pendulo invertido desde el COG
% distancia_penduloparcial - DISTANCIA_PENDULOPARCIAL Calcula la distancia recorrida en un paso mediante el modelo del pendulo invertido 
% distancia_raizcuarta - DISTANCIA_RAIZCUARTA Calcula la distancia recorrida en un paso mediante el modelo emp�rico de la raiz cuarta
% ejes_anatomicos - EJES_ANATOMICOS Reorienta los datos obtenidos para que coincidan con los ejes anat�micos.
% entrena_ident_act - ENTRENA_IDENT_ACT permite entrenar una red neuronal que identificar� las actividades realizadas por un individuo.
% evaluasalto   - EVALUASALTO Estima la duración de cada salto individual en función de los datos devueltos
% evaluasentadillas - EVALUASENTADILLAS Calcula los par�metros m�s relevantes de un conjunto de sentadillas en funci�n de los datos devueltos
% eventos_RT    - EVENTOSRT Deteccion de Initial Contact y End Contact en Tiempo Real con acelerometro en
% eventosCOGrecto - EVENTOSCOGRECTO Detecta 5 eventos a partir de las acelerariones verticales y horizontales del COG. Funci�n Off-line
% eventosPiernaG - Detecta los eventos del paso a partir de las velocidades de giro de las
% eventospiraguas - EVENTOSPIRAGUAS Detecta el evento principal de la palada (pala perpendicular al agua?)
% eventossalto  - EVENTOSSALTO Detecta 4 eventos a partir de las acelerariones verticales
% eventossentadillas - EVENTOSSENTADILLAS Detecta 3 eventos a partir de las acelerariones verticales
% eventpierectoff - EVENTPIERECTOFF Deteccion de los eventos con un giro sobre el pie
% filtro0       - FILTRO0 Filtro paso bajo de fase cero
% frecuenciapaladas - FRECUENCIAPALADAS Devuelve una señal con la frecuencia de palada. 
% ident_act     - IDENT_ACT Identifica la actividad que se est� realizando
% initsilop     - INITSILOP Inicializa el sistema de procesamiento de las aplicaciones estandar de la toolbox
% integrasig    - INTEGRASIG Integra una senyal hasta un instante, incluyendo reseteo
% limpia_estatico - LIMPIA_ESTATICO Detecta fases estaticas (sin desplazamiento).
% loadsilop     - LOADSILOP Carga los datos de un fichero de almacenamiento .sl.
% orientacioncompas - ORIENTACIONCOMPAS Calcula la orientación en base a los datos de una brújula/compás situada en el COG
% orientaciongiroscopo - ORIENTACIONGIROSCOPO Calcula la orientación en base a los datos de un giróscopo situado en el COG
% orientacionkalman - ORIENTACIONKALMAN Calcula la orientación en base a los datos de un giróscopo y un compás situados en el COG
% playsilop     - PLAYSILOP Realiza el procesamiento de acuerdo a los IMUS y algoritmos indicados
% savesilop     - SAVESILOP Guarda los datos en un fichero de almacenamiento .sl.
% silopdemo     - % SILOPDEMO Demostración de las capacidades de la toolbox
% stopsilop     - STOPSILOP Detiene el procesamiento de las señales, así como las comunicaciones con los buses 

