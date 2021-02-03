%   Clustering über die beiden Dimensionen der Daten unter verwendung der
%   R-Funktion hcluster aus dem Paket amap
% 
% clusterR(E,file,normieren,meth,SampleNames,doplot,linkageArrays, linkGenes, clusterdims)
% 
%       file         Beginn der Dateinamen 
%       normieren   0: normale Daten (Default) 
%                   1: Jedes Gen erhält Mittelwert 0 und Standardabweichung 1 
%                   2: Jedes Gen erhält Mittelwert 0 
%       meth        the distance measure to be used. This must be one of
%           'euclidean', 'maximum', 'manhattan', 'canberra'
%           'binary' 'pearson', 'correlation' or  'spearman'. Any
%           unambiguous substring can be given.
% 
%       SampleNames  Annotation fuer die Arrays, die in der Heatmap mit
%                       geplottet wird
%                       Die Farbe wird äquidistant gewaehlt, die Reihenfolge
%                       nach der Sortierung gewaehlt.
%       doplot      1: Default
%                   0: keine Abbildungen
%                   2: Paper, keine Strings am Dendrogramm, mit colorbar
% 
%       linkageArrays "ward", "single", "complete", "average" (DEFAULT), "mcquitty",
%                       "median" or "centroid","centroid2"
% 
%       clusterdims     Default [1,2]  = both (genes & samples)
%                   1 = genes will be clustered
%                   2 = samples will be clustered
%         
%   global onlyHeatmap  Default: 0
% 
function erg = clusterR(O,nk,clusterdims,normieren,meth,linkageArrays,linkGenes,file,doplot)

if(~exist('doplot','var') || isempty(doplot))
    doplot = 1;
end
if(~exist('file','var') || isempty(file))
    file = 'Cluster';
end
if(~exist('normieren','var') || isempty(normieren))
    normieren = 0;
end
if(~exist('linkageArrays','var') || isempty(linkageArrays))
    linkageArrays = 'average';
end
if(~exist('linkGenes','var') || isempty(linkGenes))
    linkGenes = 'average';
end
if(~exist('meth','var') || isempty(meth))
    meth = 'correlation';
else
    if(strcmp(meth,'cor')==1)
        meth = 'correlation';
    end
end
if(~exist('clusterdims','var') || isempty(clusterdims))
    clusterdims = 1:2;
end
if(~exist('nk','var') || isempty(nk))
    nk=size(O,2)/2;
end

erg = [];
pw = strrep([pwd,filesep],filesep,'/');
SampleNames = get(O,'SampleNames');

% Normalize
sd = std(O,'omitnan');
if(sum(sd==0)>0)
    warning(['Cluster.m: ',num2str(sum(sd==0)),' features with SD==0 in data.'])
end
dat = get(O,'data');
if(normieren == 1)
    dat = Normiere(dat);
elseif(normieren == 2)
    dat = Normiere(dat,1);
elseif normieren==3 % Skaliere global alles zwischen -1 und 1
    dat = dat-nanmin(dat(:));
    dat = dat./range(dat(:)) *2 -1;
end

clusterGenesOK=0;
if(size(O,1)>2)
	Rinit;
	%% Push data
	Rpush('SavePath',pw);
	Rpush('DataPath',pw);
    Name = get(O,'name');
    if(isempty(Name))
        Name = get(O,'filename');        
    end
	Rpush('Name',Name);
    gn = get(O,'ProteinIDs');
    if(isempty(gn))
        gn = get(O,'IDs');        
    end
    Rpush('IDs',gn);
    Rpush('SampleNames',SampleNames);
	Rpush('data',dat);
		
    %% R commands
	Rrun('setwd(SavePath)');
    Rrun('require(amap)')

    Rrun('datum     <- format(Sys.time(), "%b%d-%Y")');
	% Rrun('memory.limit(size=10000)')
% 	try
        Rrun('IDs <- t(IDs)')
       % Rrun('	anzbreaks <- 100	')        
        Rrun('	potenz <- 1/3	')
    	Rrun('minChipData <- min(data,na.rm=TRUE)')
    	Rrun('maxChipData <- max(data,na.rm=TRUE)')
    	Rrun('plotGrenze <- ceiling(max(  c(abs(minChipData),abs(maxChipData))  )) ')
		%Rrun('breaks <- seq(-plotGrenze,plotGrenze,len=2*anzbreaks+2) ')
       % R_colors(colortype)        
%     	Rrun('ps.options(append=T)')
		Rrun('xlim <- c(-0.12*length(data[,1]),length(data[,1])+1) ')
		Rrun('ylim <- c(-0.12*length(data[1,]),length(data[1,])+1) ')

       	if(size(O,2)>30)
		    Rrun('Hoehe <- 10') %Hoehe der graph. Ausgabe in inches
    	else
		    Rrun('Hoehe <- 5');
        end

        if(sum(clusterdims==2)>0)
            Rrun(['h <- hcluster(t(data), method = "',meth,'", link = "',linkageArrays,'")']);
            clusterSamplesOK = 1;
        else
            Rrun('h<-list(order=1:dim(data)[2])')
            clusterSamplesOK = 0;
        end
%         Rrun(' memory.limit(size=4000)')
               
        if(sum(clusterdims==1)>0)
            Rrun(['hgene <- hcluster(data, method = "',meth,'", link = "',linkGenes,'")']);
            clusterGenesOK = 1;
        else
            Rrun('hgene<-list(order=1:dim(data)[1])')
        end

        if(doplot~=0)
                if(clusterSamplesOK==1)
                    Rrun(['postscript("',file,'_Dendrogram_Arrays.ps", horizontal=TRUE, onefile=TRUE,height=Hoehe, width=10,pointsize=5)'])
                    if(doplot==2)
                        Rrun('plot(h,labels=F,main="", xlab="", ylab="", sub="")')
                    else
                        Rrun('plot(h,main="", xlab="", ylab="", sub="")')
                    end
                    Rrun('dev.off()')
                end

                if(doplot==2) % Farbskala
                    Rrun('anzSteps <- 100')
                    Rrun(['postscript("',file,'_Farbskala.ps", horizontal=TRUE, onefile=TRUE,height=10, width=2)'])
                    Rrun('par(lab=c(1,5,1))')
                    if(normieren==1)
                        ylab = '[ 1/SD ]';
                    else
                        ylab = 'expression [log2]';
                    end
                    Rrun(['image(1,seq(-3,3,len=anzSteps),t(matrix(seq(-3,3,len=anzSteps))),xlab="",ylab="',ylab,'",add=FALSE,xaxt="n")'])
                    %                 Rrun('image(1,c(1:anzSteps)/10-5,t(farben),xlab="",ylab="",add=FALSE)')
                    Rrun('dev.off()')

                    Rrun(['postscript("',file,'_Farbskala2.ps", horizontal=TRUE, onefile=TRUE,height=10, width=2)'])
                    Rrun('par(lab=c(1,5,1))')
                    if(normieren==1)
                        ylab = '[ 1/SD ]';
                    else
                        ylab = 'expression [log2]';
                    end
                    Rrun(['image(1,seq(-plotGrenze,plotGrenze,len=anzSteps),t(matrix(seq(-plotGrenze,plotGrenze,len=anzSteps))),xlab="",ylab="',ylab,'",add=FALSE,xaxt="n")'])
                    Rrun('dev.off()')
                end

            Rrun(['postscript("',file,'_Heatmap.ps", horizontal=TRUE, onefile=TRUE,height=Hoehe, width=10,pointsize=5)'])
            Rrun('image(1:length(data[,1]),1:length(data[1,]),data[hgene$order,h$order],ylab="",xlab="",xlim=xlim,ylim=ylim) ')
            Rrun('for(i in 1:length(Name)){text(-0.1*length(data[,1]),i,  Name[h$order[i]],adj=0)}')
            Rrun('for(i in 1:length(IDs)) {text(i,-0.1*length(data[1,]),  IDs[hgene$order[i]], srt=90,adj=0,cex=0.15)}')
            Rrun(' dev.off() ')
%             Rrun('ps.options(append=F)')
        end
        
        %% Cut
        if exist('nk','var') && ~isempty('nk')
            if(clusterGenesOK==1)
                Rrun(['cut',num2str(nk),' <- cutree(hgene,k=',num2str(nk),')'])
            else
                Rrun(['cut',num2str(nk),' <- cutree(h,k=',num2str(nk),')'])
            end
        end
        
        %% Pull        
        Rrun('orderGene <- hgene$order')
        Rrun('orderChips <- h$order')

        erg.order = double(Rpull('orderGene'));
        erg.orderChips  = double(Rpull('orderChips'));
        erg.IDs         = get(O,'ProteinIDs');
        erg.name        = get(O,'name');
        erg.data        = get(O,'data'); 
        erg.ChipAnnotation = SampleNames;
        
        if exist('nk','var') && ~isempty('nk')
            if(clusterGenesOK==1)
                erg.genecluster = double(Rpull(['cut' num2str(nk)]));
            end
            if(clusterSamplesOK==1)
                erg.samplecluster = double(Rpull(['cut' num2str(nk)]));
            end
        end

	Rclear;

    if doplot>0
        try
            if ~system(['ps2pdf ',file,'_Heatmap.ps']);
                system(['rm ',file,'_Heatmap.ps']);
            end
            if onlyHeatmap~=1
                if ~system(['ps2pdf ',file,'_Dendrogram_Arrays.ps']);
                    system(['rm ',file,'_Dendrogram_Arrays.ps']);
                end
            end
        end
    end
    
    
    if(doplot==1 && clusterGenesOK==1 && onlyHeatmap~=1)
        try
            WriteWithColnames(OmicsFilterColsSTY(O),[file,'.txt'],get(O,'data'),get(O,'SampleNames'))
        catch
            disp(lasterr)
        end
    end
    
else  %% genuegend Gene
    erg = [];
    warning('clusterR.m: Less than 3 features.')
end


