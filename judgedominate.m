function judge_nondom=judgedominate(offspring,Parent)
    N=numel(Parent);
    offspringobj=offspring.obj; %1*2
    judge_nondom=true;
    Parentobj=Parent.objs;%N*2
    for i=1:N
        k=any(Parentobj(i,:)<offspringobj)-any(Parentobj(i,:)>offspringobj);
        if k==1
            judge_nondom=false;
        end
    end
end