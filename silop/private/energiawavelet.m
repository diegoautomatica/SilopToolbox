% ENERGIAWAVELET realizar la descomposici�n wavelet de una se�al
%
% ENERGIAWAVELET realizar la descomposici�n wavelet de una se�al
% 
% Syntax: [energiatotal,desvstdwavelet,valorRMS]=energiawavelet(aceleracion)
% 
% Input parameters:
%   aceleracion-> se�al a procesar
%
% Output parameters:
%   energiatotal->Vector que tiene las energ�as de cada una de las componentes
%		wavelet obtenidas de la descomposici�n de la se�al aceleracion.
%   desvstdwavelet->Vector que tiene las desviaciones est�ndar de cada una de
%              las componentes wavelet.
%   valorRMS->Vector que contiene los valores RMS de energ�a para cada wavelet
%   
%
% Examples:
%
% See also: 

% Author:   Jesus Coautor(Antonio)
% History:  xx.yy.zz    crea el archivo
%           03.01.2008  incorporada a la toolbox
%           21.01.2008  documentada y cambiada de nombre



%realiza la descomposici�n wavelet de la se�al de aceleraci�n
function [energiatotal,desvstdwavelet,valorRMS]=energiawavelet(aceleracion) 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Descomposici�n wavelet de la se�al
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Realizaci�n de la descomposici�n de paquetes wavelet

%Como wavelet "madre" se utilizar� una Daubechies de orden 5 'db5'
[a1,d1]=dwt(aceleracion,'db5');
[aA2,aD2]=dwt(a1,'db5');
[aA3,aD3]=dwt(aA2,'db5');
[aA4,aD4]=dwt(aA3,'db5');
[aA5,aD5]=dwt(aA4,'db5');
[aA6,aD6]=dwt(aA5,'db5');    
[dA2,dD2]=dwt(d1,'db5'); %#ok<NASGU>
[dA3,dD3]=dwt(dA2,'db5');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%C�lculo de las energ�as y valores RMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%C�lculo de la energ�a de la wavelet sumando las energ�as de:
%aD6, aD5, aD4, aD3, aD2, dA3, dD3
%Tambi�n se aprovechar� para calcular el valor eficaz
energiaaD6=0; energiaaD5=0; energiaaD4=0; energiaaD3=0;
energiaaD2=0; energiadA3=0; energiadD3=0;
   
for j=1:length(aD6)
    energiaaD6=energiaaD6+aD6(j)*aD6(j);
end
%RMSaD6=sqrt(energiaaD6/length(aD6));
    
for j=1:length(aD5)
    energiaaD5=energiaaD5+aD5(j)*aD5(j);
end
RMSaD5=sqrt(energiaaD5/length(aD5));
    
for j=1:length(aD4)
    energiaaD4=energiaaD4+aD4(j)*aD4(j);
end    
RMSaD4=sqrt(energiaaD4/length(aD4));
    
for j=1:length(aD3)
    energiaaD3=energiaaD3+aD3(j)*aD3(j);
end    
RMSaD3=sqrt(energiaaD3/length(aD3));
    
for j=1:length(aD2)
    energiaaD2=energiaaD2+aD2(j)*aD2(j);
end    
RMSaD2=sqrt(energiaaD2/length(aD2));
    
for j=1:length(dA3)
    energiadA3=energiadA3+dA3(j)*dA3(j);
end    
RMSdA3=sqrt(energiadA3/length(dA3));
    
for j=1:length(dD3)
    energiadD3=energiadD3+dD3(j)*dD3(j);
end
RMSdD3=sqrt(energiadD3/length(dD3));

%Vector que contiene los valores RMS de cada una de las se�ales wavelet
valorRMS=[RMSaD5 RMSaD4 RMSaD3 RMSaD2 RMSdA3 RMSdD3];

energiainf=energiaaD6+energiaaD5+energiaaD4+energiaaD3+energiaaD2;
energiasup=energiadA3+energiadD3;
energiatotal=energiainf+energiasup;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Segunda forma de hallar la enrg�a de la se�al
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% energiaa1=0; energiad1=0;
% for j=1:length(energiaa1)
%     energiaa1=energiaa1+a1(j)*a1(j);
% end
% 
% for j=1:length(energiad1)
%     energiad1=energiad1+d1(j)*d1(j);
% end    
% 
% energiamasajustada=energiaa1+energiad1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculo de la desviaci�n est�ndar de la se�al
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%El c�lculo de la desviaci�n est�ndar se realizar� mediante la funci�n
%std(vector)
desvstdaD5=std(aD5);
desvstdaD4=std(aD4);
desvstdaD3=std(aD3);
desvstdaD2=std(aD2);
desvstddA3=std(dA3);
desvstddD3=std(dD3);
desvstdwavelet=[desvstdaD5 desvstdaD4 desvstdaD3 desvstdaD2 desvstddA3 desvstddD3];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
