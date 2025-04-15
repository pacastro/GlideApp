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
import Toybox.Weather;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewInfo extends MyViewHeader {

  //
  // VARIABLES
  //
  var fLat as Float?;
  var fLon as Float?;
  var oValue = null;
  var aData as ANumbers? = [0];

  var oChartModelTemp as MyChartModel?;

  // Resources
  // ... fonts
  private var iFontPlotHeight as Number = 0;

  // Layout-specific
  private var iLayoutCenter as Number = (Sys.getDeviceSettings().screenWidth * 0.5).toNumber();
  private var iLayoutClipW as Number = Sys.getDeviceSettings().screenWidth;
  private var iLayoutValueXleft as Number = (Sys.getDeviceSettings().screenWidth * 0.165).toNumber();
  private var iLayoutValueYtop as Number = (Sys.getDeviceSettings().screenHeight * 0.125).toNumber();
  private var iLayoutValueYbottom as Number = Sys.getDeviceSettings().screenHeight - iLayoutValueYtop;
  private var iDotRadius as Number = (Sys.getDeviceSettings().screenWidth * 0.03).toNumber();

  //
  // FUNCTIONS: MyViewHeader (override/implement)
  //

  function initialize() {
    $.oMyProcessing.iIsCurrent = 0;
    MyViewHeader.initialize();

  }

  function prepare() {
    //Sys.println("DEBUG: MyViewInfo.prepare()");
    MyViewHeader.prepare();

    // Load resources
    // ... fonts
    self.iFontPlotHeight = Gfx.getFontHeight(Gfx.FONT_XTINY);

    // Unmute tones
    (App.getApp() as MyApp).unmuteTones();

    // Weather
    if(Toybox has :Weather) {
      var wValue = $.oMyPositionLocation!=null ? Weather.getHourlyForecast() : null as Array<HourlyForecast>;
      if(wValue!=null) {
        aData = new [wValue.size() + 1];
        for (var i = 0; i < wValue.size(); i++) {
          aData[i+1] = wValue[i].temperature;
        }
        oValue = $.oMyPositionLocation!=null?Weather.getCurrentConditions():null;
        if(oValue!=null) {
          aData[0] = oValue.temperature;
        }
      }
    }
    oChartModelTemp = new MyChartModel(aData);

    // for (var i = 0; i < oChartModelTemp.get_values().size(); i++) {
    // Sys.println(i + "> " + oChartModelTemp.get_values()[i]);
    // }
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    // Update layout
    MyViewHeader.updateLayout(false);
    View.onUpdate(_oDC);
    self.drawChart(_oDC);
    self.drawValues(_oDC);

  }

  function drawValues(_oDC as Gfx.Dc) as Void {
    // Sys.println("DEBUG: MyViewInfo.drawValues()");

    var deltaT = 1800; // default 30 min in seconds

    if($.oMyPositionLocation!=null) {
      fLat = $.oMyPositionLocation.toDegrees()[0].toFloat();
      fLon = $.oMyPositionLocation.toDegrees()[1].toFloat();
    }
    else {
      fLat = null;
      fLon = null;
    }
    // Draw values
    var fValue;
    var sValue = "";
    var sValue2 = "";
    var fdeltaY = 0.5;

    _oDC.setPenWidth(1);
    _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);

    // ... position Lat
    if(LangUtils.notNaN(fLat)) {
      fValue = fLat;
      sValue = (fValue >= 0 ? "N" : "S") + fValue.abs().format("%.5f");
    }
    else {
      fValue = 0;
      sValue = $.MY_NOVALUE_LEN6;
    }
    _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYtop, Gfx.FONT_XTINY, Lang.format("Lat  : $1$°", [sValue]), Gfx.TEXT_JUSTIFY_CENTER);

    // ... position Lon
    if(LangUtils.notNaN(fLon)) {
      fValue = fLon;
      sValue = (fValue >= 0 ? "E" : "W") + fValue.abs().format("%.5f");
    }
    else {
      fValue = 0;
      sValue = $.MY_NOVALUE_LEN6;
    }
    _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYtop + iFontPlotHeight, Gfx.FONT_XTINY, Lang.format("Lon : $1$°", [sValue]), Gfx.TEXT_JUSTIFY_CENTER);

    // ... sunrise
    sValue = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    if((Toybox has :Weather) && (Weather has :getSunrise)) { oValue = $.oMyPositionLocation!=null?Weather.getSunrise($.oMyPositionLocation, Time.now()):null; }
    else { oValue = $.oMyPositionLocation!=null? (new Time.Moment((self.twiLight(sValue, fLat, fLon, :sunrise) * 60 * 60))) : null; }
    if(LangUtils.notNaN(oValue)) {
      sValue = Gregorian.info(oValue, Time.FORMAT_SHORT);
      deltaT = fLat.abs() > 60 ? (self.twiLight(sValue, 60, fLon, :tl) * 60) : (self.twiLight(sValue, fLat, fLon, :tl) * 60);
      sValue2 = Gregorian.info(oValue.subtract(new Time.Duration(deltaT)), Time.FORMAT_SHORT);
    }
    else {
      sValue = $.MY_NOVALUE_LEN2;
    }
    _oDC.drawText(self.iLayoutCenter*0.5, self.iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY), Gfx.FONT_XTINY, 
                  Lang.format("$1$$2$$3$  ", [oValue==null?sValue:sValue.hour.format("%02d"), ":", 
                                              oValue==null?sValue:sValue.min.format("%02d")
                                              ]), Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.drawText(self.iLayoutCenter*0.5, self.iLayoutValueYtop + iFontPlotHeight*(4-fdeltaY), Gfx.FONT_XTINY, 
                  Lang.format("$1$$2$$3$  ", [oValue==null?sValue:sValue2.hour.format("%02d"), ":", 
                                              oValue==null?sValue:sValue2.min.format("%02d")
                                              ]), Gfx.TEXT_JUSTIFY_CENTER);

    // ... sunset
    sValue = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    if((Toybox has :Weather) && (Weather has :getSunrise)) { oValue = $.oMyPositionLocation!=null?Weather.getSunset($.oMyPositionLocation, Time.now()):null; }
    else { oValue = $.oMyPositionLocation!=null? (new Time.Moment((self.twiLight(sValue, fLat, fLon, :sunset) * 60 * 60))) : null; }
    if(LangUtils.notNaN(oValue)) {
      sValue = Gregorian.info(oValue, Time.FORMAT_SHORT);
      sValue2 = Gregorian.info(oValue.add(new Time.Duration(deltaT)), Time.FORMAT_SHORT);
    }
    else {
      sValue = $.MY_NOVALUE_LEN2;
    }
    _oDC.drawText(self.iLayoutCenter*1.5, self.iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY), Gfx.FONT_XTINY, 
                  Lang.format("  $1$$2$$3$", [oValue==null?sValue:sValue.hour.format("%02d"), ":", 
                                              oValue==null?sValue:sValue.min.format("%02d")
                                              ]), Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.drawText(self.iLayoutCenter*1.5, self.iLayoutValueYtop + iFontPlotHeight*(4-fdeltaY), Gfx.FONT_XTINY, 
                  Lang.format("  $1$$2$$3$", [oValue==null?sValue:sValue2.hour.format("%02d"), ":", 
                                              oValue==null?sValue:sValue2.min.format("%02d")
                                              ]), Gfx.TEXT_JUSTIFY_CENTER);

    _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
    // ... time
    oValue = Time.now();
    sValue = Gregorian.info(oValue, Time.FORMAT_SHORT);
    sValue2 = Gregorian.utcInfo(oValue, Time.FORMAT_SHORT);
    _oDC.drawText(self.iLayoutCenter*0.5, self.iLayoutValueYtop + iFontPlotHeight*(5-fdeltaY), Gfx.FONT_XTINY, 
                  Lang.format("$1$$2$$3$  ", [sValue.hour.format("%02d"), ":", 
                                              sValue.min.format("%02d")
                                              ]), Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.drawText(self.iLayoutCenter*1.5, self.iLayoutValueYtop + iFontPlotHeight*(5-fdeltaY), Gfx.FONT_XTINY, 
                  Lang.format("  $1$$2$$3$", [sValue2.hour.format("%02d"), ":", 
                                              sValue2.min.format("%02d")
                                              ]), Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.drawLine(self.iLayoutCenter*0.5, self.iLayoutValueYtop + iFontPlotHeight*(5-fdeltaY), self.iLayoutCenter*1.5, self.iLayoutValueYtop + iFontPlotHeight*(5-fdeltaY));

    // ... footer
    var oTimer = oValue;
    if($.oMyActivity != null) {
      oTimer = new Time.Moment(oValue.subtract(($.oMyActivity).oTimeStart).value());
    } else {
      oTimer = new Time.Moment(oValue.subtract(oTimer).value());
    }
    (self.oRezValueFooter as Ui.Text).setColor(self.iColorText);
    (self.oRezValueFooter as Ui.Text).setText(format("$1$:$2$ $3$", [Gregorian.utcInfo(oTimer, Time.FORMAT_SHORT).hour.format("%02d"), Gregorian.utcInfo(oTimer, Time.FORMAT_SHORT).min.format("%02d"), "ET"]));

    _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);
    // Weather
    // ... current
    if(Toybox has :Weather) { 
      oValue = $.oMyPositionLocation!=null?Weather.getCurrentConditions():null;
      if(LangUtils.notNaN(oValue)) {
        fValue = oValue.condition;
        sValue = (oValue.windSpeed * $.oMySettings.fUnitWindSpeedCoefficient).format("%.0f");
        if((aData.size() == 1) || (aData[0] != oValue.temperature)) {
          self.prepare();
        }
      }
      else {
        sValue = $.MY_NOVALUE_LEN2;
      }
      _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYtop + iFontPlotHeight*6, Gfx.FONT_XTINY, 
                    Lang.format("$1$°C H$2$/L$3$  $4$$5$/$6$°", [oValue!=null?oValue.temperature.format("%.0f"):sValue, 
                                                    oValue!=null?oValue.highTemperature.format("%.0f"):sValue, 
                                                    oValue!=null?oValue.lowTemperature.format("%.0f"):sValue,
                                                    sValue,
                                                    oValue!=null?$.oMySettings.sUnitWindSpeed:"",
                                                    oValue!=null?oValue.windBearing.format("%.0f"):sValue,
                                                    ]), Gfx.TEXT_JUSTIFY_CENTER);
    }
  
    _oDC.setColor(self.iColorTextGr, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY), Gfx.FONT_XTINY, "<rise - set>", Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYtop + iFontPlotHeight*(4-fdeltaY), Gfx.FONT_XTINY, "civ twilight", Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYtop + iFontPlotHeight*(5-fdeltaY), Gfx.FONT_XTINY, "<local-utc>", Gfx.TEXT_JUSTIFY_CENTER);

    _oDC.drawLine(0, self.iLayoutValueYtop*0.8 + iFontPlotHeight*(3-fdeltaY), self.iLayoutCenter*0.8, self.iLayoutValueYtop*0.8 + iFontPlotHeight*(3-fdeltaY));
    _oDC.drawLine(self.iLayoutCenter*1.2, self.iLayoutValueYtop*0.8 + iFontPlotHeight*(3-fdeltaY), self.iLayoutClipW, self.iLayoutValueYtop*0.8 + iFontPlotHeight*(3-fdeltaY));
    
    fdeltaY = 0.5;
    var fRadiusF = 1.3;
    _oDC.setColor(0xffaa55, Gfx.COLOR_TRANSPARENT);
    _oDC.drawArc(iLayoutCenter, iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY) + iDotRadius*Math.sin(Math.toRadians(20)), iDotRadius, Gfx.ARC_COUNTER_CLOCKWISE, 20, 160);
    _oDC.drawLine(iLayoutCenter - (iDotRadius*fRadiusF).toNumber(), iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY), iLayoutCenter + (iDotRadius*fRadiusF).toNumber(), iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY));
    _oDC.drawLine(iLayoutCenter, iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY) - iDotRadius*0.92, iLayoutCenter, iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY) - (iDotRadius*fRadiusF).toNumber());
    _oDC.drawLine(iLayoutCenter - Math.round(iDotRadius*Math.cos(Math.toRadians(45))), iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY) - Math.round(iDotRadius*Math.sin(Math.toRadians(45))), iLayoutCenter - Math.round(iDotRadius*fRadiusF*Math.cos(Math.toRadians(45))), iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY) - Math.round(iDotRadius*fRadiusF*Math.sin(Math.toRadians(45))));
    _oDC.drawLine(iLayoutCenter + Math.round(iDotRadius*Math.cos(Math.toRadians(45))), iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY) - Math.round(iDotRadius*Math.sin(Math.toRadians(45))), iLayoutCenter + Math.round(iDotRadius*fRadiusF*Math.cos(Math.toRadians(45))), iLayoutValueYtop + iFontPlotHeight*(3-fdeltaY) - Math.round(iDotRadius*fRadiusF*Math.sin(Math.toRadians(45))));
  }

  function drawChart(_oDC as Gfx.Dc) as Void {
    var iX1 = iLayoutValueXleft;
    var iX2 = _oDC.getWidth() - iX1;
    var iY1 = (iLayoutValueYtop + iFontPlotHeight*(7)).toNumber();
    var iY2 = iLayoutValueYbottom;

    var range_min_size = 2;
    var coef = 1;
    var chart = new MyChart(oChartModelTemp);

    _oDC.setPenWidth(2);
    chart.draw(_oDC, [iX1, iY1, iX2, iY2], range_min_size, true, true, true, false, coef);

  }

  function twiLight(_oValue, _fLat, _fLon, _calc as Symbol) {
    // first calculate the day of the year
    var N1 = Math.floor(275 * _oValue.month / 9);
    var N2 = Math.floor((_oValue.month + 9) / 12);
    var N3 = (1 + Math.floor((_oValue.year - 4 * Math.floor(_oValue.year / 4) + 2) / 3));
    var N = N1 - (N2 * N3) + _oValue.day -30;
    // calculate the Sun's mean anomaly  
    var t = N + (((_calc == :sunset ? 18 : 6) - (_fLon / 15)) / 24);
    var M = (0.9856 * t) - 3.289;
    // calculate the Sun's true longitude
    var L = (M + (1.916 * Math.sin(Math.toRadians(M))) + (0.020 * Math.sin(2 * Math.toRadians(M))) + 282.634) ;
    L = L < 0 ? L + 360 : L > 360 ? L - 360 : L;
    var RA = Math.toDegrees(Math.atan(0.91764 * Math.tan(Math.toRadians(L))));
    RA = RA < 0 ? RA + 360 : RA > 360 ? RA - 360 : RA;
    // right ascension value needs to be converted into hours 
    RA = (RA + ((Math.floor(L / 90) * 90) - (Math.floor(RA / 90) * 90))) / 15;
    // calculate the Sun's declination
    var sinDec = 0.39782 * Math.sin(Math.toRadians(L));
    var cosDec = Math.cos(Math.asin(sinDec));
    // calculate the Sun's local hour angle for sunrise (H1) & begining civil twilight (H2)
    var cosH1 = (Math.cos(Math.toRadians(90.833)) - (sinDec * Math.sin(Math.toRadians(_fLat)))) / (cosDec * Math.cos(Math.toRadians(_fLat)));
    var cosH2 = (Math.cos(Math.toRadians(96)) - (sinDec * Math.sin(Math.toRadians(_fLat)))) / (cosDec * Math.cos(Math.toRadians(_fLat)));
    // calculate H and difference between sunrise (H1) & begining civil twilight (H2) to hours and then minutes
    if(_calc == :tl) {
      var T = Math.round((Math.toDegrees(Math.acos(cosH2)) - Math.toDegrees(Math.acos(cosH1))) / 15 * 60);
      return T.toNumber();
    } else {
      var T = (_calc == :sunrise ? (360 - Math.toDegrees(Math.acos(cosH1))) : Math.toDegrees(Math.acos(cosH1))) / 15 + RA - (0.06571 * t) - 6.622 - _fLon / 15;
      T = T < 0 ? T + 24 : T > 24 ? T - 24 : T;
      return (T);
    }
  }

  function onHide() {
    MyViewHeader.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();

  }

}

class MyViewInfoDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: MyViewInfoDelegate.onMenu()");
    Ui.pushView(new MyMenu2Generic(:menuSettings, 0),
                new MyMenu2GenericDelegate(:menuSettings),
                Ui.SLIDE_RIGHT);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewInfoDelegate.onSelect()");
    if($.oMyActivity == null) {
      Ui.pushView(new Ui.Confirmation(Ui.loadResource(Rez.Strings.titleActivityStart) + "?"),
                  new MyMenuGenericConfirmDelegate(:contextActivity, :actionStart, false),
                  Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new MyMenu2Generic(:menuActivity, 0),
                  new MyMenu2GenericDelegate(:menuActivity),
                  Ui.SLIDE_BLINK);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: MyViewInfoDelegate.onBack()");
    Ui.switchToView(new MyViewGeneral(),
                    new MyViewGeneralDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewInfoDelegate.onPreviousPage()");
    Ui.switchToView(new MyViewGeneral(),
                    new MyViewGeneralDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewInfoDelegate.onNextPage()");
    Ui.switchToView(new MyViewGeneral(),
                    new MyViewGeneralDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

}




