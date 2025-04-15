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
using Toybox.Math;
using Toybox.Timer;

class AuxLayer extends Ui.View {

  // ... Layers
  private var hints as Ui.Layer?;
  private var dots as Ui.Layer?;

  private var loc1 as Boolean = false;
  private var loc2 as Boolean = false;

  // ...  Dots Timer
  private var oDotsTimer as Timer.Timer = new Timer.Timer();

  //! Constructor
  public function initialize(_loc1 as Boolean, _loc2 as Boolean, _hintOnAct as Boolean) {
    View.initialize();

    loc1 = _loc1;
    loc2 = _loc2;

    // Layer
    dots = new Ui.Layer({:locX=>0, :locY=>(Sys.getDeviceSettings().screenWidth*0.22).toNumber(), 
                        :width=>(Sys.getDeviceSettings().screenWidth*0.14).toNumber(), :height=>(Sys.getDeviceSettings().screenWidth*0.56).toNumber()});
    addLayer(dots);
    (self.oDotsTimer as Timer.Timer).start(method(:clearDots), 1500, false);
    Dots();

    if(!_hintOnAct || ($.oMyActivity != null)) {
      if($.oMyProcessing.iIsCurrent != 6 || ($.oMyProcessing.iIsCurrent == 6 && $.iMyViewLogIndex >= 0)) {
        hints = new Ui.Layer({:locX=>(Sys.getDeviceSettings().screenWidth*0.84).toNumber(), :locY=>(Sys.getDeviceSettings().screenWidth*0.15).toNumber(),
                            :width=>(Sys.getDeviceSettings().screenWidth*0.16).toNumber(), :height=>(Sys.getDeviceSettings().screenWidth*0.70).toNumber()});
        addLayer(hints);
        Hints();
      }
    }
  }

  public function Dots() as Void {
    var iLayoutCenter = (Sys.getDeviceSettings().screenHeight * 0.5).toNumber();
    var iDotRadius = (Sys.getDeviceSettings().screenHeight * 0.017).toNumber();
    var fPos = 0.93;
    var iColorText = $.oMySettings.iGeneralBackgroundColor ? (([2].indexOf($.oMyProcessing.iIsCurrent) >= 0) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK) 
                                                          : (([2, 4].indexOf($.oMyProcessing.iIsCurrent) >= 0) ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE);
    var iColorTextGr = $.oMySettings.iGeneralBackgroundColor ? (([2].indexOf($.oMyProcessing.iIsCurrent) >= 0) ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY) 
                                                          : (([2, 4].indexOf($.oMyProcessing.iIsCurrent) >= 0) ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_LT_GRAY);
    var n = $.oMySettings.bGeneralOxDisplay ? (($.oMyActivity != null) ? 6 : 7) 
                                            : (($.oMyActivity != null) ? 5 : 6);
    var current = $.oMySettings.bGeneralOxDisplay ? $.oMyProcessing.iIsCurrent : $.oMyProcessing.iIsCurrent - 1;
    if($.oMySettings.bGeneralOxDisplay && ($.iViewGenOxIdx == 1) && ($.oMyProcessing.iIsCurrent == 1)) { current -= 1; }
    if(!$.oMySettings.bGeneralVarioDisplay) {
      n -= 1;
      current -= ($.oMyProcessing.iIsCurrent > 2) ? 1 : 0;
    }
    if(!$.oMySettings.bGeneralMapDisplay) {
      n -= 1;
      current -= ($.oMyProcessing.iIsCurrent > 4) ? 1 : 0;
    }
    dots.getDc().setColor(iColorTextGr, Graphics.COLOR_TRANSPARENT);
    dots.getDc().clear();
    for(var i = (n-1)*5; i >= -(n-1)*5; i -= 10) {
      var dX = Math.round(iLayoutCenter*(fPos)*Math.cos(Math.toRadians(i)));
      var dY = Math.round(iLayoutCenter*(fPos)*Math.sin(Math.toRadians(i)));
      dots.getDc().fillCircle(iLayoutCenter - dX, (1 - 0.44) * iLayoutCenter + dY, iDotRadius);
    }
    dots.getDc().setColor(iColorText, Graphics.COLOR_TRANSPARENT);
    dots.getDc().fillCircle(iLayoutCenter - Math.round(iLayoutCenter*(fPos)*Math.cos(Math.toRadians(-(n-1)*5 + 10*current))), 
                            (1 - 0.44) * iLayoutCenter + Math.round(iLayoutCenter*(fPos)*Math.sin(Math.toRadians(-(n-1)*5 + 10*current))), Math.round(iDotRadius*1.3)+2);
    dots.getDc().setColor(0x55aaaa, Graphics.COLOR_TRANSPARENT);
    dots.getDc().fillCircle(iLayoutCenter - Math.round(iLayoutCenter*(fPos)*Math.cos(Math.toRadians(-(n-1)*5 + 10*current))), 
                            (1 - 0.44) * iLayoutCenter + Math.round(iLayoutCenter*(fPos)*Math.sin(Math.toRadians(-(n-1)*5 + 10*current))), Math.round(iDotRadius*1.3));
  }

  (:icon)
  public function Hints() as Void {
    hints.getDc().clear();
    if(loc1) {
      var appIcon1 = Ui.loadResource($.Rez.Drawables.rightTop);
      hints.getDc().drawBitmap(Rez.Styles.system_loc__hint_button_right_top.x - (Sys.getDeviceSettings().screenWidth*0.84).toNumber(), 
                              Rez.Styles.system_loc__hint_button_right_top.y - (Sys.getDeviceSettings().screenWidth*0.15).toNumber(), appIcon1);
    } 
    if(loc2) {
      var appIcon2 = Ui.loadResource($.Rez.Drawables.rightBottom);
      hints.getDc().drawBitmap(Rez.Styles.system_loc__hint_button_right_bottom.x - (Sys.getDeviceSettings().screenWidth*0.84).toNumber(), 
                              Rez.Styles.system_loc__hint_button_right_bottom.y - (Sys.getDeviceSettings().screenWidth*0.15).toNumber(), appIcon2);
    }
  }

  (:noicon)
  public function Hints() as Void {
    if(loc1 || loc2) { return; }
  }

  public function clearDots() as Void {
    removeLayer(dots);
  }

  public function onHide() as Void {
    // invoke default View.onHide() which will stop all animations
    View.onHide();

    (self.oDotsTimer as Timer.Timer).stop();
  }
}
