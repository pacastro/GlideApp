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

import Toybox.Lang;
using Toybox.Position as Pos;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class MyDrawableHeader extends Ui.Drawable {

  //
  // VARIABLES
  //

  // Resources
  private var oRezHeaderAccuracy1 as Ui.Drawable;
  private var oRezHeaderAccuracy2 as Ui.Drawable;
  private var oRezHeaderAccuracy3 as Ui.Drawable;
  private var oRezHeaderAccuracy4 as Ui.Drawable;
  private var oRezOxStatus as Ui.Drawable;
  private var oRezMapHeaderBg as Ui.Drawable;

  // Color
  private var iColorBackground as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorOxStatus as Number = Gfx.COLOR_TRANSPARENT;

  //
  // FUNCTIONS: Ui.Drawable (override/implement)
  //

  function initialize() {
    Drawable.initialize({:identifier => "MyDrawableHeader"});

    // Resources
    oRezHeaderAccuracy1 = new Rez.Drawables.drawHeaderAccuracy1();
    oRezHeaderAccuracy2 = new Rez.Drawables.drawHeaderAccuracy2();
    oRezHeaderAccuracy3 = new Rez.Drawables.drawHeaderAccuracy3();
    oRezHeaderAccuracy4 = new Rez.Drawables.drawHeaderAccuracy4();

    oRezOxStatus = new Rez.Drawables.drawOxStatus();
    oRezMapHeaderBg = new Rez.Drawables.drawMapHeaderBackground();
  }

  function draw(_oDC) {
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor, Gfx.COLOR_TRANSPARENT);
    self.oRezMapHeaderBg.draw(_oDC);

    // Draw
    // ... background
    _oDC.setColor(self.iColorBackground, self.iColorBackground);
    _oDC.clear();

    // ... positioning accuracy
    switch($.oMyProcessing.iAccuracy) {

    case Pos.QUALITY_GOOD:
      _oDC.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy1.draw(_oDC);
      self.oRezHeaderAccuracy2.draw(_oDC);
      self.oRezHeaderAccuracy3.draw(_oDC);
      self.oRezHeaderAccuracy4.draw(_oDC);
      break;

    case Pos.QUALITY_USABLE:
      _oDC.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy1.draw(_oDC);
      self.oRezHeaderAccuracy2.draw(_oDC);
      self.oRezHeaderAccuracy3.draw(_oDC);
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy4.draw(_oDC);
      break;

    case Pos.QUALITY_POOR:
      _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy1.draw(_oDC);
      self.oRezHeaderAccuracy2.draw(_oDC);
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy3.draw(_oDC);
      self.oRezHeaderAccuracy4.draw(_oDC);
      break;

    case Pos.QUALITY_LAST_KNOWN:
      _oDC.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy1.draw(_oDC);
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy2.draw(_oDC);
      self.oRezHeaderAccuracy3.draw(_oDC);
      self.oRezHeaderAccuracy4.draw(_oDC);
      break;

    case Pos.QUALITY_NOT_AVAILABLE:
    default:
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy1.draw(_oDC);
      self.oRezHeaderAccuracy2.draw(_oDC);
      self.oRezHeaderAccuracy3.draw(_oDC);
      self.oRezHeaderAccuracy4.draw(_oDC);
      break;

    }

    // ... SpO2 Status
    if ($.oMySettings.bGeneralOxDisplay && LangUtils.notNaN($.oMyProcessing.iAgeOx) && LangUtils.notNaN($.oMyProcessing.iOx)
        && ($.oMySettings.bOxMeasure?($.oMyAltimeter.fAltitudeActual >= $.oMySettings.iOxElevation):true)) {
      if (($.oMyProcessing.iAgeOx <= 6 * 60) && ($.oMyProcessing.iOx >= 95)) {
        self.iColorOxStatus = Gfx.COLOR_DK_GREEN;
      }
      else if (($.oMyProcessing.iAgeOx >= 20 * 60) || ($.oMyProcessing.iOx <= 90)) {
        if ($.oMyProcessing.iOx <= $.oMySettings.iOxCritical) {
          self.iColorOxStatus = Time.now().value() % 2 ? Gfx.COLOR_RED : Gfx.COLOR_TRANSPARENT;
        } else {
          self.iColorOxStatus = Gfx.COLOR_RED;
        }
      }
      else if (($.oMyProcessing.iAgeOx > 6 * 60) || ($.oMyProcessing.iOx > 90)) {
        self.iColorOxStatus = Gfx.COLOR_YELLOW;
      }
      _oDC.setColor(self.iColorOxStatus, Gfx.COLOR_TRANSPARENT);
      self.oRezOxStatus.draw(_oDC);
    }
  }

  //
  // FUNCTIONS: self
  //

  function setColorBackground(_iColorBackground as Number) as Void {
    self.iColorBackground = _iColorBackground;
  }
}
