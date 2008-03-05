function [eventos]=eventosPiernaG(tibia_L, tibia_R,fh)
%
% Detecta los eventos del paso a partir de las velocidades de giro de las
% tibias izquierda y derecha.
%
%   [eventos]=eventosPiernaG(tibia_L, tibia_R)

% Corrige el signo para que el maximo absoluto sea positivo
[m,p]=max(abs(tibia_L));
if (tibia_L(p)<0)
    tibia_L=-tibia_L;
end
[m,p]=max(abs(tibia_R));
if (tibia_R(p)<0)
    tibia_R=-tibia_R;
end

% Filtra las se�ales mas bajas.
% El umbral se fija en 0.75 rad/s
%tibia_L=tibia_L.*(abs(tibia_L)>0.55);
%tibia_R=tibia_R.*(abs(tibia_R)>0.55);


n=4;
filtro=ones(2*n+1,1); filtro=filtro/sum(filtro);
tmp_signal=conv(tibia_L,filtro);
tmp_signal=tmp_signal(1+n:end-n);
MSL1=picos(tmp_signal.*(tmp_signal>0),11);
MSL2=picos(tmp_signal.*(tmp_signal<0),7);

n=4;
filtro=ones(2*n+1,1); filtro=filtro/sum(filtro);
tmp_signal=conv(tibia_R,filtro);
tmp_signal=tmp_signal(1+n:end-n);
MSR1=picos(tmp_signal.*(tmp_signal>0),11);
MSR2=picos(tmp_signal.*(tmp_signal<0),7);

%r1=[];
%r2=[];
eventos=zeros(length(tibia_L),8);
for k=MSL1'
    k2=(find(abs(MSR2-k)<15));
    if (any(k2) && tibia_L(k)>1)
        eventos(k,1)=1;
        eventos(MSR2(k2),6)=1;
    end,
end
for k=MSR1'
    k2=find(abs(MSL2-k)<15);
    if (any(k2) && tibia_R(k)>1)
        eventos(k,5)=1;
        eventos(MSL2(k2),2)=1;
    end,
end

% Buscar HS
MSL1=find(eventos(:,1)); % Evento Midstance del swing en la pierna izda
MSL2=find(eventos(:,2)); % Evento Midstance de la fase de apoyo izda
MSR1=find(eventos(:,5)); % Evento Midstance del swing en la pierna dcha
MSR2=find(eventos(:,6)); % Evento Midstance de la fase de apoyo dcha

for k=1:length(MSL1) % para cada evento midstance detectado
    % se busca el midstance correspondiente a la fase de apoyo de la misma
    % pierna que verifique: ser posterior y que no este a mas de 2
    % segundos.
    k2=find(MSL2>MSL1(k) & MSL2<min(MSL1(k)+2*64,length(tibia_L)),1);
    if (~isempty(k2))
        % si se ha encontrado al menos un k2, se buscan picos a escala 1
        % entre k1 y k2
        [pmax,pmin]=picos(tibia_L(MSL1(k):MSL2(k2)),1);
        % Nos quedamos con los maximos que siguen al primer minimo
        pmax=pmax(find(pmax>pmin(1))); %#ok<FNDSB>
        if (~isempty(pmin))
            % Marcamos el primer minimo como un posible HS
            eventos(pmin(1)+MSL1(k)-1,3)=1; 
        end
        if (~isempty(pmax))
            % Marcamos el maximo que sigue el primer minimo como el segundo
            % candido a HS
            eventos(pmax(1)+MSL1(k)-1,3)=2;
        end
        if (length(pmin)>1)
            % El segundo m�nimo es el siguiente candidato a HS
            eventos(pmin(2)+MSL1(k)-1,3)=3;
        end
    end
end
for k=1:length(MSR1)
    k2=find(MSR2>MSR1(k) & MSR2<min(MSR1(k)+2*64,length(tibia_R)),1);
    if (~isempty(k2))
        [pmax,pmin]=picos(tibia_R(MSR1(k)+5:MSR2(k2)),1);
        pmax=pmax(find(pmax>pmin(1))); %#ok<FNDSB>
        if (~isempty(pmin))
            eventos(pmin(1)+MSR1(k)+4,7)=1;
        end
        if (~isempty(pmax))
            eventos(pmax(1)+MSR1(k)+4,7)=2;
        end
        if (length(pmin)>1)
            eventos(pmin(2)+MSR1(k)+4,7)=3;
        end
    end
end

% Buscar TO
for k=1:length(MSL2) % Para cada evento midstance de la fase de apoyo
    % se busca el siguiente midstance correspondiente a una fase de swing
    k2=find(MSL1>MSL2(k) & MSL1<min(MSL2(k)+64,length(tibia_L)),1);
    if (~isempty(k2))
        % si se encontro
        % se busca el evento TO como el m�nimo absoluto entre ambos eventos
        % de midswing
        [m,p]=min(tibia_L(MSL2(k):MSL1(k2)));
        eventos(p+MSL2(k)-1,4)=1;
    end
end
for k=1:length(MSR2)
    k2=find(MSR1>MSR2(k) & MSR1<min(MSR2(k)+64,length(tibia_R)),1);
    if (~isempty(k2))
        [m,p]=min(tibia_R(MSR2(k):MSR1(k2)));
        eventos(p+MSR2(k)-1,8)=1;
    end
end

if (nargin>2)
    figure;
    plot(tibia_L)
    hold
    plot(tibia_R,'g')
    plot(find(eventos(:,6)),tibia_R(find(eventos(:,6))),'m*'); %#ok<FNDSB>
    plot(find(eventos(:,5)),tibia_R(find(eventos(:,5))),'ms'); %#ok<FNDSB>
    plot(find(eventos(:,7)),tibia_R(find(eventos(:,7))),'md'); %#ok<FNDSB>
    plot(find(eventos(:,8)),tibia_R(find(eventos(:,8))),'mo'); %#ok<FNDSB>
    plot(find(eventos(:,2)),tibia_L(find(eventos(:,2))),'r*'); %#ok<FNDSB>
    plot(find(eventos(:,1)),tibia_L(find(eventos(:,1))),'rs'); %#ok<FNDSB>
    plot(find(eventos(:,3)),tibia_L(find(eventos(:,3))),'rd'); %#ok<FNDSB>
    plot(find(eventos(:,4)),tibia_L(find(eventos(:,4))),'ro'); %#ok<FNDSB>
end




function [pmax,pmin,plocal]=picos(datos,n)


%der_dch=[diff(datos); 0];
%der_izd=[0; diff(datos)];
%minimos=[];
%maximos=[];

prod=[];
for desp=1:n
    prod=[prod [datos((desp+1):end)-datos(1:(end-desp)); zeros(desp,1)].*[zeros(desp,1); datos((desp+1):end)-datos(1:(end-desp))]]; %#ok<AGROW>
end
prod=all(prod<0,2);
p=find(prod);

% Determinar si son maximos o minimos
tmp=(ones(length(p),1)*(-n:n)+p*ones(1,2*n+1));
tmp=datos(tmp);
minimos=(datos(p)==min(tmp,[],2));
maximos=(datos(p)==max(tmp,[],2));
pmax=[p maximos minimos];

if (nargout>1)
    pmax=p(find(maximos)); %#ok<FNDSB>
    pmin=p(find(minimos)); %#ok<FNDSB>
    plocal=p(find(~maximos & ~minimos)); %#ok<FNDSB>
end