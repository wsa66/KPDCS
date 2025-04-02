function [Cluster,IDX,Centroid]=Patition(Population,epsilon,MinPts)
        Popobjs=Population.objs;    
        IDX=DBSCAN(Popobjs,epsilon,MinPts); 
        k=max(IDX);
        Cluster=[];
        Centroid=[];
        for i=0:k
            Cluster=[Cluster,Population(:,IDX==i)];
            c=mean(Population(:,IDX==i).best.decs,1);
            Centroid=[Centroid;c];
        end
end