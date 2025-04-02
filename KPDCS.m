classdef KPDCS < ALGORITHM
% <multi> <real/integer><constrained/none> <dynamic>
% Regularity model-based multiobjective estimation of distribution
% algorithm

%------------------------------- Copyright --------------------------------
% Copyright (c) 2022 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------
%%

    methods
        function main(Algorithm,Problem)
            %% Generate random population
            Population = Problem.Initialization();
            epsilon=0.1;
            MinPts=5;    
            AllPop=[];
            AllKneePoint=[];
            AllKneeIDX=[];
            AllPopulation=[];
            [hiskneepoint]= FindKnee(Population,Problem); 
            HisIDX=kmeans_cluster(hiskneepoint,Population,Problem); 
             
            AllKneePoint=[AllKneePoint;hiskneepoint];
            AllKneeIDX=[AllKneeIDX;HisIDX];          
            AllPopulation=[AllPopulation;Population];
            ALLIGD1=[];ALLIGD2=[];
            Center=[];
            for i=1:size(hiskneepoint,2)
                clu=Population(:,HisIDX==i);
                if size(clu,2)==0
                    Center=[Center;hiskneepoint(i).dec];
                else
                    Center=[Center;mean(clu.decs,1)];
                end
            end
            %%
            M=0;t=0;
            x=zeros(1,Problem.D);
            y=ones(1,Problem.D);
            rep=Problem.Evaluation(x);
            loc=Problem.Evaluation(y);
            HiskneePop=repmat(rep,6,23);
            HiskneePop(:,23)=repmat(loc,6,1);
            Centroid=mean(Population.best.decs,1);
            %% Optimization
            while Algorithm.NotTerminated(Population)
                FLAGCHANGE=0;
                if Changed(Problem,Population)
                    FLAGCHANGE=1;
                    t=t+1;
                    M=M+1;
                    AllPop=[AllPop,Population]; 
                    [KneePop]= FindKnee(Population,Problem);
                    IDX=kmeans_cluster(KneePop,Population,Problem);
                    AllKneePoint=[AllKneePoint;KneePop];
                    AllKneeIDX=[AllKneeIDX;IDX];
                    AllPopulation=[AllPopulation;Population]; 
                    if t>=4
                        AllKneePoint=AllKneePoint(2:5,:);
                        AllKneeIDX=AllKneeIDX(2:5,:);
                        AllPopulation=AllPopulation(2:5,:);
                    end 
                    disp("第"+M+"代第"+t+"代");
                    [Popnon_dom,Nnondom,Center]=Cluster_Predict(IDX,Problem,Population,KneePop,Center,M);
                   
                    if t>=4
                        if Nnondom<Problem.N
                            Ndom=Problem.N-Nnondom;
                            PredictDom=Neural_Net(AllKneeIDX,AllPopulation,Problem,Population,KneePop,t,Ndom);
                            Population=[Popnon_dom,PredictDom];
                        else
                            Population=Popnon_dom;
                        end
                    else
                        if Nnondom>=Problem.N
                            type=1;
                            [~,IDX_DB,~]=Patition(Popnon_dom,epsilon,MinPts); 
                            if size(AllKneePoint,1)>=2
                                classifier=translearning(AllKneePoint,AllKneeIDX,AllPopulation,Population);
                                [Popnon_dom,~]=offspring_classifier(Popnon_dom,IDX_DB,Nnondom,Problem,type,Population,KneePop,t,classifier);
                            else
                                [Popnon_dom,~]=offsping_generate(Popnon_dom,IDX_DB,Nnondom,Problem,type,Population,KneePop,t);
                            end
                            Population=Popnon_dom;
                        else
                            type=2;
                            [~,IDX_DB,~]=Patition(Popnon_dom,epsilon,MinPts); 
                            if size(AllKneePoint,1)>=2
                                classifier=translearning(AllKneePoint,AllKneeIDX,AllPopulation,Population,Popnon_dom);
                                [~,offspring_n]=offspring_classifier(Popnon_dom,IDX_DB,Nnondom,Problem,type,Population,KneePop,t,classifier);
                            else
                                [~,offspring_n]=offsping_generate(Popnon_dom,IDX_DB,Nnondom,Problem,type,Population,KneePop,t);
                            end
                            Population=[Popnon_dom,offspring_n];
                        end
                    end
                end
                Offspring  = Operator(Problem,Population);
                Population = EnvironmentalSelection([Population,Offspring],Problem.N);
                if  t<=4
                    Population=theidea1(Problem,Population);
                    Population = EnvironmentalSelection(Population,Problem.N);
                end
                if FLAGCHANGE==1
                    IGD1=Problem.CalMetric('IGD',Population);
                end
                if Problem.FE >= Problem.maxFE
                    Population = [AllPop,Population];
                    [~,rank]   = sort(Population.adds(zeros(length(Population),1)));
                    Population = Population(rank);
                end
            end
        end
    end
end