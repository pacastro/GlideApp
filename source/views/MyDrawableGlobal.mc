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
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Time;

class MyDrawableGlobal extends Ui.Drawable {

  //
  // VARIABLES
  //

  // Resources
  private var oRezFieldsBackground as Ui.Drawable;
  private var oRezAlertLeft as Ui.Drawable;
  private var oRezAlertCenter as Ui.Drawable;
  private var oRezAlertRight as Ui.Drawable;

  private var oRezAlertOx as Ui.Drawable;
  private var oRezFieldsBackgroundOx as Ui.Drawable;

  // Colors
  private var iColorFieldsBackground as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorAlertLeft as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorAlertCenter as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorAlertRight as Number = Gfx.COLOR_TRANSPARENT;

  private var iColorAlertOx as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorFieldsBackgroundOx as Number = Gfx.COLOR_TRANSPARENT;
  private var iFgColor as Number = Gfx.COLOR_TRANSPARENT;


  //
  // FUNCTIONS: Ui.Drawable (override/implement)
  //

  function initialize() {
    Drawable.initialize({:identifier => "MyDrawableGlobal"});

    // Resources
    oRezFieldsBackground = new Rez.Drawables.drawFieldsBackground();
    oRezAlertLeft = new Rez.Drawables.drawGlobalAlertLeft();
    oRezAlertCenter = new Rez.Drawables.drawGlobalAlertCenter();
    oRezAlertRight = new Rez.Drawables.drawGlobalAlertRight();

    oRezAlertOx = new Rez.Drawables.drawAlertOx();
    oRezFieldsBackgroundOx = new Rez.Drawables.drawFieldsBackgroundOx();
  }

  function draw(_oDC) {
    // Draw

    // ... fields
    _oDC.setColor(self.iColorFieldsBackground, Gfx.COLOR_TRANSPARENT);
    self.oRezFieldsBackground.draw(_oDC);

    _oDC.setColor(self.iColorFieldsBackgroundOx, Gfx.COLOR_TRANSPARENT);
    self.oRezFieldsBackgroundOx.draw(_oDC);

    // ... alerts
    if(self.iColorAlertLeft != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(self.iColorAlertLeft, Gfx.COLOR_TRANSPARENT);
      self.oRezAlertLeft.draw(_oDC);
    }
    if(self.iColorAlertCenter != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(self.iColorAlertCenter, Gfx.COLOR_TRANSPARENT);
      self.oRezAlertCenter.draw(_oDC);
    }
    if(self.iColorAlertRight != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(self.iColorAlertRight, Gfx.COLOR_TRANSPARENT);
      self.oRezAlertRight.draw(_oDC);
    }

    if(self.iColorAlertOx != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(self.iColorAlertOx, Gfx.COLOR_TRANSPARENT);
      self.oRezAlertOx.draw(_oDC);
    }

    // ... Display Start/Pause/Stop anim
    if(_oDC has :setAntiAlias) { _oDC.setAntiAlias(true); }
    if ((($.oMyActivity != null) && (bActStart || bActPause)) || bActStop) {
      var iRadius = (_oDC.getWidth()*0.15f).toNumber();
      var icentX = (_oDC.getWidth()/2).toNumber();
      var icentY = (_oDC.getHeight()/2).toNumber();
      
      if (Time.now().subtract(oDispTime).value() <= 1) {
        if (bActStart) {
          // Draw start arrow
          var aistart = [
            [icentX - iRadius, icentY - iRadius],
            [icentX + iRadius, icentY],
            [icentX - iRadius, icentY + iRadius],
          ];
          iFgColor = Gfx.COLOR_DK_GREEN;
          _oDC.setColor(iFgColor, Gfx.COLOR_TRANSPARENT);
          _oDC.fillPolygon(aistart);
        }
        else if (bActPause) {
           // Draw pause
          iFgColor = Gfx.COLOR_ORANGE;
          _oDC.setColor(iFgColor, Gfx.COLOR_TRANSPARENT);
          _oDC.fillRectangle(icentX - iRadius, icentY - iRadius, iRadius/2, iRadius*2);
          _oDC.fillRectangle(icentX + iRadius, icentY - iRadius, -iRadius/2, iRadius*2);
        }
        else if (bActStop) {
          // Draw stop box
          iFgColor = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_RED : Gfx.COLOR_RED;
          _oDC.setColor(iFgColor, Gfx.COLOR_TRANSPARENT);
          _oDC.fillRectangle(icentX - iRadius, icentY - iRadius, iRadius*2, iRadius*2);
        }
      }
      // Draw surrounding circle
      _oDC.setColor(bActStop?Gfx.COLOR_DK_RED:iFgColor, Gfx.COLOR_TRANSPARENT);
      _oDC.setPenWidth(_oDC.getWidth()*0.04f);
      _oDC.drawCircle(icentX, icentY, icentX);
      
      if ((Time.now().subtract(oDispTime).value() > 2) && !bActStop) {
        bActStart = false;
        bActPause = false;
      }
    }

    if (($.oMyActivity == null) && ([3, 4, 6].indexOf($.oMyProcessing.iIsCurrent) < 0) && ($.oMyProcessing.iAccuracy > 1) || ((bActStop ? !bActPause : false) && $.oMyProcessing.iIsCurrent == 5)) {
      _oDC.setColor(((bActStop ? !bActPause : false) ? $.oMyProcessing.iIsCurrent != 5 : true) ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      _oDC.setPenWidth((_oDC.getWidth()*0.018).toNumber());
      _oDC.drawArc(_oDC.getWidth()/2, _oDC.getWidth()/2, (_oDC.getWidth()/2*0.965).toNumber(), Gfx.ARC_COUNTER_CLOCKWISE, 20, 40);
    }
  }

  //
  // FUNCTIONS: self
  //

  function setColorFieldsBackground(_iColor as Number) as Void {
    self.iColorFieldsBackground = _iColor;
  }

  function setColorAlertLeft(_iColor as Number) as Void {
    self.iColorAlertLeft = _iColor;
  }

  function setColorAlertCenter(_iColor as Number) as Void {
    self.iColorAlertCenter = _iColor;
  }

  function setColorAlertRight(_iColor as Number) as Void {
    self.iColorAlertRight = _iColor;
  }

  function setColorAlertOx(_iColor as Number) as Void {
    self.iColorAlertOx = _iColor;
  }

  function setColorFieldsBackgroundOx(_iColor as Number) as Void {
    self.iColorFieldsBackgroundOx = _iColor;
  }

}
