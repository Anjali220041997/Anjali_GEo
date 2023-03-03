filename='E:\AMRITA  GEO ASSN\GIS ALKA MAAM\GEODETIC ASSNG\ASSIGNMENT 6 GRACE\GRCTellus.JPL.200204_202207.GLO.RL06M.MSCNv02CRI.nc';
ncdisp(filename);

% water thickness from grace
waterthickness=ncread(filename,'lwe_thickness');
Grace=waterthickness( :, : ,01 );
basin = geotiffread("E:\AMRITA  GEO ASSN\GIS ALKA MAAM\GIS ASSNG\ASSIGNMENT 5 ARCGIS MATLAB\WMOBBBasins_PolygonToRast.tif");
size(basin);
figure(1);
imagesc(basin);
title("basin");

% GRACE;
figure(2);
imagesc(Grace);
title("Grace ");

% reading date from grace
date=ncread(filename,'time');
lon=ncread(filename,'lon');
lat=ncread(filename,'lat');

% check lon of grace
lon180 = rem( (lon + 180), 360) - 180;

% basin nan

basinup= NaN(13,720);
basindown = NaN(68,720);
newbasin1=[basinup;basin];
newbasin2=[newbasin1;basindown];
figure(3)
imagesc(newbasin2);

% grace : for 1 month
Grace=waterthickness(:,:,01);
uphalf= Grace(1:360,:);                            % separate upper half of matrix
lowhalf = Grace(361:720,:);                        % separate lower half of matrix
newGrace = [lowhalf;uphalf];                       % concatenate  -180 to 0 (lon180) with 0 to 180 (uphalf)
figure(4);
imagesc(newGrace);
title("concatenated grace");
% flip grace 
newGraceflip=rot90(newGrace);
figure(5);
imagesc(newGraceflip);
title("grace flipped");

% we have 0 to 360, now cut 0 to 180(x2 because of 0.5 grid) and concatenate it below so result will bw -180 to 180 so lon from -180 to 180 is = newGrace1

% grace : for all months
Grace1=waterthickness(:,:,:);
uphalf1= Grace1(1:360,:,:);                            % separate upper half of matrix
lowhalf1 = Grace1(361:720,:,:);                        % separate lower half of matrix
newGrace1 = [lowhalf1;uphalf1];                       % concatenate  -180 to 0 (lon180) with 0 to 180 (uphalf)

% flipping grace to match basin

newGrace1flip=rot90(newGrace1);


%% filling nan in missing months in grace

datetime.setDefaultFormats('defaultdate','yyyy-MM-dd');
start = datetime(2002,04,16);
close = datetime(2022,07,16);
date = start:calmonths(1):close;
Date = date';
MonthMissing = ["2002-06-16";"2002-07-16";"2003-06-16";"2011-01-16";"2011-06-16";"2012-05-16";"2012-10-16";"2013-03-16";"2013-08-16";"2013-09-16";"2014-02-16";"2014-07-16";"2014-12-16";"2015-06-16";"2015-10-16";"2015-11-16";"2016-04-16";"2016-09-16";"2016-10-16";"2017-02-16";"2017-07-16";"2017-08-16";"2017-09-16";"2017-10-16";"2017-11-16";"2017-12-16";"2018-01-16";"2018-02-16";"2018-03-16";"2018-04-16";"2018-05-16";"2018-08-16";"2018-09-16"];
MM=datetime(MonthMissing);
M = size(MM);
D = size(Date);

% loop : nan in place of missing months

emptymatrix = NaN(360,720);

count = 0;
j = 1;
for i = 1:244
    Gracefin(:,:,i) = newGrace1flip(:,:,j);
    if( (Date(i) == MM(count+1)) && (count<=32) )  
        Gracefin(:,:,i) = emptymatrix;
        if count >= 32
            count = count^1;
        else
            count = count + 1; 
        end
        j = j - 1;
    end
    j = j + 1;
end


% plot : take 1 pixel
pixeltaken=Gracefin(111,123,:);
figure(6);
plot(Date,squeeze(pixeltaken),"-r","LineWidth",3);
title('GRACE Water Elevation Data ');
xlabel('TIME IN YEARS');
ylabel('WATER ELEVATION IN CM');
grid on;

%interpolate for pixeltaken
V=Gracefin(111,123,:);
Z=fillmissing(V,"previous");
figure(7)
plot(Date,squeeze(Z),"-g","LineWidth",3)
title('GRACE Interpolated Water Elevation Data ');
xlabel('TIME IN YEARS');
ylabel('WATER ELEVATION IN CM');
grid on;
% interpolate for all pixels

for i =1:360
    for j=1:720
        Zall(i,j,:)=fillmissing(Gracefin(i,j,:),"previous");
        
    end
end


% slope for one : pixeltaken


N=datenum(Date);
p=polyfit(N,Z,1)
figure(8)
plot(p)

% slope for all pixels
pall=zeros(360,720);

for i = 1 : 360
    for j = 1 : 720
        X = polyfit (N, Zall(i,j,:),1);
        pall(i,j)=X(:,1);
     end
 end
 
 % image of slopes : global

figure(9)
imagesc(pall)
colormap turbo              % colormap theme
colorbar


% smaller colorbar range

lims=clim                  % to view colorbar limit:  -114360 to 233950
clim([0  1000])            % to set new colorbar limit:  0    to  1000

%%% SMAP