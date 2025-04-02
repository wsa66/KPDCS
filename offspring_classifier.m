function [Popnon_dom,offspring_n]=offspring_classifier(Popnon_dom,IDX_DB,Nnondom,Problem,type,Population,KneePop,t,classifier)
    offspring_n=[];
    Noise=Popnon_dom(:,IDX_DB==0);
    Parent=[Noise,KneePop];
    [FrontNo,~] = NDSort(Parent.objs,Parent.cons,size(Parent,2));
    Next = FrontNo == 1;
    no_dominate=Population.best;
    if type==1
        Next=false(1,size(Popnon_dom,2));
        CrowdDis=CrowdingDistance(Popnon_dom.objs);
        [~,Rank]=sort(CrowdDis,'descend');
        Next(Rank(1:Problem.N-size(KneePop,2)))=true;
        Popnon_dom=Popnon_dom(Next);
    elseif type==2
         if size(Parent,2)<=2
            up=max(no_dominate.decs,[],1);
            low=min(no_dominate.decs,[],1);
            Noffspring=0;
            while Noffspring<Problem.N
                divdec=low+(up-low).*rand([1,Problem.D]);
                if divdec<low
                    divdec=low;
                elseif divdec>up
                    divdec=up;
                end
                if predict(classifier,divdec)==1
                    offspring=Problem.Evaluation(divdec);
                    offspring_n=[offspring_n,offspring];
                    Noffspring=Noffspring+1;
                else
                    continue;
                end
            end
         else
             disp("Problem.N:"+Problem.N+"Nnondom:"+Nnondom)
             Noffspring=0;
             errorspring=0;
             while Noffspring<=Problem.N-Nnondom
                 divdec=Problem.lower+(Problem.upper-Problem.lower).*rand(10000,Problem.D);
                 disp("Noffspring1:"+Noffspring)
                 for i=1:size(divdec,1)
                    if predict(classifier,divdec(i,:))==1
                        Noffspring=Noffspring+1;
                        if Noffspring>Problem.N-Nnondom
                            break;
                        end
                        offspring=Problem.Evaluation(divdec(i,:));
                        offspring_n=[offspring_n,offspring];
                    else
                        errorspring=errorspring+1;
                    end
                 end
             end
            
         end
    end
end

function Del = Truncation(PopObj,K)
% Select part of the solutions by truncation
    %% Truncation
    Distance = pdist2(PopObj,PopObj);
    Distance(logical(eye(length(Distance)))) = inf;
    Del = false(1,size(PopObj,1));
    while sum(Del) < K
        Remain   = find(~Del);
        Temp     = sort(Distance(Remain,Remain),2);
        [~,Rank] = sortrows(Temp);
        Del(Remain(Rank(1))) = true;
    end
end