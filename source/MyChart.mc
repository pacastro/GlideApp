// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// GlideApp
// Copyright (C) 2024 Pablo Castro
//
// GlideApp is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// GlideApp is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt
// GlideApp is based on My Vario Lite by Yannick Dutertre and Glider's Swiss Knife (GliderSK) by Cedric Dufour

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2022 Cedric Dufour <http://cedric.dufour.name>
//
// Glider's Swiss Knife (GliderSK) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Glider's Swiss Knife (GliderSK) is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class MyChart {
    var model;

    function initialize(a_model) {
        model = a_model;
    }

    function draw(dc, x1y1x2y2,
                  range_min_size, draw_min_max, draw_axes,
                  strict_min_max_bounding, bar_chart, coef) {
        // Work around 10 arg limit!
        var aData = x1y1x2y2 as ANumbers;
        var x1 = aData[0];
        var y1 = aData[1];
        var x2 = aData[2];
        var y2 = aData[3];

        var data = model.get_values() as AFloats;
        var line_color = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY;
        var block_color = $.oMySettings.iGeneralBackgroundColor ? 0x55aaaa : 0x005555;
        var iColorText = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
        var iColorTextGr = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY;

        var range_border = range_min_size <= 2 ? 0.25 : 5;

        var width = x2 - x1;
        var height = y2 - y1;
        var x = x1;
        var item;

        var min = model.get_min();
        var max = model.get_max();

        var range_min = min - range_border;
        var range_max = max + range_border;
        if (range_max - range_min < range_min_size) {
            range_max = range_min + range_min_size;
        }
        
        var x_old = null;
        var y_old = null;
        if(bar_chart) {
            for (x = x1; x <= x2; x++) {
                item = data[x_item(x, x1, width, data.size())];
                if (item != null && item > range_max) {
                    dc.setColor(block_color, Gfx.COLOR_TRANSPARENT);
                    dc.drawLine(x, y1, x, y2);
                    x_old = null;
                    y_old = null;
                }
                else if (item != null && item >= range_min) {
                    var y = item_y(item, y2, height, range_min, range_max);
                    dc.setColor(block_color, Gfx.COLOR_TRANSPARENT);
                    dc.drawLine(x, y, x, y2);
                    if (x_old != null) {
                        dc.setColor(line_color, Gfx.COLOR_TRANSPARENT);
                        dc.drawLine(x_old, y_old, x, y);
                        // TODO is the below line needed due to a CIQ bug
                        // or some subtlety I don't understand?
                        // dc.drawPoint(x, y);
                    }
                    x_old = x;
                    y_old = y;
                }
                else {
                    x_old = null;
                    y_old = null;
                }
            }
        } 
        else if(data.size() >= 2) {
            x_old = x1;
            y_old = item_y(data[0], y2, height, range_min, range_max);
            var idx_old = 0;
            for (x = x1; x <= x2; x++) {
                var idx = (x - x1) * (data.size() -1) / width;
                item = data[idx];
                if(item != null) {
                    var y = item_y(item, y2, height, range_min, range_max);
                    if(idx_old != idx) {
                        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
                        dc.drawLine(x_old, y_old, x, y);
                        x_old = x;
                        y_old = y;
                        idx_old = idx;
                    }
                }
            }
        }

        if (draw_axes) {
            dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
            tick_line(dc, x1, y1, y2, -5, 3, true);
            tick_line(dc, x2, y1, y2, 5, 3, true);
            if(bar_chart) {
                tick_line(dc, y2, x1, x2 + 1, 0, 3, false);
            } else if(data.size() > 2) {
                dc.setColor(iColorTextGr, Gfx.COLOR_TRANSPARENT);
                tick_line(dc, y2, x1, x2 + 1, -5, (data.size() - 2), false);
            }
        
        }

        if (draw_min_max and model.get_min_max_interesting()) {
            dc.setColor(iColorText, Gfx.COLOR_TRANSPARENT);
            var bg_color = iColorText == Gfx.COLOR_WHITE
                ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
            label_text(dc, item_x(model.get_min_i(), x1, width, data.size()),
                       item_y(min, y2, height, range_min, range_max),
                       x1y1x2y2, line_color, bg_color, 
                       bar_chart?(min*coef).format((range_min_size<=1)?"%.1f":"%.0f")
                       :Lang.format("$1$ +$2$h", [(min*coef).format("%.0f"), model.get_min_i().format("%.0f")]),
                       strict_min_max_bounding, false);
            label_text(dc, item_x(model.get_max_i(), x1, width, data.size()),
                       item_y(max, y2, height, range_min, range_max),
                       x1y1x2y2, line_color, bg_color, 
                       bar_chart?(max*coef).format((range_min_size<=1)?"%.1f":"%.0f")
                       :Lang.format("$1$ +$2$h", [(max*coef).format("%.0f"), model.get_max_i().format("%.0f")]),
                       strict_min_max_bounding, true);
        }
    }

    function item_x(i, orig_x, width, size) {
        return orig_x + i * width / (size - 1);
    }

    function x_item(x, orig_x, width, size) {
        return (x - orig_x) * (size - 1) / width;
    }

    function item_y(item, orig_y, height, min, max) {
        return orig_y - height * (item - min) / (max - min);
    }

    function label_text(dc, x, y, x1y1x2y2, fg, bg, txt, strict, above) {
        var oFontChartMinMax = WatchUi.loadResource(Rez.Fonts.fontPlotS);
        var aData = x1y1x2y2 as ANumbers;
        var x1 = aData[0];
        var y1 = aData[1];
        var x2 = aData[2];
        var y2 = aData[3];

        var dims = dc.getTextDimensions(txt, oFontChartMinMax) as AFloats;
        var w = dims[0];
        var h = dims[1];

        x -= w / 2;
        if (x < x1 + 2) {
            x = x1 + 2;
        } else if (x > x2 - w - 2) {
            x = x2 - w - 2;
        }
        if (above) {
            if(y > y1+h) {
                y -= h;
            }
        }
        if (strict) {
            if (y > y2 - h) {
                y = y2 - h;
            }
            else if (y < y1) {
                y = y1;
            }
        }
        dc.drawText(x, y, oFontChartMinMax, txt, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function tick_line(dc, c, end1, end2, tick_size, tick_n, vert) {
        tick_line0(dc, c, end1, end2, vert);
        for (var n = 1; n <= tick_n; n++) {
            tick_line0(dc, (((tick_n+1) - n) * end1 + n * end2) / (tick_n+1), c, c + tick_size,
                       !vert);
        }
    }

    function tick_line0(dc, c, end1, end2, vert) {
        if (vert) {
            dc.drawLine(c, end1, c, end2);
        } else {
            dc.drawLine(end1, c, end2, c);
        }
    }
}

class MyChartModel {

    var current = null;
    var values_size = 226; // Must be even
    var min_range_minutes = 7.5;
    var max_range_minutes1 = 240;
    var max_range_minutes2 = 30;
    var values as AFloats?;
    var range_mult;
    var range_mult_max;
    var range_expand = true;
    var range_mult_count = 0;
    var aAux as AFloats? = [];

    var min;
    var max;
    var min_i;
    var max_i;

    function initialize() {
        set_range_minutes(min_range_minutes);
    }

    function reset() {
        current = null;
        min = null;
        range_mult = 0;
        set_range_minutes(min_range_minutes);
        range_mult_count = 0;
    }

    function get_values() {
        return values;
    }

    function get_range_minutes() {
        return (values.size() * range_mult / 60);
    }

    function set_range_minutes(range) {
        var new_mult = range * 60.0 / values_size;
        if (new_mult != range_mult) {
            range_mult = new_mult;
            values = new [values_size];
            update_stats();
        }
    }

    function set_max_range_minutes(range) {
        range_mult_max = range * 60.0 / values_size;
        if(bRangeChange) {
            values[0] = null;
            bRangeChange = false;
        }
    }

    function set_range_expand(re) {
        range_expand = re;
    }

    function get_current() {
        return current;
    }

    function get_min() {
        return min;
    }

    function get_max() {
        return max;
    }

    function get_min_i() {
        return min_i;
    }

    function get_max_i() {
        return max_i;
    }

    function get_min_max_interesting() {
        return max != -99999999 and min != max;
    }

    function new_value(new_value) {
        current = new_value;
        if (current != null) {
            aAux.add(current);
        }
        range_mult_count++;
        range_mult = $.oMySettings.bChartRange?range_mult:(range_mult<(max_range_minutes2 * 60.0 / values_size)?range_mult:(max_range_minutes2 * 60.0 / values_size));
        set_max_range_minutes(($.oMySettings.bChartRange?max_range_minutes1:max_range_minutes2));
        if (range_mult_count >= range_mult) {
            var expand = range_expand && range_mult < range_mult_max && 
                        values[0] == null && values[1] != null;
            for (var i = 1; i < values.size(); i++) {
                values[i-1] = values[i];
            }
            if(aAux.size() > 2) {
                values[values.size() - 1] = LangUtils.arrayMax(aAux)-Math.mean(aAux) >= Math.mean(aAux)-LangUtils.arrayMin(aAux) ? LangUtils.arrayMax(aAux) : LangUtils.arrayMin(aAux);
            } else if(values[values.size() - 2] == null) {
                values[values.size() - 1] = aAux.size() == 0 ? null : (LangUtils.arraySum(aAux) / aAux.size());
            } else {
                values[values.size() - 1] = (LangUtils.arrayMax(aAux) >= values[values.size() - 2]) ? LangUtils.arrayMax(aAux) : LangUtils.arrayMin(aAux);
            }
            if((LangUtils.arrayMax(aAux) >= max) || (LangUtils.arrayMin(aAux) <= min)) {
                values[values.size() - 1] = (LangUtils.arrayMax(aAux) >= max) ? LangUtils.arrayMax(aAux) : LangUtils.arrayMin(aAux);
                if((LangUtils.arrayMax(aAux) >= max) && (LangUtils.arrayMin(aAux) <= min)) {
                    values[values.size() - 2] = aAux.indexOf(LangUtils.arrayMax(aAux)) < aAux.indexOf(LangUtils.arrayMin(aAux)) ? LangUtils.arrayMax(aAux) : LangUtils.arrayMin(aAux);
                    values[values.size() - 1] = aAux.indexOf(LangUtils.arrayMax(aAux)) < aAux.indexOf(LangUtils.arrayMin(aAux)) ? LangUtils.arrayMin(aAux) : LangUtils.arrayMax(aAux);
                }
            }
            range_mult_count = 0;
            aAux = [];

            if (expand) {
                do_range_expand();
            }
            update_stats();
        }
    }

    function do_range_expand() {
        var sz = values.size();
        for (var i = sz - 1; i >= sz / 2; i--) {
            var old_i = i * 2 - sz;

            aAux = [values[old_i], values[old_i+1]];
            if(aAux[0] == aAux[1]) { values[i] = aAux[0]; }
            else if(i > sz / 2) {
                values[i] = ((aAux[0] > aAux[1]) ? aAux[0] : aAux[1]) >= values[i - 1] ? LangUtils.arrayMax(aAux) : LangUtils.arrayMin(aAux);
                if((((aAux[0] > aAux[1]) ? aAux[0] : aAux[1])  >= max) && (((aAux[0] < aAux[1]) ? aAux[0] : aAux[1])  <= min)) {
                    values[i - 1] = aAux.indexOf(LangUtils.arrayMax(aAux)) < aAux.indexOf(LangUtils.arrayMin(aAux)) ? LangUtils.arrayMax(aAux) : LangUtils.arrayMin(aAux);
                    values[i] = aAux.indexOf(LangUtils.arrayMax(aAux)) < aAux.indexOf(LangUtils.arrayMin(aAux)) ? LangUtils.arrayMin(aAux) : LangUtils.arrayMax(aAux);
                }
            } else {
                values[i] = (aAux[0] + aAux[1]) / 2;
                if((((aAux[0] > aAux[1]) ? aAux[0] : aAux[1])  >= max) && (((aAux[0] < aAux[1]) ? aAux[0] : aAux[1])  <= min)) {
                    values[i] = aAux.indexOf(LangUtils.arrayMax(aAux)) < aAux.indexOf(LangUtils.arrayMin(aAux)) ? LangUtils.arrayMax(aAux) : LangUtils.arrayMin(aAux);
                    values[i + 1] = aAux.indexOf(LangUtils.arrayMax(aAux)) < aAux.indexOf(LangUtils.arrayMin(aAux)) ? LangUtils.arrayMin(aAux) : LangUtils.arrayMax(aAux);
                }
            }
            if((((aAux[0] > aAux[1]) ? aAux[0] : aAux[1])  >= max) || (((aAux[0] < aAux[1]) ? aAux[0] : aAux[1])  <= min)) {
                values[i] = (LangUtils.arrayMax(aAux) >= max) ? LangUtils.arrayMax(aAux) : LangUtils.arrayMin(aAux);
            }
        }
        for (var i = 0; i < sz / 2; i++) {
            values[i] = null;
        }
        range_mult *= 2;
        aAux = [];
    }

    function update_stats() {
        min = 99999999;
        max = -99999999;
        min_i = values.size();
        max_i = values.size();

        for (var i = 0; i < values.size(); i++) {
            var item = values[i];
            if (item != null) {
                if (item < min) {
                    min_i = i;
                    min = item;
                }
                if (item > max) {
                    max_i = i;
                    max = item;
                }
            }
        }
    }
}

class MyChartModelEstatic {

    var values_size;
    var values as AFloats?;

    var min;
    var max;
    var min_i;
    var max_i;

    function initialize(_data) {
        values = _data;
        values_size = values.size();

        update_stats();
    }

    function get_values() {
        return values;
    }

    function get_min() {
        return min;
    }

    function get_max() {
        return max;
    }

    function get_min_i() {
        return min_i;
    }

    function get_max_i() {
        return max_i;
    }

    function get_min_max_interesting() {
        return max != -99999999 and min != max;
    }

    function update_stats() {
        min = 99999999;
        max = -99999999;
        min_i = values.size();
        max_i = values.size();

        for (var i = 0; i < values.size(); i++) {
            var item = values[i];
            if (item != null) {
                if (item < min) {
                    min_i = i;
                    min = item;
                }
                if (item > max) {
                    max_i = i;
                    max = item;
                }
            }
        }
    }
}

