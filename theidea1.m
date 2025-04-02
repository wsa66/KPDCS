function Population = theidea1(Problem,Population)
    KneePop= FindKnee(Population,Problem);
   
    Popnodom=Population.best;
    Nnodom=size(Popnodom,2);
    
    Popdom=get_dom(Population,Popnodom); 
    [~,IDX_DB,~]=Patition(Popnodom,0.1,5);  
    Noise=Popnodom(:,IDX_DB==0);

    Parent=[Noise,KneePop];
    Nodom=[];
    NDSobj=Popnodom.objs;   %[Nnodom,2]
    Noffspring=0;
    while Noffspring<=Nnodom
        MatingPool = Parent(randperm(numel(Parent),2)); 
        offspring=OperatorGAhalf(Problem,MatingPool);
        offspringobj=offspring.obj;
        Noffspring=Noffspring+1;
        %%  如果子代是能支配任意一个NDS，则代替他成为新的NDS
        ifNDS=false;
        i=1:Nnodom;
            k = any(offspringobj<NDSobj(i,:)) - any(offspringobj>NDSobj(i,:));
            if k==1 
                ifNDS=true;
            elseif k==-1 
                ifNDS=false;
            elseif k==0 
                ifNDS=true;
                Nodom=[Nodom,Popnodom(1,i)];
            end
        
        if ~ifNDS
            Popdom=[Popdom,offspring];
        else
            Nodom =[Nodom,offspring];
        end
    end
    Popnodom=unique(Nodom);
    Nnodom=size(Popnodom,2);
    Ndom=Problem.N-Nnodom;
    if Ndom>0
        Popdom=EnvironmentalSelection(Popdom,Ndom);
    else
        Popdom=[];
    end
    Population=[Popnodom,Popdom,KneePop];
    
end