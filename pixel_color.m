function color_type = pixel_color( r, g, b )
% Return the color of the given pixel
% Type = 1 - red, 2 - blue, 3 - white, 4 - black, 5 - undefined

    TH_RED_RATIO = 0.5;
    TH_BLUE_RATIO = 0.15;
    TH_WHITE_BLACK = 125;
    TH_SIMILAR = 30;
                   
    if (g / r <= TH_RED_RATIO && b / r <= TH_RED_RATIO)
        color_type = 1;
    else
        if (r / b <= TH_BLUE_RATIO && g / b <= TH_BLUE_RATIO)
            color_type = 2;
        else
            if (r >= TH_WHITE_BLACK && g >= TH_WHITE_BLACK && b >= TH_WHITE_BLACK && ...
                    abs(r - g) <= TH_SIMILAR && abs(r - b) <= TH_SIMILAR && abs(g - b) <= TH_SIMILAR)
                color_type = 3;
            else
                if (r <= TH_WHITE_BLACK && g <= TH_WHITE_BLACK && b <= TH_WHITE_BLACK)
                    color_type = 4;
                else
                    color_type = 5;
                end;
            end;
        end;     
    end;
end