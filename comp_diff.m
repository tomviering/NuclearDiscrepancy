function comp_diff(str, t1, t2)
% computes whether t1 and t2 are significantly different numbers 
% this can be used to check for rounding errors
% many stars indicate a problem

    diff = abs(t1 - t2);
    sign = (eps(t1) + eps(t2))/2;
    
    D = (log10(diff));
    DS = (log10(sign));
    
    fprintf('%30s %2d %2d',str,round(D),round(DS));
    stars = D - DS;
    if stars < 0
        stars = 0;
    end
    fprintf(' ');
    for i = 1:stars
        fprintf('*');
    end
    fprintf('\n');
        

end