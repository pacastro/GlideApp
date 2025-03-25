// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Generic ConnectIQ Helpers/Resources (CIQ Helpers)
// Copyright (C) 2017-2022 Cedric Dufour <http://cedric.dufour.name>
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is distributed in the hope
// that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

import Toybox.Lang;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class HintLayer extends Ui.View {

  //! Constructor
  (:icon)
  public function initialize(_loc1 as Boolean, _loc2 as Boolean) {
    View.initialize();

    var loc1 = _loc1;
    var loc2 = _loc2;

    // Layer
    var hints = new Ui.Layer({:x=>0, :y=>0, :width=>Sys.getDeviceSettings().screenWidth, :height=>Sys.getDeviceSettings().screenWidth});
    addLayer(hints);

    // ... Layer hint buttons
    hints.getDc().clear();
    if(loc1) {
      var appIcon1 = Ui.loadResource($.Rez.Drawables.rightTop);
      hints.getDc().drawBitmap(Rez.Styles.system_loc__hint_button_right_top.x, Rez.Styles.system_loc__hint_button_right_top.y, appIcon1);
    } 
    if(loc2) {
      var appIcon2 = Ui.loadResource($.Rez.Drawables.rightBottom);
      hints.getDc().drawBitmap(Rez.Styles.system_loc__hint_button_right_bottom.x, Rez.Styles.system_loc__hint_button_right_bottom.y, appIcon2);
    }
  }

  (:noicon)
  public function initialize(_loc1 as Boolean, _loc2 as Boolean) {
    View.initialize();
  }
}
