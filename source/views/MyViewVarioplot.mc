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
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Display mode (intent)
var iMyViewVarioplotPanZoom as Number = 0;

class MyViewVarioplot extends MyViewHeader {

  //CONSTANTS
  public const TIME_CONSTANT = 4;

  //
  // VARIABLES
  //
  // Display mode (internal)
  private var iPanZoom as Number = 0;

  // Resources
  // ... buttons
  private var oRezButtonKeyUp as Ui.Drawable?;
  private var oRezButtonKeyDown as Ui.Drawable?;

  // ... fonts
  private var oRezFontPlot as Ui.FontResource?;
  private var oRezFontPlotS as Ui.FontResource?;

  // Layout-specific
  private var iLayoutCenter as Number = 120;
  private var iLayoutClipY as Number = 31;
  private var iLayoutClipW as Number = 240;
  private var iLayoutClipH as Number = 178;
  private var iLayoutValueXleft as Number = 40;
  private var iLayoutValueXright as Number = 200;
  private var iLayoutValueYtop as Number = 30;
  private var iLayoutValueYcenter as Number = 119;
  private var iLayoutValueYbottom as Number = 190;
  private var iDotRadius = 5 as Number;

  // Color scale
  private var aiScale as Array<Number> = [-3000, -2000, -1000, -50, 50, 1000, 2000, 3000] as Array<Number>;


  //
  // FUNCTIONS: Layout-specific
  //

  (:layout_240x240)
  function initLayout() as Void {
    self.iLayoutCenter = 120;
    self.iLayoutClipY = 31;
    self.iLayoutClipW = 240;
    self.iLayoutClipH = 178;
    self.iLayoutValueXleft = 40;
    self.iLayoutValueXright = 200;
    self.iLayoutValueYtop = 30;
    self.iLayoutValueYcenter = 110;
    self.iLayoutValueYbottom = 190;
    self.iDotRadius = 3;
  }

  (:layout_260x260)
  function initLayout() as Void {
    self.iLayoutCenter = 130;
    self.iLayoutClipY = 34;
    self.iLayoutClipW = 260;
    self.iLayoutClipH = 192;
    self.iLayoutValueXleft = 43;
    self.iLayoutValueXright = 217;
    self.iLayoutValueYtop = 33;
    self.iLayoutValueYcenter = 119;
    self.iLayoutValueYbottom = 205;
    self.iDotRadius = 4;
  }

  (:layout_280x280)
  function initLayout() as Void {
    self.iLayoutCenter = 140;
    self.iLayoutClipY = 36;
    self.iLayoutClipW = 280;
    self.iLayoutClipH = 208;
    self.iLayoutValueXleft = 47;
    self.iLayoutValueXright = 233;
    self.iLayoutValueYtop = 35;
    self.iLayoutValueYcenter = 128;
    self.iLayoutValueYbottom = 221;
    self.iDotRadius = 5;
  }


  //
  // FUNCTIONS: MyViewHeader (override/implement)
  //

  function initialize() {
    MyViewHeader.initialize();

    // Layout-specific initialization
    self.initLayout();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewVarioplot.prepare()");
    MyViewHeader.prepare();

    // Load resources
    // ... fonts
    self.oRezFontPlot = Ui.loadResource(Rez.Fonts.fontPlot) as Ui.FontResource;
    self.oRezFontPlotS = Ui.loadResource(Rez.Fonts.fontPlotS) as Ui.FontResource;

    // Color scale
    switch($.oMySettings.iVariometerRange) {
    default:
    case 0:
      self.aiScale = [-3000, -2000, -1000, -50, 50, 1000, 2000, 3000] as Array<Number>;
      break;
    case 1:
      self.aiScale = [-6000, -4000, -2000, -100, 100, 2000, 4000, 6000] as Array<Number>;
      break;
    case 2:
      self.aiScale = [-9000, -6000, -3000, -150, 150, 3000, 6000, 9000] as Array<Number>;
      break;
    }

    // Unmute tones
    (App.getApp() as MyApp).unmuteTones();
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.onUpdate()");

    // Update layout
    MyViewHeader.updateLayout(true);
    View.onUpdate(_oDC);
    self.drawPlot(_oDC);
    self.drawValues(_oDC);

    // Draw buttons
    if($.iMyViewVarioplotPanZoom) {
      if(self.oRezButtonKeyUp == null or self.oRezButtonKeyDown == null
         or self.iPanZoom != $.iMyViewVarioplotPanZoom) {
        if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom in/out
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonPlus();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonMinus();
        }
        self.iPanZoom = $.iMyViewVarioplotPanZoom;
      }
      (self.oRezButtonKeyUp as Ui.Drawable).draw(_oDC);
      (self.oRezButtonKeyDown as Ui.Drawable).draw(_oDC);
    }
    else {
      self.oRezButtonKeyUp = null;
      self.oRezButtonKeyDown = null;
    }
  }

  function drawPlot(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.drawPlot()");
    var iNowEpoch = Time.now().value();

    // Draw plot
    _oDC.setPenWidth(3);
    var iPlotIndex = $.oMyProcessing.iPlotIndex;
    var iVariometerPlotRange = $.oMySettings.iVariometerPlotRange * 60;
    if(iPlotIndex < 0) {
      // No data
      return;
    }

    // ... end (center) location
    var iEndIndex = iPlotIndex;
    var iEndEpoch = $.oMyProcessing.aiPlotEpoch[iEndIndex];
    if(iEndEpoch < 0 or iNowEpoch-iEndEpoch > iVariometerPlotRange) {
      // No data or data too old
      return;
    }
    var iEndLatitude = $.oMyProcessing.aiPlotLatitude[iEndIndex];
    var iEndLongitude = $.oMyProcessing.aiPlotLongitude[iEndIndex];

    // ... start location
    var iStartEpoch = iNowEpoch-iVariometerPlotRange;

    // ... plot
    _oDC.setClip(0, self.iLayoutClipY, self.iLayoutClipW, self.iLayoutClipH);
    var iCurrentIndex = (iEndIndex-iVariometerPlotRange+1+$.oMyProcessing.PLOTBUFFER_SIZE)%($.oMyProcessing.PLOTBUFFER_SIZE);
    var fZoomX = $.oMySettings.fVariometerPlotZoom * Math.cos(iEndLatitude / 495035534.9930312523f);
    var fZoomY = $.oMySettings.fVariometerPlotZoom ;
    var iMaxDeltaEpoch = self.TIME_CONSTANT;
    var iLastEpoch = iEndEpoch;  //
    var iLastX = 0;
    var iLastY = 0;
    var iLastColor = 0;
    var bDraw = false;
    for(var i=iVariometerPlotRange; i>0; i--) {
      var iCurrentEpoch = $.oMyProcessing.aiPlotEpoch[iCurrentIndex];
      if(iCurrentEpoch >= 0 and iCurrentEpoch >= iStartEpoch) {
        if(iCurrentEpoch-iLastEpoch <= iMaxDeltaEpoch) {
          var iCurrentX = self.iLayoutCenter+(($.oMyProcessing.aiPlotLongitude[iCurrentIndex]-iEndLongitude)*fZoomX).toNumber();
          var iCurrentY = self.iLayoutCenter-(($.oMyProcessing.aiPlotLatitude[iCurrentIndex]-iEndLatitude)*fZoomY).toNumber();
          var iCurrentVariometer = $.oMyProcessing.aiPlotVariometer[iCurrentIndex];
          if(bDraw) {
            var iCurrentColor;
            if(iCurrentVariometer > self.aiScale[7]) {
              iCurrentColor = 0xAAFFAA;
            }
            else if(iCurrentVariometer > self.aiScale[6]) {
              iCurrentColor = 0x00FF00;
            }
            else if(iCurrentVariometer > self.aiScale[5]) {
              iCurrentColor = 0x00AA00;
            }
            else if(iCurrentVariometer > self.aiScale[4]) {
              iCurrentColor = 0x55AA55;
            }
            else if(iCurrentVariometer < self.aiScale[0]) {
              iCurrentColor = 0xFFAAAA;
            }
            else if(iCurrentVariometer < self.aiScale[1]) {
              iCurrentColor = 0xFF0000;
            }
            else if(iCurrentVariometer < self.aiScale[2]) {
              iCurrentColor = 0xAA0000;
            }
            else if(iCurrentVariometer < self.aiScale[3]) {
              iCurrentColor = 0xAA5555;
            }
            else {
              iCurrentColor = 0xAAAAAA;
            }
            if(iCurrentX != iLastX or iCurrentY != iLastY or iCurrentColor != iLastColor) {  // ... better a few comparison than drawLine() for nothing
              _oDC.setColor(iCurrentColor, Gfx.COLOR_TRANSPARENT);
              _oDC.drawLine(iLastX, iLastY, iCurrentX, iCurrentY);
              if(i == 1) {
                _oDC.fillCircle(iCurrentX, iCurrentY, self.iDotRadius);
              }
            }
            iLastColor = iCurrentColor;
          }
          else {
            iLastColor = -1;
          }
          iLastX = iCurrentX;
          iLastY = iCurrentY;
          bDraw = true;
        }
        else {
          bDraw = false;
        }
        iLastEpoch = iCurrentEpoch;
      }
      else {
        bDraw = false;
      }
      iCurrentIndex = (iCurrentIndex+1) % $.oMyProcessing.PLOTBUFFER_SIZE;
    }
    if($.oMyProcessing.iCenterLongitude != 0 && $.oMyProcessing.iCenterLatitude != 0 && $.oMyProcessing.iStandardDev != 0) {
      var myX = self.iLayoutCenter +(($.oMyProcessing.iCenterLongitude-iEndLongitude)*fZoomX).toNumber();
      var myY = self.iLayoutCenter -(($.oMyProcessing.iCenterLatitude-iEndLatitude)*fZoomY).toNumber();
      _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
      _oDC.drawCircle(myX, myY, ($.oMyProcessing.iStandardDev*fZoomY).toNumber());
    }
    //Sys.println(format("DEBUG: centerX, centerY, iEndLongitude, iEndLatitude = $1$, $2$, $3$, $4$", [$.oMyProcessing.iCenterLongitude, $.oMyProcessing.iCenterLatitude, iEndLongitude, iEndLatitude]));
    _oDC.clearClip();
  }

  function drawValues(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.drawValues()");

    // Draw values
    
    var fValue;
    var sValue;
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

    // ... altitude
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and LangUtils.notNaN($.oMyProcessing.fAltitude)) {
      fValue = $.oMyProcessing.fAltitude * $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYtop, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_LEFT);

    // ... variometer
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and LangUtils.notNaN($.oMyProcessing.fVariometer)) {
      fValue = $.oMyProcessing.fVariometer_filtered * $.oMySettings.fUnitVerticalSpeedCoefficient;
      if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
      }
      else {
        sValue = fValue.format("%+.0f");
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutValueXright, self.iLayoutValueYtop, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitVerticalSpeed]), Gfx.TEXT_JUSTIFY_RIGHT);

    // ... wind dir
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and LangUtils.notNaN($.oMyProcessing.iWindDirection)) {
      fValue = $.oMyProcessing.iWindDirection;
      if($.oMyProcessing.bWindValid) {
        if($.oMySettings.iUnitDirection == 1) {
          sValue = $.oMyProcessing.convertDirection(fValue);
        } else {
          sValue = fValue.format("%d");
        }
      }
      else {
      sValue = $.MY_NOVALUE_LEN3;
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);

    _oDC.drawText(5, self.iLayoutValueYcenter - 15, self.oRezFontPlotS as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_LEFT);

    // ... wind speed
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and LangUtils.notNaN($.oMyProcessing.fWindSpeed)) {
      fValue = $.oMyProcessing.fWindSpeed;
      if($.oMyProcessing.bWindValid) {
        fValue *= $.oMySettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(5, self.iLayoutValueYcenter, self.oRezFontPlotS as Ui.FontResource, (sValue.equals($.MY_NOVALUE_LEN3)?"W":"Wind"), Gfx.TEXT_JUSTIFY_LEFT);
    _oDC.drawText(5, self.iLayoutValueYcenter + 15, self.oRezFontPlotS as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_LEFT);
    _oDC.drawText(5, self.iLayoutValueYcenter + 15*2, self.oRezFontPlotS as Ui.FontResource, (sValue.equals($.MY_NOVALUE_LEN3)?"":$.oMySettings.sUnitHorizontalSpeed), Gfx.TEXT_JUSTIFY_LEFT);

    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    // ... ground speed
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and LangUtils.notNaN($.oMyProcessing.fGroundSpeed)) {
      fValue = $.oMyProcessing.fGroundSpeed * $.oMySettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYbottom, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitHorizontalSpeed]), Gfx.TEXT_JUSTIFY_LEFT);

    // ... finesse
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and !$.oMyProcessing.bAscent and LangUtils.notNaN($.oMyProcessing.fFinesse)) {
      fValue = $.oMyProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN2;
    }
    _oDC.drawText(self.iLayoutValueXright, self.iLayoutValueYbottom, self.oRezFontPlot as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_RIGHT);
  
    // ... cardinal points
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYtop, self.oRezFontPlotS as Ui.FontResource, "N", Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.drawText(self.iLayoutValueXright*1.14, self.iLayoutValueYcenter, self.oRezFontPlotS as Ui.FontResource, "E", Gfx.TEXT_JUSTIFY_LEFT);
    _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYbottom*1.03, self.oRezFontPlotS as Ui.FontResource, "S", Gfx.TEXT_JUSTIFY_CENTER);
  
  
  }

  function onHide() {
    MyViewHeader.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();

    $.iMyViewVarioplotPanZoom = 0;
    // Free resources
    // ... buttons
    self.oRezButtonKeyUp = null;
    self.oRezButtonKeyDown = null;
  }

}

class MyViewVarioplotDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  // function onMenu() {
  //   //Sys.println("DEBUG: MyViewVarioplotDelegate.onMenu()");
  //   Ui.pushView(new MyMenuGeneric(:menuSettings),
  //               new MyMenuGenericDelegate(:menuSettings),
  //               Ui.SLIDE_IMMEDIATE);
  //   return true;
  // }
  function onMenu() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onMenu()");
    if($.iMyViewVarioplotPanZoom) {
      $.iMyViewVarioplotPanZoom = 0;  // ... cancel pan/zoom
      Ui.pushView(new MyMenuGeneric(:menuSettings),
                  new MyMenuGenericDelegate(:menuSettings),
                  Ui.SLIDE_IMMEDIATE);
    }
    else {
      $.iMyViewVarioplotPanZoom = 1;  // ... enter pan/zoom
      Ui.requestUpdate();
    }
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onSelect()");
    if($.oMyActivity == null) {
      Ui.pushView(new MyMenuGenericConfirm(:contextActivity, :actionStart),
                  new MyMenuGenericConfirmDelegate(:contextActivity, :actionStart, false),
                  Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new MyMenuGeneric(:menuActivity),
                  new MyMenuGenericDelegate(:menuActivity),
                  Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onBack()");
    if($.iMyViewVarioplotPanZoom) {
      $.iMyViewVarioplotPanZoom = 0;  // ... cancel pan/zoom
      Ui.requestUpdate();
      return true;
    }
    else if($.oMyActivity != null) {
      return true;
    }
    return false;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onPreviousPage()");
    if($.iMyViewVarioplotPanZoom == 0) {
      Ui.switchToView(new MyViewVariometer(),
                      new MyViewVariometerDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    else if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom in
      $.oMySettings.setVariometerPlotZoom($.oMySettings.iVariometerPlotZoom+1);
      App.Properties.setValue("userVariometerPlotZoom", $.oMySettings.iVariometerPlotZoom);
      Ui.requestUpdate();
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onNextPage()");
    if($.iMyViewVarioplotPanZoom == 0) {
        Ui.switchToView(new MyViewGeneralOx(),
                        new MyViewGeneralOxDelegate(),
                        Ui.SLIDE_IMMEDIATE);
    }
    else if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom out
      $.oMySettings.setVariometerPlotZoom($.oMySettings.iVariometerPlotZoom-1);
      App.Properties.setValue("userVariometerPlotZoom", $.oMySettings.iVariometerPlotZoom);
      Ui.requestUpdate();
    }
    $.tLastTimer = Time.now();  // view ET timer
    return true;
  }

}