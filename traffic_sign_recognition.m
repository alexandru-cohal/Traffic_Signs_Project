function class = traffic_sign_recognition( ROI )
% Classify the Traffic Sign included in the given ROI

    %% Constants
    
    TH_WHITE_HORIZONTAL = 20;
    TH_MINIMUM_WHITE = 20;
    TH_WHITE_TURNAROUND = 15;
    TH_BLUE_RATIO = 0.30;
    TH_RED_RATIO = 0.40;
    TH_WHITE_RATIO = 0.3;
    TH_RED_IN_WHITE_SIGN = 2;
    TH_MIN_END_OF_RESRICTIONS = 0.06;
    TH_MAX_END_OF_RESRICTIONS = 0.4;
    TH_BLACK_FORBIDDEN = 0.12;

    %% Initializations
    
    class = -1;
    
    ROI_size = size(ROI);
    radius = ROI_size(1) / 2;
    
    red_pixel_U_no = 0;
    red_pixel_D_no = 0;
    blue_pixel_no = 0;
    white_pixel_UL_no = 0;
    white_pixel_UR_no = 0;
    white_pixel_DL_no = 0;
    white_pixel_DR_no = 0;
    black_pixel_L_no = 0;
    black_pixel_R_no = 0;
    undefined_color_pixel_no = 0;
    pixel_no = 0;

    %% Count pixel colors

    for row = 1 : ROI_size(1)
        for column = 1 : ROI_size(2)             
            if pdist([radius radius; row column]) <= radius
                pixel_no = pixel_no + 1;
                
                color_type = pixel_color(ROI(row, column, 1), ROI(row, column, 2), ROI(row, column, 3));
                
                switch color_type
                    case 1 % RED
                        if row <= radius
                            red_pixel_U_no = red_pixel_U_no + 1;
                        else
                            red_pixel_D_no = red_pixel_D_no + 1;
                        end;
                    case 2 % BLUE
                        blue_pixel_no = blue_pixel_no + 1;
                    case 3 % WHITE
                        if row <= radius
                            if column <= radius
                                white_pixel_UL_no = white_pixel_UL_no + 1;
                            else
                                white_pixel_UR_no = white_pixel_UR_no + 1;
                            end;
                        else
                            if column <= radius
                                white_pixel_DL_no = white_pixel_DL_no + 1;
                            else
                                white_pixel_DR_no = white_pixel_DR_no + 1;
                            end;
                        end;
                    case 4 % BLACK
                        if column <= radius
                            black_pixel_L_no = black_pixel_L_no + 1;
                        else
                            black_pixel_R_no = black_pixel_R_no + 1;
                        end;
                    case 5 % UNDEFINED
                        undefined_color_pixel_no = undefined_color_pixel_no + 1;
                end;
            end;
        end;
    end;
        
    
    %% Clasify Traffic Sign
    
    if (blue_pixel_no / pixel_no > TH_BLUE_RATIO)
        if (white_pixel_DR_no > white_pixel_UL_no && white_pixel_DR_no > white_pixel_UR_no && white_pixel_DR_no > white_pixel_DL_no)
            fprintf('DETOUR RIGHT \n');
            class = 1;
        else  
            if (abs( (white_pixel_DL_no + white_pixel_UL_no) - (white_pixel_DR_no + white_pixel_UR_no) ) < TH_WHITE_HORIZONTAL && white_pixel_UL_no + white_pixel_UR_no + white_pixel_DL_no + white_pixel_DR_no >= TH_MINIMUM_WHITE )
                fprintf('GO STRAIGHT \n');
                class = 2;
            else
                if ((white_pixel_UR_no > white_pixel_UL_no) && (white_pixel_UR_no > white_pixel_DL_no) && (white_pixel_UR_no > white_pixel_DR_no))
                    fprintf('TURN RIGHT \n');                   
                    class = 3;
                else
                    if (abs(white_pixel_UR_no-white_pixel_UL_no) <= TH_WHITE_TURNAROUND && abs(white_pixel_UR_no-white_pixel_DR_no) <= TH_WHITE_TURNAROUND && abs(white_pixel_UR_no-white_pixel_DL_no) <= TH_WHITE_TURNAROUND && ...
                            abs(white_pixel_UL_no-white_pixel_DR_no) <= TH_WHITE_TURNAROUND && abs(white_pixel_UL_no-white_pixel_DL_no) <= TH_WHITE_TURNAROUND && ...
                            abs(white_pixel_DR_no-white_pixel_DL_no) <= TH_WHITE_TURNAROUND)
                        fprintf('TURN AROUND \n');
                        class = 4;                  
                    end;
                end;
            end;
        end;
    else
        if (red_pixel_U_no + red_pixel_D_no) / pixel_no > TH_RED_RATIO
           fprintf('FORBIDDEN \n');
           class = 5;
        else
            if (white_pixel_UL_no + white_pixel_UR_no + white_pixel_DL_no + white_pixel_DR_no) / pixel_no >= TH_WHITE_RATIO
                if ((red_pixel_U_no + red_pixel_D_no) <= TH_RED_IN_WHITE_SIGN && (black_pixel_L_no + black_pixel_R_no) / pixel_no <= TH_MAX_END_OF_RESRICTIONS && (black_pixel_L_no + black_pixel_R_no) / pixel_no >= TH_MIN_END_OF_RESRICTIONS)
                    fprintf('END OF RESTRICTIONS \n');
                    class = 6;
                else
                    if ((red_pixel_U_no + red_pixel_D_no) <= TH_RED_IN_WHITE_SIGN && (black_pixel_L_no + black_pixel_R_no) / pixel_no >= TH_MAX_END_OF_RESRICTIONS)
                        fprintf('FORBIDDEN TRUCK OVERCOME \n');
                        class = 7;
                    else
                        if ((red_pixel_U_no + red_pixel_D_no) >= TH_RED_IN_WHITE_SIGN && (black_pixel_L_no + black_pixel_R_no) / pixel_no <= TH_BLACK_FORBIDDEN )
                            fprintf('FORBIDDEN \n');
                            class = 8;
                        else
                            fprintf('SPEED LIMITATION \n');
                            class = 9;
                        end;
                    end;
                end;
            end;
        end;
    end;
    
    fprintf('\n');
end