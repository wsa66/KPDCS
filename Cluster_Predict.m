function[Popnon_dom,Nnondom,Center1]=Cluster_Predict(IDX,Problem,Population,KneePop,Center,M)
    k=size(KneePop,2);
    no_dominate=Population.best;
    Nnondom=size(no_dominate,2);
    disp("Nnondom: "+Nnondom);
    Cluster=[];
    Center1=[];
    for i=1:k
        step=1; %规定步长
        clu=Population(:,IDX==i);
        no_dom=getnondom(no_dominate,clu); 
        if numel(no_dom)==0
            no_dom=[KneePop(:,i),clu.best];
            disp("第"+i+"簇没有非支配解集");
        end
        Centroid =Center(i,:);
        if M<=3
            Centroid1=mean(no_dominate.decs,1);
        else
            Centroid1=mean(no_dom.decs,1);
        end
        %对非支配解集进行预测
        nodom_predict_1=repmat(0.5*(Centroid1-Centroid),size(no_dom,2),1)+no_dom.decs;
        nodom_predict_2=repmat(1*(Centroid1-Centroid),size(no_dom,2),1)+no_dom.decs;
        nodom_predict_3=repmat(1.5*(Centroid1-Centroid),size(no_dom,2),1)+no_dom.decs;
        n1=Problem.Evaluation(nodom_predict_1);
        n2=Problem.Evaluation(nodom_predict_2);
        n3=Problem.Evaluation(nodom_predict_3);
        n_all=[n1,n2,n3];
        no_dom=EnvironmentalSelection(n_all,size(no_dom,2));
        clu=no_dom;
        Cluster=[Cluster,clu]; %保存到总簇中
        Center1=[Center1;Centroid1];
    end
    Popnon_dom=Cluster;
    Popnon_dom=EnvironmentalSelection(Popnon_dom,Nnondom);
end
