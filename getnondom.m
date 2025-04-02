function no_dom=getnondom(no_dominate,clu)
    no_dom=[];
    N=size(no_dominate,2);
    M=size(clu,2);
    for i=1:M
        for j=1:N
            if clu(i)==no_dominate(j)
                no_dom=[no_dom,no_dominate(j)];
                break;
            end
        end
    end
end