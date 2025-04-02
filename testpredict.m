function [no_dominate,Centroid,Nnodom]=testpredict(Problem,Population,Centroid)
    no_dominate=Population.best;
    Centroid1=mean(no_dominate.decs,1);
    Gaussian=norm(Centroid1-Centroid)/2/sqrt(size(no_dominate.decs,2)).*randn(size(no_dominate.decs));
    X=repmat(Centroid1-Centroid,size(no_dominate,2),1)+no_dominate.decs+Gaussian;
    up=max(no_dominate.decs,[],1);
    low=min(no_dominate.decs,[],1);
    if X<low
        X=low;
    elseif X>up
        X=up;
    end
    no_dominate=Problem.Evaluation(X);
    Centroid=Centroid1;
    Nnodom=size(no_dominate,2);
end