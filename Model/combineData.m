
% both time of day and seasons selected.....................................
if(morn_check == 1 && seasons_check == 1)
    num_days = [153,61,151];
    index = 1;
    data_simul{13} = [];
    for i = 1:numel(num_days)
        season = [];
        start_morn = 1; start_after = 1; start_even = 1; start_night = 1;
        morn_range = 7*(60/intv); after_range = 5*(60/intv);
        even_range = 4*(60/intv); night_range = 8*(60/intv);
        end_morn = 7*(60/intv); end_after= 5*(60/intv);
        end_even = 4*(60/intv); end_night = 8*(60/intv);
        season = data_simul{index + 3}(start_night:6*(60/intv));
        
        if(i == str2double(leap_value(1)))
            num_days(3) = 152;
        end
        
        for j = 1:num_days(i)*len
            season = vertcat(season, data_simul{index}(start_morn:end_morn)); %#ok<*AGROW>
            start_morn = end_morn + 1;
            end_morn = start_morn + morn_range - 1;
            
            season = vertcat(season, data_simul{index + 1}(start_after:end_after));
            start_after = end_after + 1;
            end_after = start_after + after_range- 1;
            
            season = vertcat(season, data_simul{index + 2}(start_even:end_even));
            start_even = end_even + 1;
            end_even = start_even + even_range - 1;
            
            season = vertcat(season, data_simul{index + 3}(start_night:end_night));
            start_night = end_night + 1;
            end_night = start_night + night_range - 1;
        end

        seasons{i} = season;
        index = index + 4;
    end
end

% both selected continued, or only seasons selected........................
if((morn_check == 0 && seasons_check == 1) || (morn_check == 1 && seasons_check == 1))
    if(morn_check == 0 && seasons_check == 1)
        data_simul{4} = [];
        d_simulated = data_simul;
    elseif(morn_check == 1 && seasons_check == 1)
        data_simul{13} = [];
        d_simulated = seasons;
    end
    d_simulated{4} = [];
    year_diff = start_year;
    for i = 1:len
        yearly_sim_data{i} = d_simulated{3}(start_year:end_win);
        yearly_sim_data{i} = vertcat(yearly_sim_data{i}, d_simulated{2}(start_spr:start_oct-1));
        yearly_sim_data{i} = vertcat(yearly_sim_data{i}, d_simulated{1}(start_summ:end_summ));
        yearly_sim_data{i} = vertcat(yearly_sim_data{i}, d_simulated{2}(start_oct:end_oct));
        yearly_sim_data{i} = vertcat(yearly_sim_data{i}, d_simulated{3}(start_win:start_year-1));
        d_simulated{4} = vertcat(d_simulated{4},yearly_sim_data{i});
        if(i < len)
            windiff = end_win - start_year;
            start_win = end_win + 1;
            start_year = end_win + year_diff;
            end_win = start_year + windiff;
            
            diff = end_summ - start_summ;
            start_summ = end_summ + 1;
            end_summ = start_summ + diff;
            
            diff = start_oct-1 - start_spr;
            start_spr = end_oct + 1;
            octdiff = end_oct - start_oct;
            start_oct = start_spr + diff + 1;
            end_oct = start_oct + octdiff;
        end

    end
    if(morn_check == 0 && seasons_check == 1)
        data_simul{4} = d_simulated{4};
        data_orig{4} = orig_data;
    elseif(morn_check == 1 && seasons_check == 1)
        data_simul{13} = d_simulated{4};
        data_orig{13} = orig_data;
    end
end