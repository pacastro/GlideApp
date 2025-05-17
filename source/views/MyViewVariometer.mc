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
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Math;

class MyViewVariometer extends MyView {

  //
  // VARIABLES
  //
  // Layout-specific
  private var iLayoutCenter as Number = (Sys.getDeviceSettings().screenWidth * 0.5).toNumber();
  private var iLayoutValueR as Number = (iLayoutCenter * 0.79).toNumber();
  private var iLayoutCacheR as Number = (iLayoutCenter * 0.74).toNumber();
  private var iLayoutBatteryY as Number = (Sys.getDeviceSettings().screenHeight * 0.615).toNumber();
  private var iLayoutActivityY as Number = (Sys.getDeviceSettings().screenHeight - iLayoutBatteryY);
  private var iLayoutTimeY as Number = Math.round(Sys.getDeviceSettings().screenHeight * 0.675);
  private var iLayoutAltitudeY as Number = (Sys.getDeviceSettings().screenHeight - iLayoutTimeY);
  private var iLayoutRightX as Number = (Sys.getDeviceSettings().screenWidth * 0.883).toNumber();

  //
  // FUNCTIONS: MyView (override/implement)
  //

  function initialize() {
    //Populate last view
    $.oMyProcessing.iIsCurrent = 2;

    MyView.initialize();
  }

  function onLayout(_oDC) {
    //Sys.println("DEBUG: MyViewVariometer.onLayout()");
    // No layout; see drawLayout() below
  }

  function onShow() {
    // Sys.println("DEBUG: MyViewVariometer.onShow()");
    MyView.onShow();

    // Layer
    auxLayer = new AuxLayer(false, true, true);

    // Unmute tones
    (App.getApp() as MyApp).unmuteTones();
  }

  function onUpdate(_oDC) as Void {
    // Sys.println("DEBUG: MyViewVariometer.onUpdate()");
    MyView.onUpdate(_oDC);

    // Draw layout
    self.drawVario(_oDC);
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewVariometer.onHide()");
    MyView.onHide();
    auxLayer.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();
  }

  // FUNCTIONS: self
  //

  function drawVario(_oDC) as Void {
    // Sys.println("DEBUG: MyViewVariometer.draw()");

    if(_oDC has :setAntiAlias) { _oDC.setAntiAlias(true); }
    // Draw background
    _oDC.setPenWidth(self.iLayoutCenter);
    
    // ... background
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor, $.oMySettings.iGeneralBackgroundColor);
    _oDC.clear();

    // ... variometer
    var sValue;
    var bUnitm = $.oMySettings.fUnitVerticalSpeedCoefficient == 1 ? true : false;
    _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);
    _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutCacheR, Gfx.ARC_COUNTER_CLOCKWISE, 40, 320);
    _oDC.setPenWidth(2);
    _oDC.setColor(self.iColorTextGr, Gfx.COLOR_TRANSPARENT);
    _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_COUNTER_CLOCKWISE, 40, 320);

    var delta = 135/(bUnitm ? ($.oMySettings.fVariometerRange < 10 ? $.oMySettings.fVariometerRange : 5) : 5);
    for(var i = 135; i >= -135; i -= delta) {
      sValue = ((i / delta).abs() * ($.oMySettings.fVariometerRange < 10 ? 1 : 2) * (bUnitm ? 1 : ($.oMySettings.fUnitVerticalSpeedCoefficient / ($.oMySettings.fVariometerRange < 5 ? 200 : 100)))).format("%.0f");
      _oDC.setPenWidth(3);
      _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
      _oDC.drawLine(self.iLayoutCenter - Math.round(iLayoutCenter*Math.cos(Math.toRadians(i))), self.iLayoutCenter - Math.round(iLayoutCenter*Math.sin(Math.toRadians(i))), 
                    self.iLayoutCenter - Math.round(((4*self.iLayoutCenter + self.iLayoutCacheR) / 5)*Math.cos(Math.toRadians(i))), self.iLayoutCenter - Math.round(((4*self.iLayoutCenter + self.iLayoutCacheR) / 5)*Math.sin(Math.toRadians(i))));
      _oDC.drawText(self.iLayoutCenter - Math.round(((self.iLayoutCenter + self.iLayoutCacheR) / 2)*Math.cos(Math.toRadians(i))), self.iLayoutCenter - Math.round(((self.iLayoutCenter + self.iLayoutCacheR) / 2)*Math.sin(Math.toRadians(i))), 
                    Gfx.FONT_XTINY, sValue, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
      if(i > -135) {
        _oDC.setPenWidth(2);
        _oDC.setColor(self.iColorTextGr, Gfx.COLOR_TRANSPARENT);
        _oDC.drawLine(self.iLayoutCenter - Math.round(iLayoutCenter*Math.cos(Math.toRadians(i-(delta/2)))), self.iLayoutCenter - Math.round(iLayoutCenter*Math.sin(Math.toRadians(i-(delta/2)))), 
                      self.iLayoutCenter - Math.round(((7*self.iLayoutCenter + self.iLayoutCacheR) / 8)*Math.cos(Math.toRadians(i-(delta/2)))), self.iLayoutCenter - Math.round(((7*self.iLayoutCenter + self.iLayoutCacheR) / 8)*Math.sin(Math.toRadians(i-(delta/2)))));
      }
    }

    // ...  Min Max g load
    if(chartRun(5)) {
      var iAngleMax = Math.round(135.0f * oChartModelg.get_max() * (bUnitm ? 1/$.oMySettings.fVariometerRange : 1/($.oMySettings.fVariometerRange == 3.0f ? 5.0f : [3.0f, 5.0f, 10.0f].indexOf($.oMySettings.fVariometerRange)*10.0f)));
      var iAngleMin = Math.round(135.0f * oChartModelg.get_min() * (bUnitm ? 1/$.oMySettings.fVariometerRange : 1/($.oMySettings.fVariometerRange == 3.0f ? 5.0f : [3.0f, 5.0f, 10.0f].indexOf($.oMySettings.fVariometerRange)*10.0f)));
      if(iAngleMax > 140) { iAngleMax = 140; }
      if(iAngleMin < -140) { iAngleMin = -140; }
      _oDC.setPenWidth(self.iLayoutValueR - self.iLayoutCacheR);
      _oDC.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
      _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, (self.iLayoutValueR + self.iLayoutCacheR) / 2, Gfx.ARC_CLOCKWISE, 181-iAngleMin, 180-iAngleMax);
    }
    
    // ... g diamond
    var fValue = $.oMyProcessing.fAcceleration;
    var iAngle;
    if(LangUtils.notNaN(fValue)) {
      iAngle = Math.round(135.0f * fValue * (bUnitm ? 1/$.oMySettings.fVariometerRange : 1/($.oMySettings.fVariometerRange == 3.0f ? 5.0f : [3.0f, 5.0f, 10.0f].indexOf($.oMySettings.fVariometerRange)*10.0f)));
      if(iAngle.abs() > 140) { iAngle = 140 * iAngle / iAngle.abs(); } 
      var iRadius = ((5*self.iLayoutCenter + self.iLayoutCacheR) / 6);
      var aDiamond = [
        [self.iLayoutCenter - self.iLayoutCenter * Math.cos(Math.toRadians(iAngle)), self.iLayoutCenter - self.iLayoutCenter * Math.sin(Math.toRadians(iAngle))],
        [self.iLayoutCenter - iRadius * Math.cos(Math.toRadians(iAngle - 2)), self.iLayoutCenter - iRadius * Math.sin(Math.toRadians(iAngle - 2))],
        [self.iLayoutCenter - ((2*self.iLayoutCenter + self.iLayoutCacheR) / 3) * Math.cos(Math.toRadians(iAngle)), self.iLayoutCenter - ((2*self.iLayoutCenter + self.iLayoutCacheR) / 3) * Math.sin(Math.toRadians(iAngle))],
        [self.iLayoutCenter - iRadius * Math.cos(Math.toRadians(iAngle + 2)), self.iLayoutCenter - iRadius * Math.sin(Math.toRadians(iAngle + 2))]
      ];
      _oDC.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
      _oDC.fillPolygon(aDiamond);
    }

    // ... dE indicator
    if($.oMySettings.bVariometerdE) {
      fValue = $.oMyProcessing.fVariometerdE;
      if(LangUtils.notNaN(fValue)) {
        _oDC.setPenWidth(self.iLayoutCenter*0.95 - self.iLayoutValueR);
        iAngle = Math.round(135.0f * fValue * (bUnitm ? 1/$.oMySettings.fVariometerRange : $.oMySettings.fUnitVerticalSpeedCoefficient/(100 * ($.oMySettings.fVariometerRange == 3.0f ? 5 : [3.0f, 5.0f, 10.0f].indexOf($.oMySettings.fVariometerRange)*10))));
        if(iAngle != 0) {
          if(iAngle.abs() > 140) { iAngle = 140 * iAngle / iAngle.abs(); }  // ... leave room for unit text
          _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
          _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, (self.iLayoutCenter*0.95 + self.iLayoutValueR) / 2, Gfx.ARC_CLOCKWISE, 181.5-iAngle, 178.5-iAngle);
        }
      }
    }

    // ... Last thermal avg 
    // Sys.println($.oMyProcessing.fVarioLastThAvg);
    fValue = $.oMySettings.bVariometerAvgLast ? $.oMyProcessing.fVarioLastThAvg : $.oMyProcessing.aVariometer_history;
    if(LangUtils.notNaN(fValue) && ($.oMyProcessing.aVariometer_history.size() > 0)) {
      iAngle = Math.round(135.0f * ($.oMySettings.bVariometerAvgLast ? fValue : Math.mean(fValue)) * (bUnitm ? 1/$.oMySettings.fVariometerRange : $.oMySettings.fUnitVerticalSpeedCoefficient/(100 * ($.oMySettings.fVariometerRange == 3.0f ? 5 : [3.0f, 5.0f, 10.0f].indexOf($.oMySettings.fVariometerRange)*10))));
      if(iAngle.abs() > 140) { iAngle = 140 * iAngle / iAngle.abs(); }  // ... leave room for unit text
      _oDC.setPenWidth(5);
      _oDC.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
      _oDC.drawLine(self.iLayoutCenter - Math.round(iLayoutCenter*Math.cos(Math.toRadians(iAngle))), self.iLayoutCenter - Math.round(iLayoutCenter*Math.sin(Math.toRadians(iAngle))), 
                    self.iLayoutCenter - Math.round(((3*self.iLayoutCenter + self.iLayoutCacheR) / 4)*Math.cos(Math.toRadians(iAngle))), self.iLayoutCenter - Math.round(((3*self.iLayoutCenter + self.iLayoutCacheR) / 4)*Math.sin(Math.toRadians(iAngle))));
      _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutCenter, Gfx.ARC_CLOCKWISE, 183-iAngle, 177-iAngle);
    }

    // ... Vert Speed indicator
    _oDC.setPenWidth(self.iLayoutCenter - self.iLayoutValueR);
    fValue = $.oMyProcessing.fVariometer_filtered;
    if(LangUtils.notNaN(fValue)) {
      iAngle = Math.round(135.0f * fValue * (bUnitm ? 1/$.oMySettings.fVariometerRange : $.oMySettings.fUnitVerticalSpeedCoefficient/(100 * ($.oMySettings.fVariometerRange == 3.0f ? 5 : [3.0f, 5.0f, 10.0f].indexOf($.oMySettings.fVariometerRange)*10))));
      if(iAngle.abs() > 140) { iAngle = 140 * iAngle / iAngle.abs(); }  // ... leave room for unit text
      _oDC.setColor(iAngle > 0 ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, (self.iLayoutCenter + self.iLayoutValueR) / 2, Gfx.ARC_CLOCKWISE, 181.5-iAngle, 178.5-iAngle);
    }

    // ... cache
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor, $.oMySettings.iGeneralBackgroundColor);
    _oDC.fillCircle(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutCacheR);

    // Draw non-position values

    // ... battery
    _oDC.setColor(self.iColorTextGr, Gfx.COLOR_TRANSPARENT);
    sValue = Lang.format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]);
    _oDC.drawText(self.iLayoutRightX, self.iLayoutBatteryY, Gfx.FONT_XTINY, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... activity
    if($.oMyActivity == null) {  // ... stand-by
      sValue = self.sValueActivityStandby;
    }
    else if(($.oMyActivity as MyActivity).isRecording()) {  // ... recording
      _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityRecording;
    }
    else {  // ... paused
      _oDC.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityPaused;
    }
     _oDC.drawText(self.iLayoutRightX, self.iLayoutActivityY - Gfx.getFontHeight(Gfx.FONT_XTINY), Gfx.FONT_XTINY, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... time
    var oTimeNow = Time.now();
    var oTimeInfo = $.oMySettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    sValue = Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.oMySettings.sUnitTime]);
    _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutCenter, self.iLayoutTimeY, Gfx.FONT_MEDIUM, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // Draw position values

    // ... altitude
    fValue = $.oMyProcessing.fAltitude;
    if(LangUtils.notNaN(fValue)) {
      fValue *= $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
     _oDC.drawText(self.iLayoutCenter, self.iLayoutAltitudeY - Gfx.getFontHeight(Gfx.FONT_MEDIUM), Gfx.FONT_MEDIUM, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_CENTER);

    // ... variometer
    fValue = $.oMyProcessing.fVariometer_filtered;
    if(LangUtils.notNaN(fValue)) {
      fValue *= $.oMySettings.fUnitVerticalSpeedCoefficient;
      if(($.oMyProcessing.aVariometer_history.size() > 0) && ($.oMySettings.fVariometerAvgTime != 0)) {
        fValue = Math.mean($.oMyProcessing.aVariometer_history) * $.oMySettings.fUnitVerticalSpeedCoefficient;
      }
      sValue = (bUnitm ? fValue : (fValue / 100)).format("%+.1f");
      if(fValue <= -0.05f or fValue >= 0.05f) {
        _oDC.setColor(fValue > 0 ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutCenter, self.iLayoutCenter, Gfx.FONT_NUMBER_MILD, sValue, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    _oDC.setColor(self.iColorTextGr, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutCenter, self.iLayoutCenter - Gfx.getFontHeight(Gfx.FONT_XTINY)*2, Gfx.FONT_XTINY, $.oMySettings.fVariometerAvgTime == 0 ? "current" : "avg " + $.oMySettings.fVariometerAvgTime + "s", Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.drawText(self.iLayoutCenter * 2, self.iLayoutCenter, Gfx.FONT_TINY, (bUnitm ? "" : "¹ºº") + $.oMySettings.sUnitVerticalSpeed, Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER);

    // ... speed
    fValue = $.oMyProcessing.fGroundSpeed;
    if(LangUtils.notNaN(fValue)) {
      fValue *= $.oMySettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
     _oDC.drawText(self.iLayoutCenter, self.iLayoutCenter + Gfx.getFontHeight(Gfx.FONT_XTINY), Gfx.FONT_XTINY, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitHorizontalSpeed]), Gfx.TEXT_JUSTIFY_CENTER);
  
    if (($.oMyActivity == null) && ($.oMyProcessing.iAccuracy > Position.QUALITY_LAST_KNOWN)) {
      _oDC.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
      _oDC.setPenWidth(_oDC.getWidth() * 0.018f);
      _oDC.drawArc(iLayoutCenter, iLayoutCenter, (iLayoutCenter*0.965).toNumber(), Gfx.ARC_COUNTER_CLOCKWISE, 20, 40);
    }

    // ... SpO2 Status
    if ($.oMySettings.bGeneralOxDisplay && ($.oMySettings.bOxMeasure?(LangUtils.notNaN($.oMyProcessing.fAltitude) ? ($.oMyProcessing.fAltitude >= $.oMySettings.iOxElevation):false): true)) {
      _oDC.setColor($.oMyProcessing.iColorOxStatus, Gfx.COLOR_TRANSPARENT);
      _oDC.fillRectangle((Sys.getDeviceSettings().screenWidth * 0.85).toNumber(), (Sys.getDeviceSettings().screenWidth * 0.395).toNumber(), 
                        (Sys.getDeviceSettings().screenWidth * 0.0577).toNumber(), (Sys.getDeviceSettings().screenWidth * 0.0231).toNumber());
    }
  }
}

class MyViewVariometerDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onBack() {
    //Sys.println("DEBUG: MyViewHeaderDelegate.onBack()");
    if($.oMyActivity == null) {
      return false;
    } else {
      var iRangeIdx = $.oMySettings.loadVariometerRange();
      iRangeIdx = (iRangeIdx+1) % 3;
      $.oMySettings.saveVariometerRange(iRangeIdx as Number);
      $.oMySettings.setVariometerRange(iRangeIdx as Number);
      Ui.requestUpdate();
    } 
    return true;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewVariometerDelegate.onPreviousPage()");
    iViewGenOxIdx = 0;
    Ui.switchToView(new MyViewGeneral(),
                    new MyViewGeneralDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewVariometerDelegate.onNextPage()");
    Ui.switchToView(new MyViewVarioplot(),
                    new MyViewVarioplotDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
