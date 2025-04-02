function [Population,Problem]=oppositionlearing(Population,Problem)
nodom=Population.best;
nodomdecs=nodom.decs;
dom=get_dom(Population,nodom); 
domdecs=dom.decs;
%%
if size(dom,2)~=0
    cur=[];
    up=max(domdecs,[],1);
    low=min(domdecs,[],1);
    k=rand;
    op_domdecs=repmat(k*(up+low),size(domdecs,1),1)-domdecs;
    if op_domdecs>up
        op_domdecs=up;
    elseif op_domdecs<low
        op_domdecs=low;
    end
    
   op_dom=Problem.Evaluation(op_domdecs); 
    
    for i=1:size(dom,2)
        mindist_dom=inf;
        mindist_op=inf;
        for j=1:size(nodom,2)
            mindist_dom=min(mindist_dom,dist(domdecs(i,:),nodomdecs(j,:)'));
            mindist_op=min(mindist_op,dist(op_domdecs(i,:),nodomdecs(j,:)'));
        end
        if mindist_dom<mindist_op
            Population=[Population,dom(1,i)];
        else
            Population=[Population,op_dom(1,i)];
        end
        cur=[cur,dom(1,i)];
    end
    Population=[nodom,cur];
end

end