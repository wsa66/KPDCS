function [KneePop,KneeIndex]=FindKnee(Population,Problem)
if Problem.M==3
    %% Find the knee points
    num=10;
    KneeIndex=false(1,Problem.N);
    no_dominate=Population.best; 
    KneePoints = false(1,length(no_dominate));
    Distance   = zeros(1,length(no_dominate));
    Popobj=no_dominate.objs;
    [~,maxindex1]=max(Popobj(:,1),[],1);
    [~,maxindex2]=max(Popobj(:,2),[],1);
    [~,maxindex3]=max(Popobj(:,3),[],1);
    P1=Popobj(maxindex1,:);
    P2=Popobj(maxindex2,:);
    P3=Popobj(maxindex3,:);
    x1=P1(1);y1=P1(2);z1=P1(3);
    x2=P2(1);y2=P2(2);z2=P2(3);
    x3=P3(1);y3=P3(2);z3=P3(3);
    A = (y2 - y1)*(z3 - z1) - (z2 -z1)*(y3 - y1);
    B = (x3 - x1)*(z2 - z1) - (x2 - x1)*(z3 - z1);
    C = (x2 - x1)*(y3 - y1) - (x3 - x1)*(y2 - y1);
    V=[A,B,C];
    D = -(A * x1 + B * y1 + C * z1);
    F1_min=min(Popobj(:,1));%第一个目标的最小值
    F1_max=max(Popobj(:,1));%第一个目标的最大值
    interval=(F1_max-F1_min)/num;
    for k=1:size(no_dominate,2)
        K=Popobj(k,:);
        Distance(1,k)=abs(dot(K,V)-D)/norm(V);  %保存每个点到平面的距离
    end
    [sortPop,Rank]=sortrows(Popobj,1);
    maxdistemp=zeros(1,num);
    maxdisindex=zeros(1,num);

    for k=1:size(no_dominate,2)
        for i=1:num
            if sortPop(k,1)>=F1_min+(i-1)*interval&&sortPop(k,1)<F1_min+i*interval
                if Distance(1,Rank(k))>=maxdistemp(i)
                    maxdistemp(i)=Distance(1,Rank(k));
                    maxdisindex(i)=Rank(k);
                end
            end
        end
    end
    for x=1:size(maxdisindex,2)
        if maxdisindex(1,x)~=0
            KneePoints(1,maxdisindex(1,x))=true;
        end
    end
    KneePop=no_dominate(KneePoints); 
    for j=1:num
        if maxdistemp(1,j)==0&&maxdisindex(1,j)==0 
            up=max(no_dominate.decs,[],1);
            low=min(no_dominate.decs,[],1);
            divdec=low+(up-low).*rand();
            temp=Problem.Evaluation(divdec);
            KneePop=[KneePop,temp];
        end
    end
else
    %% Find the knee points
    num=10;
    KneeIndex=false(1,Problem.N);
    no_dominate=Population.best; 
    KneePoints = false(1,length(no_dominate));
    Distance   = zeros(1,length(no_dominate));
    Popobj=no_dominate.objs;
    [~,maxindex]=max(Popobj(:,1),[],1);
    [~,minindex]=min(Popobj(:,1),[],1);
    Pmax=Popobj(maxindex,:);
    Pmin=Popobj(minindex,:);
    F1_min=min(Popobj(:,1));%第一个目标的最小值
    F1_max=max(Popobj(:,1));%第一个目标的最大值
    interval=(F1_max-F1_min)/num;
    for k=1:size(no_dominate,2)
        K=Popobj(k,:);
        Distance(1,k)=abs(det([Pmax-Pmin;K-Pmin]))/norm(Pmax-Pmin);
    end
    [sortPop,Rank]=sortrows(Popobj,1);
    maxdistemp=zeros(1,num);
    maxdisindex=zeros(1,num);

    for k=1:size(no_dominate,2)
        for i=1:num
            if sortPop(k,1)>=F1_min+(i-1)*interval&&sortPop(k,1)<F1_min+i*interval
                if Distance(1,Rank(k))>=maxdistemp(i)
                    maxdistemp(i)=Distance(1,Rank(k));
                    maxdisindex(i)=Rank(k);
                end
            end
        end
    end
    for x=1:size(maxdisindex,2)
        if maxdisindex(1,x)~=0
            KneePoints(1,maxdisindex(1,x))=true;
        end
    end
    KneePop=no_dominate(KneePoints); 
    for j=1:num
        if maxdistemp(1,j)==0&&maxdisindex(1,j)==0 
            up=max(no_dominate.decs,[],1);
            low=min(no_dominate.decs,[],1);
            divdec=low+(up-low).*rand();
            temp=Problem.Evaluation(divdec);
            KneePop=[KneePop,temp];
        end
    end
end %if
end %function