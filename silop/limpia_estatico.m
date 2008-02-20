% LIMPIA_ESTATICO Detecta fases estaticas (sin desplazamiento).
%
% LIMPIA_ESTATICO Funcion para detectar los instantes de tiempo en los que se permanece estatico
% al principio de los experimentos, basado en que la se馻l de los tres
% aceler髆etros no cambia en menos de.... Devuelve...    
%
% Sintax: [estatico,aceleraciones]=limpia_estatico(aceleraciones,freq)
%
% Par醡etros de entrada:
%    Aceleraciones    - matriz (nx3) con las aceleraciones antero-posterior, medio-lateral y
%                       vertical (en orden estandar del xsens)
%    freq             - frecuencia de muestreo en Hzs
%
% Par醡etros de salida:
%    estatico         - un array (nx1) indicando si el individuo est谩 est谩tico o en movimiento
%                      en cada instante de tiempo
%    Aceleraciones    - las aceleraciones originales, en las que se ha eliminado toda la 
%                      variabilidad correspondiente a los instantes de tiempo est谩ticos.
%                       AccHorizontal=AccMedioLateral=0, AccVertical=9.81
%
% Examples:
%
% See also:
%
% Bugs: No comprueba los par醡etros de entrada

% Author:   Rafael C. 
% History:  12.11.2000  file created
%                       full description at the top
%           19.11.2000  suggestions for in-code comments added
%           12.12.2008  Adaptada correctamente a la toolbox.

function [estatico,Aceleraciones]=limpia_estatico(Aceleraciones,freq)

%Falta el testeo de entradas...

%Detecci贸n de instantes sin aceleraci贸n
tmph=abs(Aceleraciones(:,1))<1;
tmpm=abs(Aceleraciones(:,2))<1;
tmpv=abs(Aceleraciones(:,3)-9.81)<1;
tmp0=tmph.*tmpm.*tmpv;

%Detecci贸n de intervalos de 1 d茅cima de segundo sin aceleraci贸n
tiempo0=conv(tmp0(1:end-freq/10+1),ones(1,freq/10));
estatico=tiempo0<10;

%Si se quieren las aceleraciones corregidas se recalculan
if nargout==2
	Aceleraciones(:,1)=Aceleraciones(:,1).*estatico;
	Aceleraciones(:,2)=Aceleraciones(:,2).*estatico;
	Aceleraciones(:,3)=Aceleraciones(:,3).*estatico+9.81*(1-estatico);
end
