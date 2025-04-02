function PredictDom=Neural_Net(AllKneeIDX,AllPopulation,Problem,Population,KneePop,cur_t,Ndom)
    clusternum=size(KneePop,2);% 聚类个数
    nodomPop=Population.best;
    disp("在net中非支配数量："+size(nodomPop,2));
    Z = min(Population.objs,[],1);
    AllPopdist=zeros(size(AllPopulation)); 
    if Problem.M==2
        W=[Z(1)/sum(Z),Z(2)/sum(Z)];
    elseif Problem.M==3
         W=[Z(1)/sum(Z),Z(2)/sum(Z),Z(3)/sum(Z)];
    end
    normW   = sqrt(sum(W(1,:).^2,2));
    %%  计算所有个体的PBI距离
    for t=cur_t-3:cur_t
        tempPop=AllPopulation(t-(cur_t-4),:);
        for i=1:size(tempPop,2)
            normP   = sqrt(sum((tempPop(i).obj-repmat(Z,1,1)).^2,2));
            CosineP = sum((tempPop(i).obj-repmat(Z,1,1)).*W(1,:),2)./normW./normP;
            Popdist=normP.*CosineP + 5*normP.*sqrt(1-CosineP.^2);
            AllPopdist(t-(cur_t-4),i)=Popdist;
        end
    end
    %%  相邻环境t之间配对 计算角度和步长
    step=zeros(size(AllPopulation,1)-1,size(AllPopulation,2));
    Poporder=[1:1:Problem.N;1:1:Problem.N;1:1:Problem.N];
    PairOrder=zeros(cur_t-1,Problem.N);
    for t=cur_t-3:cur_t-1
        curPop=AllPopulation(t-(cur_t-4),:);
        curIDX=AllKneeIDX(t-(cur_t-4),:); 
        nextPop=AllPopulation(t+1-(cur_t-4),:);
        nextIDX=AllKneeIDX(t+1-(cur_t-4),:);
        clustep=[]; 
        cluangle=[];
        temporder=[]; 
        for k=1:clusternum
            cluorder=Poporder(t-(cur_t-4),curIDX==k);
            clu=curPop(1,curIDX==k); 
            nextclu=nextPop(1,nextIDX==k); 
            clupbidist=AllPopdist(t-(cur_t-4),curIDX==k); 
            if numel(nextclu)==0
                 nextclu=nextPop(1,nextIDX==k-1);
                 nextpbidist=AllPopdist(t+1-(cur_t-4),nextIDX==k-1); 
                 if numel(nextclu)==0
                     nextclu=nextPop(1,nextIDX==k+1);
                     nextpbidist=AllPopdist(t+1-(cur_t-4),nextIDX==k+1);
                 end
            else
                 nextpbidist=AllPopdist(t+1-(cur_t-4),nextIDX==k);
            end
            if size(clu,2)~=0
                for i=1:size(clu,2) 
                    cursolution=clu(i);
                    PBIdist=clupbidist(i);
                    C=abs(PBIdist-nextpbidist); 
                    C_min=min(C);
                    [~, col]=find(C==C_min); 
                    pairsolution=nextclu(1,col); 
                    [~,curcol]=find(AllPopulation(t-(cur_t-4),:)==cursolution);
                    if size(pairsolution,2)==0
                        randnum=randperm(100);
                        pairsolution=AllPopulation(t+1-(cur_t-4),randnum(1));
                    end
                    [~,paircol]=find(AllPopulation(t+1-(cur_t-4),:)==pairsolution(1)); 
                    PairOrder(t-(cur_t-4),curcol)=paircol(1); 
                    %%  计算角度和步长
                    vector=pairsolution(1).dec-cursolution.dec;
                    curangle=zeros(1,Problem.D-1);
                    curstep=norm(vector);
                    for j=1:Problem.D-1
                        curangle(1,j)=atan2(norm(vector(1,j+1:end)),vector(j)); 
                    end
                    clustep=[clustep,curstep];
                    cluangle=[cluangle;curangle];
                    temporder=[temporder,cluorder(i)];
                end
            end
           
        end 
        Poporder(t-(cur_t-4),:)=temporder; 
        step(t-(cur_t-4),:)=clustep; 
        angle(:,:,t-(cur_t-4))=cluangle; 
    end
    [~,PopRank]=sort(Poporder,2);
    %%  构造训练集
    for i=1:3
        step(i,:)=step(i,PopRank(i,:));
    end
    XtrainData=[step(1,:);step(2,PairOrder(1,:))];
    YtrainData=[step(3,PairOrder(2,PairOrder(1,:)))];
   
    [Xtrain,PS_Xtrain]=mapminmax(XtrainData,-1,1);
    [Ytrain,PS_Ytrain]=mapminmax(YtrainData,-1,1);
    %%  构造神经网络 预测步长
    hiddenum1=10;
    hiddenum2=4;
    outputnum=1;
       netstep=newff(Xtrain,Ytrain,[hiddenum1],{'tansig','purelin'},'traingdm');
    netstep.trainParam.showWindow = false;
    netstep.trainParam.showCommandLine = false; 
    netstep.trainParam.epochs=100;
    netstep.trainParam.lr=0.01;
    netstep.trainParam.goal=0.0001; 
    netstep=train(netstep,Xtrain,Ytrain);
    predictXstep=[step(2,:);step(3,PairOrder(2,:))];
    predictXData=mapminmax('apply',predictXstep,PS_Xtrain);
    predictYData=sim(netstep,predictXData);
    predictYstep=mapminmax('reverse',predictYData,PS_Ytrain); % 反归一化 1*100
    predictYstep=predictYstep';

    for j=1:3
        angle(:,:,j)=angle(PopRank(j,:)',:,j);
    end
    predictYangle=zeros(Problem.N,Problem.D-1);
    parfor i=1:Problem.D-1
        XtrainData=[angle(:,i,1)';angle(PairOrder(1,:)',i,2)'];
        YtrainData=angle(PairOrder(2,PairOrder(1,:)),i,3)';
        [Xtrain,PS_Xtrain]=mapminmax(XtrainData,-1,1);
        [Ytrain,PS_Ytrain]=mapminmax(YtrainData,-1,1);
        hiddenum1=10;
        hiddenum2=4;
        outputnum=1;
        netangle=newff(Xtrain,Ytrain,[hiddenum1],{'tansig','purelin'},'traingdm');
    
        netangle.trainParam.showWindow = false;
        netangle.trainParam.showCommandLine = false; 
        netangle.trainParam.epochs=100; 
        netangle.trainParam.lr=0.01;
        netangle.trainParam.goal=0.0001; 
        netangle=train(netangle,Xtrain,Ytrain);
        predictXangle=[angle(:,i,2)';angle(PairOrder(2,:)',i,3)'];
        predictXData=mapminmax('apply',predictXangle,PS_Xtrain); 
        predictYData=sim(netangle,predictXData);
        predictYangleone=mapminmax('reverse',predictYData,PS_Ytrain); 
        predictYangle(:,i)=predictYangleone';
    end
    %%  通过以上步骤得到第t时刻每个个体的步长predictYstep和角度predictYangle;  接下来计算第t+1时刻的每个个体
    
    PredictVectordecs=zeros(Problem.N,Problem.D); 
    for i=1:Problem.D
        if i==1
            PredictVectordecs(:,i)=predictYstep.*cos(predictYangle(:,i));
        elseif i>1&&i<Problem.D
            tempsinangle=1;
            for j=1:i-1
                tempsinangle=tempsinangle.*sin(predictYangle(:,j));
            end
            PredictVectordecs(:,i)=predictYstep.*tempsinangle.*cos(predictYangle(:,i));
        elseif i==Problem.D
            tempsinangle=1;
            for j=1:i-1
                tempsinangle=tempsinangle.*sin(predictYangle(:,j));
            end
            PredictVectordecs(:,i)=predictYstep.*tempsinangle;
        end
    end
    curPopdec=Population.decs;
    PredictYdecs=curPopdec+PredictVectordecs;
    %%  接下来求非支配个体，获得哪些个体应该进行预测
    disp("在net中非支配数量："+size(nodomPop,2));
    domPop=get_dom(Population,nodomPop);
    Ndom=size(domPop,2);
    disp("在net中支配数量："+Ndom);
    domPostion=ones(size(Population));
    for i=1:Problem.N
        for j=1:size(nodomPop,2)
            if Population(i)==nodomPop(j)
                domPostion(i)=0;
            end
        end
    end
    PredictDom=[];
    Popobj=Population.objs;
    for i=1:Problem.N
        if domPostion(1,i)==1
            presolutionobj=Problem.CalObj(PredictYdecs(i,:));
            k=any(presolutionobj<Popobj(i,:)) - any(presolutionobj>Popobj(i,:));
            if k==1 
                presolution=Problem.Evaluation(PredictYdecs(i,:));
                PredictDom=[PredictDom,presolution];
            elseif k==-1 
                PredictDom=[PredictDom,Population(i)];
            elseif k==0
                if rand>0.5
                    presolution=Problem.Evaluation(PredictYdecs(i,:));
                    PredictDom=[PredictDom,presolution];
                else
                    PredictDom=[PredictDom,Population(i)];
                end
            end
        end
    end
    PredictDom=EnvironmentalSelection(unique(PredictDom),Ndom);
    
end