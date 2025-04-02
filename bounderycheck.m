function [nodom_predict_1,nodom_predict_2,nodom_predict_3,nodom_predict_4,...
            nodom_predict_5,nodom_predict_6,nodom_predict_7,nodom_predict_8]=bounderycheck(up,low, ...
            nodom_predict_1,nodom_predict_2,nodom_predict_3,nodom_predict_4, ...
            nodom_predict_5,nodom_predict_6,nodom_predict_7,nodom_predict_8)

    if nodom_predict_1<low
      nodom_predict_1=low;
    elseif nodom_predict_1>up
      nodom_predict_1=up;
    end

    if nodom_predict_2<low
      nodom_predict_2=low;
    elseif nodom_predict_2>up
      nodom_predict_2=up;
    end

    if nodom_predict_3<low
        nodom_predict_3=low;
    elseif nodom_predict_3>up
        nodom_predict_3=up;
    end

    if nodom_predict_4<low
        nodom_predict_4=low;
    elseif nodom_predict_4>up
        nodom_predict_4=up;
    end

    if nodom_predict_5<low
        nodom_predict_5=low;
    elseif nodom_predict_5>up
        nodom_predict_5=up;
    end

    if nodom_predict_6<low
        nodom_predict_6=low;
    elseif nodom_predict_6>up
        nodom_predict_6=up;
    end

    if nodom_predict_7<low
        nodom_predict_7=low;
    elseif nodom_predict_7>up
        nodom_predict_7=up;
    end
    if nodom_predict_8<low
        nodom_predict_8=low;
    elseif nodom_predict_8>up
        nodom_predict_8=up;
    end



end