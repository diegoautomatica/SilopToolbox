%ALG_DESP_ACC Algoritmo para estimar la aceleración de un punto
% de un solido rígo en base a la aceleración de otro punto y la 
% velocidad angular
%
%Se puede configurar mediante:
%    addalgoritmo('alg_desp_acc',{'codo.AabX','codo.AabY''codo.AabZ'},{'antebrazo.Acc_X','antebrazo.Acc_Y','antebrazo.Acc_Z','antebrazo.G_X','antebrazo.G_Y','antebrazo.G_Z'},[]);

%
%Parametros: como todos los alg_ resultados anteriores, senales a usar y
%parametros (vacio, por ahora)

function [AccX,AccY,AccZ] = alg_desp_acc(previos, senhales, params) %#ok<INUSD>

    AccX=previos(:,1);
    AccY=previos(:,2);
    AccZ=previos(:,3);
    sc = find(isnan(previos(:,1))); %#ok<EFIND> %Filas a�n no procesadas
    sc=sc';
    if (sc(1)>10)
        sc= [sc(1)-10:sc(1)-1,sc];
    end
    sc=sc';
    if (~isempty(sc))
        accx=senhales(sc,1);
        accy=senhales(sc,2);
        accz=senhales(sc,3);
        acc=[accx,accy,accz];
        wx=senhales(sc,4);
        wy=senhales(sc,5);
        wz=senhales(sc,6);
        w=[wx,wy,wz];
    
        alfax=[0;diff(wx)]*50; %frecuencia debe ser un parametro
        alfay=[0;diff(wy)]*50; %frecuencia debe ser un parametro
        alfaz=[0;diff(wz)]*50; %frecuencia debe ser un parametro
    
        %orden=8;filtro=ones(1,orden)/orden;
        %alfax=conv(alfax,filtro);
        %alfay=conv(alfay,filtro);
        %alfaz=conv(alfaz,filtro);
        %alfax=alfax(orden/2+1:end-orden/2+1);
        %alfay=alfay(orden/2+1:end-orden/2+1);
        %alfaz=alfaz(orden/2+1:end-orden/2+1);
        
        alfa=[alfax,alfay,alfaz];
        
        r=ones(length(sc),1)*params;
        Acc=acc-cross(alfa,r)-cross(w,cross(w,r));
        AccX(sc)=Acc(:,1);
        AccY(sc)=Acc(:,2);
        AccZ(sc)=Acc(:,3);
    end
