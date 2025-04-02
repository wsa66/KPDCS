function [Popnon_dom,offspring_n]=offsping_generate(Popnon_dom,IDX_DB,Nnondom,Problem,type,Population,KneePop,t)
    offspring_n=[];
    Noise=Popnon_dom(:,IDX_DB==0);
    Parent=[Noise,KneePop];
    no_dominate=Population.best;
    if type==1
        Next=false(1,size(Popnon_dom,2));
        CrowdDis=CrowdingDistance(Popnon_dom.objs);
        [~,Rank]=sort(CrowdDis,'descend');
        Next(Rank(1:Nnondom))=true;
        Popnon_dom=Popnon_dom(Next);
    elseif type==2
        offspring_n=Parent;
        while numel(offspring_n)<=Problem.N-Nnondom
            MatingPool = Parent(randperm(numel(Parent),2)); 
            offspring=OperatorGAhalf(Problem,MatingPool);
            judge_nondom=judgedominate(offspring,Parent);
            if judge_nondom==true 
                offspring_n=[offspring_n,offspring];
            else
                continue;
            end
        end

    end
end
