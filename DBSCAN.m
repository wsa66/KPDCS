
function [IDX, isnoise]=DBSCAN(X,epsilon,MinPts)     
    C=0;                       
    
    n=size(X,1);               
    IDX=zeros(n,1);            
    
    D=pdist2(X,X);             
    
    visited=false(n,1);       
    isnoise=false(n,1);       
    
    for i=1:n                  
        if ~visited(i)         
            visited(i)=true;   
            Neighbors=RegionQuery(i);    
            if numel(Neighbors)<MinPts 
                isnoise(i)=true;          
            else              
                C=C+1;        
                ExpandCluster(i,Neighbors,C);   
            end
        end
    end                  
    
    function ExpandCluster(i,Neighbors,C)    
        IDX(i)=C;                            
        
        k = 1;                             
        while true                          
            j = Neighbors(k);                
            
            if ~visited(j)                   
                visited(j)=true;             
                Neighbors2=RegionQuery(j);   
                if numel(Neighbors2)>=MinPts 
                    Neighbors=[Neighbors Neighbors2];   
                end
            end                              
            if IDX(j)==0                     
                IDX(j)=C;                    
            end                              
            
            k = k + 1;                       
            if k > numel(Neighbors)         
                break;
            end
        end
    end                                      
    
    function Neighbors=RegionQuery(i)        
        Neighbors=find(D(i,:)<=epsilon);
    end
 
end