function dom=get_dom(Population,no_dominate)
    no_dominate_test=no_dominate;
    no_dom_index=zeros(1,size(Population,2));
    for i=1:size(Population,2)
        for j=1:size(no_dominate_test,2)
            if Population(:,i)==no_dominate_test(:,j)
                no_dom_index(:,i)=1;
            end
        end
    end
    dom=Population(1,~no_dom_index);
end