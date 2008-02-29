%% SILOPDEMO Demostración de las capacidades de la toolbox
% SILOPDEMO Muestra la forma de usar la toolbox para el desarrollo rápido de aplicaciones mediante 
% un ejemplo de uso
%


%% Se crea la configuración inicial para la ejecución de la aplicación
% llamando a initsilop()
initsilop(); %Crea un conjunto de variables necesarias al principio.

%Temporalmente trabajaremos con una global en silopdemo para que siga funcionando todo
global SILOP_CONFIG
CONFIG=SILOP_CONFIG;


%% Se añaden los IMUS con los que se trabajará
% En este caso un IMU en el COG
CONFIG = addimu(CONFIG, 'COG', 204);


%% Nos conectamos al sistema de adquisición de datos.
% En este caso escogemos hacerlo trabajando en simulación y con un fichero
% de log
CONFIG = connectsilop(CONFIG,1); %Conectamos al sistema de muestreo


%% Creamos abreviaturas de los nombres de las señales
% De esta forma las podremos usar más comodamente 

Acc_X=CONFIG.SENHALES.COG.Acc_X;
Acc_Y=CONFIG.SENHALES.COG.Acc_Y;
Acc_Z=CONFIG.SENHALES.COG.Acc_Z;
G_Z=CONFIG.SENHALES.COG.G_Z;

%% Añadimos los algoritmos necesarios.
% Añadimos el algoritmo de deteccion de eventos, para localizar los instantes de HS y TO

CONFIG = addalgoritmo(CONFIG, 'alg_det_event', 2, [Acc_Z, Acc_X], [], {});

%% Añadimos los algoritmos restantes,
% medicion de pasos, estimacion de la orientacion, calculo de posiciones 2d
% y representación de la posición en 2d

CONFIG = addalgoritmo(CONFIG, 'alg_est_dist_pendulo' , 1, [Acc_Z], [], {'alg_det_event'});
CONFIG = addalgoritmo(CONFIG, 'alg_est_orient_gyro', 1, [G_Z], [], {});
CONFIG = addalgoritmo(CONFIG, 'alg_est_2d', 2, [], [], {'alg_est_dist_pendulo'  'alg_est_orient_gyro'});
CONFIG = addalgoritmo(CONFIG, 'alg_plot_pos2d', 0, [], [], {'alg_est_2d'});
    
%% Se pone en marcha el proceso
% Se detiene mediante la pulsación de la tecla ESC
CONFIG=playsilop(CONFIG,2);




