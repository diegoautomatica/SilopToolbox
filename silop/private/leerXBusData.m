% LEERXBUSDATA Lee datos desde el dispositivo Xbus Master
%
% LEERXBUSDATA Lee datos desde el dispositivo Xbus Master. Esta función
% está pensada para ser usada desde una callback, y no directamente desde
% una función/script
% 
% Syntax: leerXBusData(obj,event,XBusMaster)
% 
% Input parameters:
%     obj 	-> Parámetro 1 de la callback
%     event     -> Parámetro 2 de la callback
%     XBusMaster-> Objeto con la información del dispositivo.
%
% Output parameters:
%   Ninguno, los datos obtenidos quedan en la variable global SILOP_DATA_BUFFER
%
% Examples:
%
% See also: creaxbusmaster, destruyexbusmaster

% Author:   Rafael C. Gonzalez de los Reyes
% History:  04.12.07    creacion del archivo
%           18.12.07    pasada a private por Diego. Se conserva .doc en private-SilopToolbox.doc
%           21-01.08    comentada la variable global iter que no se usa





%Lee datos del buffer. Llamada por una callback
function leerXBusData(obj,event,XBusMaster) %#ok<INUSL>

global SILOP_DATA_BUFFER;
%global iter;

%iter=iter+1;

% if (mod(iter,500)==0)
%     obj.RequestToSend='off';
% end
data=fread(obj,[XBusMaster.DataLength XBusMaster.nm],'uint8');

%obj
%disp(event.Type)
%disp(event.Data.AbsTime)

% Procesar los datos de 1 mensaje

%checksum
if (any(mod(sum(data(2:end,:)),256)) )
    disp('>>>> ERROR de checksum');
end
% tipo de mensaje
if (any(data(3,:)-50))
    disp('>>>> ERROR de tipo de mensaje');
end
% procesar la informacion
muestra=([256 1]*data(5:6,:))';
q=quantizer('Mode','single');
SILOP_DATA_BUFFER=[];
for k=1:XBusMaster.ns
    ax=hex2num(q,reshape(sprintf('%02X',data((7:10)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); %hex2num(q,sprintf('%02X',data(7:10)));
    ay=hex2num(q,reshape(sprintf('%02X',data((11:14)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); %hex2num(q,sprintf('%02X',data(11:14)));
    az=hex2num(q,reshape(sprintf('%02X',data((15:18)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); %hex2num(q,sprintf('%02X',data(15:18)));
    rx=hex2num(q,reshape(sprintf('%02X',data((19:22)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); %hex2num(q,sprintf('%02X',data(19:22)));
    ry=hex2num(q,reshape(sprintf('%02X',data((23:26)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); %hex2num(q,sprintf('%02X',data(23:26)));
    rz=hex2num(q,reshape(sprintf('%02X',data((27:30)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); %hex2num(q,sprintf('%02X',data(27:30)));
    mx=hex2num(q,reshape(sprintf('%02X',data((31:34)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); %hex2num(q,sprintf('%02X',data(31:34)));
    my=hex2num(q,reshape(sprintf('%02X',data((35:38)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); %hex2num(q,sprintf('%02X',data(35:38)));
    mz=hex2num(q,reshape(sprintf('%02X',data((39:42)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 XBusMaster.nm])'); %hex2num(q,sprintf('%02X',data(39:42)));
    %if (XBusMaster.modo==2)
        % corregir la orientacion
        %R=reshape(hex2num(q,reshape(sprintf('%02X',data((43:78)+(k-1)*XBusMaster.Conf.Dev(1).DataLength,:)),[8 9*XBusMaster.nm])'),[9 XBusMaster.nm]); %hex2num(q,sprintf('%02X',data(7:10)));
    %end
    %SILOP_DATA_BUFFER=[flipud([muestra ax ay az rx ry rz mx my mz]); SILOP_DATA_BUFFER(1:(end-XBusMaster.nm),:)];
    SILOP_DATA_BUFFER=[SILOP_DATA_BUFFER ax ay az rx ry rz mx my mz]; %#ok<AGROW>
end
SILOP_DATA_BUFFER=[muestra SILOP_DATA_BUFFER];

disp(['leidos ' num2str([muestra(1) muestra(end)])])
