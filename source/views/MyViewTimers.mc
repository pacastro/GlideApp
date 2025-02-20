// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

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

class MyViewTimers extends MyViewGlobal {

  //
  // VARIABLES
  //

  // Resources (cache)
  // ... fields (units)
  public var oRezUnitTopRight as Ui.Text?;
  public var oRezUnitTopLeft as Ui.Text?;
  public var oRezUnitBottomRight as Ui.Text?;

  private var oRezLabelLeft as Ui.Text?;
  private var oRezLabelCenter as Ui.Text?;
  // ... strings
  public var sUnitElapsed as String = "elapsed";
  public var sUnitDistance_fmt as String = "distance [km]";
  public var sUnitAscent_fmt as String = "ascent [m]";

  // Internals
  // ... fields
  private var iFieldIndex as Number = 0;
  private var iFieldEpoch as Number = -1;

  // ... Chart
  var range_min_size = 30;
  var coef = 1;
  //
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    //Populate last view
    $.oMyProcessing.bIsPrevious = 5;
    MyViewGlobal.initialize();

    // Internals
    // ... fields
    self.iFieldEpoch = Time.now().value();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewGlobal.prepare()");
    MyViewGlobal.prepare();

    // Load resources
    // ... fields (units)
    self.oRezUnitTopRight = View.findDrawableById("unitTopRight") as Ui.Text;
    self.oRezUnitTopLeft = View.findDrawableById("unitTopLeft") as Ui.Text;
    self.oRezUnitBottomRight = View.findDrawableById("unitBottomRight") as Ui.Text;

    self.oRezLabelLeft = View.findDrawableById("labelLeft") as Ui.Text;
    self.oRezLabelCenter = View.findDrawableById("labelCenter") as Ui.Text;
    // ... strings
    self.sUnitElapsed = (Ui.loadResource(Rez.Strings.labelElapsed) as String).toLower();
    self.sUnitDistance_fmt = Lang.format("$1$ [$2$]", [(Ui.loadResource(Rez.Strings.labelDistance) as String).toLower(), $.oMySettings.sUnitDistance]);
    self.sUnitAscent_fmt = Lang.format("$1$ [$2$]", [(Ui.loadResource(Rez.Strings.labelAscent) as String).toLower(), $.oMySettings.sUnitElevation]);

     // Set colors (value-independent), labels and units
    // ... activity: Distance
    (View.findDrawableById("labelTopLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelDistance) as String);
    (View.findDrawableById("unitTopLeft") as Ui.Text).setText(Lang.format("[$1$]",[$.oMySettings.sUnitDistance]));
    // ... activity: Ascent
    (View.findDrawableById("labelTopRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelAscent) as String);
    (View.findDrawableById("unitTopRight") as Ui.Text).setText(Lang.format("[$1$]",[$.oMySettings.sUnitElevation]));

    // ... Center
    if(!$.oMySettings.bGeneralChartDisplay) {
    // ... acceleration g
    (View.findDrawableById("labelCenter") as Ui.Text).setText(("Accel g").toLower());
    // ... rate of turn
    // (View.findDrawableById("labelCenter") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitRateOfTurn]));
    // // ... lap: elapsed/distance/ascent (dynamic)
    // (self.oRezUnitRight as Ui.Text).setText(self.sUnitElapsed);
    }

    // ... recording: start
    (View.findDrawableById("labelBottomLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelRecording) as String);
    (View.findDrawableById("unitBottomLeft") as Ui.Text).setText((Ui.loadResource(Rez.Strings.labelStart) as String).toLower());

    // ... recording: elapsed
    (View.findDrawableById("labelBottomRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelElapsed) as String);
    (View.findDrawableById("unitBottomRight") as Ui.Text).setText("hh:mm");

    // Unmute tones

  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.onUpdate()");

    // Update layout
    MyViewGlobal.onUpdate(_oDC);
    if($.oMySettings.bGeneralChartDisplay) { self.drawChart(_oDC); }
    self.updateLayout(true);
    
  }

  function updateLayout(_b) {
    //Sys.println("DEBUG: MyViewGlobal.updateLayout()");
    MyViewGlobal.updateLayout(true);

    // Fields
    var iEpochNow = Time.now().value();
    if(iEpochNow - self.iFieldEpoch >= 2) {
      self.iFieldIndex = (self.iFieldIndex + 1) % 3;
      self.iFieldEpoch = iEpochNow;
    }

    // Colors
    if($.oMyProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE or $.oMyProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(($.oMyProcessing.iAccuracy==Pos.QUALITY_LAST_KNOWN)?Gfx.COLOR_YELLOW:self.iColorBG);
      self.iColorText = self.iColorTextGr;
    }
    else {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    }

    // Set values
    var oTimeNow = Time.now();
    var bRecording = ($.oMyActivity != null)?($.oMyActivity.isRecording()):false;
    var fValue;
    var sValue;

    // ... distance
    (self.oRezValueTopLeft as Ui.Text).setColor(bRecording ? self.iColorText : self.iColorTextGr);
    if($.oMyActivity != null) {
      fValue = ($.oMyActivity as MyActivity).fGlobalDistance * $.oMySettings.fUnitDistanceCoefficient;
      sValue = fValue.format("%.1f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueTopLeft as Ui.Text).setText(sValue);

    // ... ascent
    (self.oRezValueTopRight as Ui.Text).setColor(bRecording ? self.iColorText : self.iColorTextGr);
    if($.oMyActivity != null) {
      fValue = $.oMyActivity.fGlobalAscent * $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueTopRight as Ui.Text).setText(sValue);

     // ... Chart
    if($.oMySettings.bGeneralChartDisplay) {
      (self.oRezLabelLeft as Ui.Text).setText($.oMySettings.sChartDisplay);
      (self.oRezLabelCenter as Ui.Text).setText(Lang.format("[$1$]",[$.oMySettings.sChartUnitDisplay]));
    }

    // ... CENTER
    if(!$.oMySettings.bGeneralChartDisplay) {
      (self.oRezValueCenter as Ui.Text).setColor(bRecording ? self.iColorText : self.iColorTextGr);
      // // ... recording: distance
      // (self.oRezValueCenter as Ui.Text).setText(self.sUnitDistance_fmt);
      
      // ... acceleration g
      fValue = $.oMyProcessing.fAcceleration;
      if(LangUtils.notNaN(fValue) && ($.oMyActivity != null)) {
        fValue = $.oMyProcessing.fAcceleration;
        sValue = fValue.format("%.1f");
      }
    
      // ... rate of turn
      // fValue = $.oMyProcessing.fRateOfTurn.abs();
      // if(LangUtils.notNaN(fValue) and $.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      //   fValue *= $.oMySettings.fUnitRateOfTurnCoefficient;
      //   if($.oMySettings.iUnitRateOfTurn == 1) {
      //     sValue = fValue.format("%.1f");
      //   }
      //   else {
      //     sValue = fValue.format("%.0f");
      //   }
      // }

      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      (self.oRezValueCenter as Ui.Text).setText(sValue);
    }

    // ... recording: start
    (self.oRezValueBottomLeft as Ui.Text).setColor(bRecording ? self.iColorText : self.iColorTextGr);
    if($.oMyActivity != null) {
      sValue = LangUtils.formatTime(($.oMyActivity as MyActivity).oTimeStart, $.oMySettings.bUnitTimeUTC, false);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueBottomLeft as Ui.Text).setText(sValue);

    // ... recording: elapsed
    (self.oRezValueBottomRight as Ui.Text).setColor(bRecording ? self.iColorText : self.iColorTextGr);
    sValue = $.MY_NOVALUE_LEN3;
    if($.oMyActivity != null) {
      if($.oMyActivity.isRecording()) {
        sValue = LangUtils.formatElapsedTime($.oMyActivity.oTimeStart, oTimeNow.subtract($.oMyActivity.oTimePauseTot), false);
      }
      else if(($.oMyActivity.oTimeStop != null)&&($.oMyActivity.oTimePauseTot != null)) {
        sValue = LangUtils.formatElapsedTime($.oMyActivity.oTimeStart, $.oMyActivity.oTimeStop.subtract($.oMyActivity.oTimePauseTot), false);
      }
    }
    (self.oRezValueBottomRight as Ui.Text).setText(sValue);
  }

  function drawChart(_oDC as Gfx.Dc) as Void {
    var iX1 = (_oDC.getWidth()*0.018f).toNumber();
    var iX2 = _oDC.getWidth() - iX1;
    var iY1 = (_oDC.getHeight()*0.375f).toNumber();
    var iY2 = (_oDC.getHeight()*0.627f).toNumber();

    var model = oChartModelAlt;
    switch($.oMySettings.loadChartDisplay()) {
    default: 
    case 0:
      range_min_size = 30;
      coef = $.oMySettings.fUnitElevationCoefficient;
      model = oChartModelAlt;
      break;
    case 1:
      range_min_size = 10;
      coef = $.oMySettings.fUnitElevationCoefficient;
      model = oChartModelAsc;
      break;
    case 2:
      range_min_size = 0.5;
      coef = $.oMySettings.fUnitVerticalSpeedCoefficient;
      model = oChartModelCrt;
      break;
    case 3:
      range_min_size = 20;
      coef = $.oMySettings.fUnitHorizontalSpeedCoefficient;
      model = oChartModelSpd;
      break;
    case 4:
      range_min_size = 10;
      coef = 1;
      model = oChartModelHR;
      break;
    case 5:
      range_min_size = 0.5;
      coef = 1;
      model = oChartModelg;
      break;
    }

    var chart = new MyChart(model);

    _oDC.setPenWidth(1);
    chart.draw(_oDC, [iX1, iY1, iX2, iY2], range_min_size, $.oMySettings.bChartMinMax, true, true, true, coef);

    if(($.oMySettings.bChartValue)&&($.oMySettings.loadChartDisplay()!=1)) {
      _oDC.setColor(iColorTextGr, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText((iX1+iX2)/2, (iY1+iY2)/2, Gfx.FONT_TINY, fmt_num(model.get_current()), Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }
  }

  function fmt_num(num) {
      if (num == null) {
          return "- - -";
      } else {
          return "" + (num*coef).format((range_min_size<=1)?"%.1f":"%.0f");
      }
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewGlobal.onHide()");
    MyViewGlobal.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();
  }

}

class MyViewTimersDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewTimersDelegate.onPreviousPage()");
    if((Ui has :MapView)&&($.oMySettings.bGeneralMapDisplay)) {
      var mapView = new MyViewMap();
      Ui.switchToView(mapView,
                      new MyViewMapDelegate(mapView),
                      Ui.SLIDE_IMMEDIATE);
    } 
    else {
      Ui.switchToView(new MyViewVarioplot(),
                      new MyViewVarioplotDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewTimersDelegate.onNextPage()");
    if($.oMyActivity != null) { //Skip the log view if we are recording, e.g. in flight
      iViewGenOxIdx = 1;
      Ui.switchToView(new MyViewGeneral(),
                      new MyViewGeneralDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.switchToView(new MyViewLog(),
                      new MyViewLogDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

}
