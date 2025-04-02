%%  以6个膝点为中心对种群中所有个体进行聚类

function IDX=kmeans_cluster(KneePop,Population,Problem)
    N=Problem.N;
    IDX=zeros(size(Population));
    X=size(KneePop,2);
    Popobjs=Population.objs;
    kneeobjs=KneePop.objs;
    for i=1:size(Population,2)
        Pop_i=Popobjs(i,:);
        mindist_i=inf;
        for j=1:X
            dist_i=pdist([Pop_i;kneeobjs(j,:)]);
            if dist_i<mindist_i
                mindist_i=dist_i;
                IDX(:,i)=j;
            end
        end
    end

end