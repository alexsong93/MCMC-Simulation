% check to see if all elements of start_row are zero - means the state
% transition never happened so choose a different start_row
function out = isValid(startRow,C)
    if(C(startRow,:)==0)
        out = 0;
    else
        out = 1;
    end
end
