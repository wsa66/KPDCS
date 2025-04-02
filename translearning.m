function classifier=translearning(AllKneePoint,AllKneeIDX,AllPopulation,Population,Popnon_dom)
% function classifier=translearning(AllKneePoint,AllKneeIDX,AllPopulation,Population)
    k=size(AllKneePoint,2);
    X=size(AllKneePoint,1);
    IDXknee=false(size(AllKneePoint));
    [FrontNo,~] = NDSort(AllKneePoint.objs,AllKneePoint.cons,numel(AllKneePoint));
    Next=FrontNo==1;
    for i=1:size(FrontNo,2)
        if FrontNo(1,i)==1
            IDXknee(floor((i-1)/6)+1,mod(i-1,6)+1)=true;
        end
    end
    Xtrain=AllPopulation(X,:).best.decs;
    Ytrain=true(size(AllPopulation(X,:).best.decs,1),1);
    for i=1:X-1
        for j=1:k
            clu=AllPopulation(i,AllKneeIDX(i,:)==j);
            no_dom=getnondom(AllPopulation(i,:).best,clu);
            dom=get_dom(clu,no_dom);
            if numel(no_dom)==0
                no_dom=[AllKneePoint(i,j),clu.best];
            end
            Xtrain=[Xtrain;no_dom.decs];
            Ytrain=[Ytrain;false(size(no_dom.decs,1),1)];
        end
    end
    classifier=fitckernel(Xtrain,Ytrain);
end