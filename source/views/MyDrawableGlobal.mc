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
  private var oRezOxStatus as Ui.Drawable;
  private var oRezFieldsBackgroundOx as Ui.Drawable;

  // Colors
  private var iColorFieldsBackground as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorAlertLeft as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorAlertCenter as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorAlertRight as Number = Gfx.COLOR_TRANSPARENT;

  private var iColorAlertOx as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorOxStatus as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorFieldsBackgroundOx as Number = Gfx.COLOR_TRANSPARENT;


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
    oRezOxStatus = new Rez.Drawables.drawOxStatus();
    oRezFieldsBackgroundOx = new Rez.Drawables.drawFieldsBackgroundOx();
  }

  function draw(_oDC) {
    // Draw

    // ... fields
    _oDC.setColor(self.iColorFieldsBackground, Gfx.COLOR_TRANSPARENT);
    self.oRezFieldsBackground.draw(_oDC);

    _oDC.setColor(self.iColorFieldsBackgroundOx, Gfx.COLOR_TRANSPARENT);
    self.oRezFieldsBackgroundOx.draw(_oDC);

    _oDC.setColor(self.iColorOxStatus, Gfx.COLOR_TRANSPARENT);
    self.oRezOxStatus.draw(_oDC);

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

  function setColorOxStatus(_iColor as Number) as Void {
    self.iColorOxStatus = _iColor;
  }
  function setColorFieldsBackgroundOx(_iColor as Number) as Void {
    self.iColorFieldsBackgroundOx = _iColor;
  }

}
