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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

using Toybox.Time;
using Toybox.Time.Gregorian;

class MyViewGeneral extends MyViewGlobal {
  //
  // VARIABLES
  //

  //strings
  // private var sUnitElapsed as String = "elapsed";

  //
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    //Populate last view
    $.oMyProcessing.bIsPrevious = 1;
    MyViewGlobal.initialize();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewGeneral.prepare()");
    MyViewGlobal.prepare();

    // Set colors (value-independent), labels and units
    if((($.oMySettings.bGeneralOxDisplay?1:0) * $.iViewGenOxIdx) < 1) {
      // ... Wind Dir
      (View.findDrawableById("labelTopLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelWindDirection) as String);
      if($.oMySettings.iUnitDirection==0) {
        (View.findDrawableById("unitTopLeft") as Ui.Text).setText("[°]");
      }
      // ... Wind Speed
      (View.findDrawableById("labelTopRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelWindSpeed) as String);
      (View.findDrawableById("unitTopRight") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitWindSpeed]));
    } else {
      // ... Heart Rate
      (View.findDrawableById("labelTopLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelHeartRate) as String);
      // ... Oxygen Saturation
      (View.findDrawableById("labelTopRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelSpO2) as String);
    }
    // ... altitude
    (View.findDrawableById("labelLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelAltitude) as String);
    (View.findDrawableById("unitLeft") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... finesse
    (View.findDrawableById("labelCenter") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelFinesse) as String);
    // ... heading
    (View.findDrawableById("labelRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelHeading) as String);
    if($.oMySettings.iUnitHeading==0) {
      (View.findDrawableById("unitRight") as Ui.Text).setText("[°]");
    }
    // ... vertical speed
    (View.findDrawableById("labelBottomLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelVerticalSpeed) as String);
    (View.findDrawableById("unitBottomLeft") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitVerticalSpeed]));
    // ... ground speed
    (View.findDrawableById("labelBottomRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelGroundSpeed) as String);
    (View.findDrawableById("unitBottomRight") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitHorizontalSpeed]));

    // Unmute tones
     (App.getApp() as MyApp).unmuteTones();
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.onUpdate()");

    // Update layout
    MyViewGlobal.onUpdate(_oDC);
    self.updateLayout(true);
    if((($.oMySettings.bGeneralOxDisplay?1:0) * $.iViewGenOxIdx) < 1) {
      self.drawArrow(_oDC);
    }
  }

  function updateLayout(_b) {  
    //Sys.println("DEBUG: MyViewGeneral.updateLayout()");
    MyViewGlobal.updateLayout(true);

    // Set values (and dependent colors)
    var fValue;
    var iValue;
    var sValue;
    var bRecording = ($.oMyActivity != null)?($.oMyActivity.isRecording()):false;

    if((($.oMySettings.bGeneralOxDisplay?1:0) * $.iViewGenOxIdx) > 0) {
      // ... Heart Rate
      (self.oRezValueTopLeft as Ui.Text).setColor(bRecording ? self.iColorText : self.iColorTextGr);
      fValue = $.oMyProcessing.iHR;
      if(LangUtils.notNaN(fValue)) {
        sValue = fValue.format("%.0f");
      } 
      else {
        (self.oRezValueTopLeft as Ui.Text).setColor(self.iColorTextGr);
        sValue = $.MY_NOVALUE_LEN3;
      }
      (self.oRezValueTopLeft as Ui.Text).setText(sValue);

      // ... SpO2
      if($.oMySettings.bOxMeasure && ($.oMyAltimeter.fAltitudeActual < $.oMySettings.iOxElevation)) {
        (self.oRezValueTopRight as Ui.Text).setColor($.oMySettings.iGeneralBackgroundColor?Gfx.COLOR_LT_GRAY:Gfx.COLOR_DK_GRAY);
        sValue = "elev";
      }
      else {
        (self.oRezValueTopRight as Ui.Text).setColor(bRecording ? self.iColorText : self.iColorTextGr);
        fValue = $.oMyProcessing.iOx;
        if(LangUtils.notNaN(fValue)) {
          sValue = fValue.format("%.0f");
          if(fValue > $.oMySettings.iOxCritical) {
            (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertOx(Gfx.COLOR_TRANSPARENT);
          }
          else {
            (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertOx(self.iColorBG);
          }
        }
        else {
          (self.oRezValueTopRight as Ui.Text).setColor(self.iColorTextGr);
          sValue = $.MY_NOVALUE_LEN3;
        }
      }
      (self.oRezValueTopRight as Ui.Text).setText(sValue);

      // ... SpO2 Age
      if($.oMySettings.bOxMeasure && ($.oMyAltimeter.fAltitudeActual < $.oMySettings.iOxElevation)) {
        (self.oRezValueTopRightB as Ui.Text).setColor(self.iColorTextGr);
        sValue = format(">$1$ $2$", [($.oMySettings.iOxElevation*$.oMySettings.fUnitElevationCoefficient).format("%.0f"), $.oMySettings.sUnitElevation]);
      }
      else {
        (self.oRezValueTopRightB as Ui.Text).setColor(Gfx.COLOR_DK_GRAY);
        if(LangUtils.notNaN($.oMyProcessing.iAgeOx)&&LangUtils.notNaN(fValue)) {
          fValue = Gregorian.utcInfo(new Time.Moment($.oMyProcessing.iAgeOx), Time.FORMAT_SHORT);
          // Sys.println("DEBUG: $.oMyProcessing.oTimeLastOx: "+fValue.day+"d"+fValue.hour+"h"+fValue.min.format("%02d")+"m");
          sValue = "Age: "+(fValue.month>1?">30 days":(fValue.day>2?(">"+(fValue.day-1)+" days"):((fValue.day-1)*24+fValue.hour+"h"+fValue.min.format("%02d")+"m")));
        }
        else {
          (self.oRezValueTopRightB as Ui.Text).setColor(self.iColorTextGr);
          sValue = "Age: " + $.MY_NOVALUE_LEN3;
        }
      }
      (self.oRezValueTopRightB as Ui.Text).setText(sValue);
    } else { (self.oRezValueTopRightB as Ui.Text).setText(""); }

    // ... altitude
    (View.findDrawableById("labelLeft") as Ui.Text).setColor($.bAltimeter ? Gfx.COLOR_DK_GRAY : ($.oMyProcessing.iAccuracy == 2 ? Gfx.COLOR_RED : 0xffaa55));
    (self.oRezValueLeft as Ui.Text).setColor(self.iColorText);
    fValue = $.oMyProcessing.fAltitude;
    if(LangUtils.notNaN(fValue)) {
      fValue *= $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      (self.oRezValueLeft as Ui.Text).setColor(self.iColorTextGr);
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueLeft as Ui.Text).setText(sValue);

    // ... variometer
    (self.oRezValueBottomLeft as Ui.Text).setColor(self.iColorText);
    fValue = $.oMyProcessing.fVariometer_filtered;
    if(LangUtils.notNaN(fValue)) {
      fValue *= $.oMySettings.fUnitVerticalSpeedCoefficient;
      if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
        if(fValue >= 0.05f) {
          (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_DK_GREEN);
        }
        else if(fValue <= -0.05f) {
          (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_RED);
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if(fValue >= 0.5f) {
          (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_DK_GREEN);
        }
        else if(fValue <= -0.5f) {
          (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_RED);
        }
      }
    }
    else {
      (self.oRezValueBottomLeft as Ui.Text).setColor(self.iColorTextGr);
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueBottomLeft as Ui.Text).setText(sValue);

    // Colors
    if($.oMyProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE) {
      if((($.oMySettings.bGeneralOxDisplay?1:0) * $.iViewGenOxIdx) > 0) {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackgroundOx(self.iColorBG);
      } else {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(self.iColorBG);
        (self.oRezValueTopLeft as Ui.Text).setColor(self.iColorTextGr);
        (self.oRezValueTopLeft as Ui.Text).setText($.MY_NOVALUE_LEN3);
        (self.oRezValueTopRight as Ui.Text).setColor(self.iColorTextGr);
        (self.oRezValueTopRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      }
      (self.oRezValueCenter as Ui.Text).setColor(self.iColorTextGr);
      // (self.oRezValueCenter as Ui.Text).setText($.MY_NOVALUE_LEN2);
      (self.oRezValueCenter as Ui.Text).setText("v"+Ui.loadResource(Rez.Strings.AppVersion) as String);
      (self.oRezValueRight as Ui.Text).setColor(self.iColorTextGr);
      (self.oRezValueRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueBottomRight as Ui.Text).setColor(self.iColorTextGr);
      (self.oRezValueBottomRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      return;
    }
    else if($.oMyProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      if((($.oMySettings.bGeneralOxDisplay?1:0) * $.iViewGenOxIdx) > 0) {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackgroundOx(Gfx.COLOR_YELLOW);
      } else {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_YELLOW);
      }
      self.iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      if((($.oMySettings.bGeneralOxDisplay?1:0) * $.iViewGenOxIdx) > 0) {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackgroundOx(Gfx.COLOR_TRANSPARENT);
      } else {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
      }
    }

    if((($.oMySettings.bGeneralOxDisplay?1:0) * $.iViewGenOxIdx) < 1) {
      // ... Wind Direction
      (self.oRezValueTopLeft as Ui.Text).setColor(self.iColorText);
      //sValue = LangUtils.formatTime(oTimeNow, $.oMySettings.bUnitTimeUTC, false);
      iValue = $.oMyProcessing.iWindDirection;
      if(LangUtils.notNaN(iValue) && $.oMyProcessing.bWindValid) {
        if($.oMySettings.iUnitDirection == 1) {
          sValue = $.oMyProcessing.convertDirection(iValue);
        } else {
          sValue = iValue.format("%d");
        }
          
      } else {
        (self.oRezValueTopLeft as Ui.Text).setColor(self.iColorTextGr);
        sValue = $.MY_NOVALUE_LEN3;
      }
      (self.oRezValueTopLeft as Ui.Text).setText(sValue);

      // ... Wind Speed
      (self.oRezValueTopRight as Ui.Text).setColor(self.iColorText);
      fValue = $.oMyProcessing.fWindSpeed;
      if(LangUtils.notNaN(fValue) && $.oMyProcessing.bWindValid) {
        fValue *= $.oMySettings.fUnitWindSpeedCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        (self.oRezValueTopRight as Ui.Text).setColor(self.iColorTextGr);
        sValue = $.MY_NOVALUE_LEN3;
      }
      (self.oRezValueTopRight as Ui.Text).setText(sValue);
    }

    // ... finesse
    (self.oRezValueCenter as Ui.Text).setColor(self.iColorText);
    if(LangUtils.notNaN($.oMyProcessing.fFinesse) and !$.oMyProcessing.bAscent) {
      fValue = $.oMyProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      (self.oRezValueCenter as Ui.Text).setColor(self.iColorTextGr);
      sValue = $.MY_NOVALUE_LEN2;
    }
    (self.oRezValueCenter as Ui.Text).setText(sValue);

    // ... heading
    (self.oRezValueRight as Ui.Text).setColor(self.iColorText);
    fValue = $.oMyProcessing.fHeading;

    if(LangUtils.notNaN(fValue)) {
      //fValue = ((fValue * 180.0f/Math.PI).toNumber()) % 360;
      fValue = ((fValue * 57.2957795131f).toNumber()) % 360;
      if($.oMySettings.iUnitHeading == 1) {
        sValue = $.oMyProcessing.convertDirection(fValue);
      }
      else {
        sValue = fValue.format("%d");
      }
    }
    else {
      (self.oRezValueRight as Ui.Text).setColor(self.iColorTextGr);
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueRight as Ui.Text).setText(sValue);

    // ... ground speed
    (self.oRezValueBottomRight as Ui.Text).setColor(self.iColorText);
    fValue = $.oMyProcessing.fGroundSpeed;
    if(LangUtils.notNaN(fValue)) {
      fValue *= $.oMySettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      (self.oRezValueBottomRight as Ui.Text).setColor(self.iColorTextGr);
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueBottomRight as Ui.Text).setText(sValue);
  }

  function drawArrow(_oDC as Gfx.Dc) as Void {
    if($.oMyProcessing.bWindValid) {
      var iRadius = _oDC.getWidth()*0.05f;;
      var iCompassX = _oDC.getWidth()/2;
      var iCompassY = _oDC.getHeight()/4;

      // Draw compass arrow
      var fArrowDir = Math.toRadians($.oMyProcessing.iWindDirection + 180) - $.oMyProcessing.fHeading;;

      var fArrowWidth = Math.PI * (1 - 0.15f);
      var fArrowBackLeft = fArrowDir - fArrowWidth;
      var fArrowBackRight = fArrowDir + fArrowWidth;

      var aiiArrow = [
        [iCompassX + iRadius * Math.sin(fArrowDir),     iCompassY - iRadius * Math.cos(fArrowDir)],
        [iCompassX + iRadius * Math.sin(fArrowBackLeft),  iCompassY - iRadius * Math.cos(fArrowBackLeft)],
        [iCompassX + iRadius * 0.2f * Math.sin(fArrowDir + Math.PI),  iCompassY - iRadius * 0.2f * Math.cos(fArrowDir - Math.PI)],
        [iCompassX + iRadius * Math.sin(fArrowBackRight), iCompassY - iRadius * Math.cos(fArrowBackRight)]
      ];

      _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
      _oDC.fillPolygon(aiiArrow);
    }
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewGeneral.onHide()");
    MyViewGlobal.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();
  }
}

class MyViewGeneralDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewGeneralDelegate.onPreviousPage()");
    if($.oMySettings.bGeneralOxDisplay && iViewGenOxIdx==0) {
        iViewGenOxIdx = (iViewGenOxIdx+1) % 2;
        Ui.switchToView(new MyViewGeneral(),
                        new MyViewGeneralDelegate(),
                        Ui.SLIDE_IMMEDIATE);
    }
    else if($.oMyActivity != null) { //Skip the log view if we are recording, e.g. in flight
      Ui.switchToView(new MyViewTimers(),
                      new MyViewTimersDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.switchToView(new MyViewLog(),
                      new MyViewLogDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onNextPage()");
    if($.oMySettings.bGeneralOxDisplay && iViewGenOxIdx==1) {
        iViewGenOxIdx = (iViewGenOxIdx+1) % 2;
        Ui.switchToView(new MyViewGeneral(),
                        new MyViewGeneralDelegate(),
                        Ui.SLIDE_IMMEDIATE);
    }
    else if ($.oMySettings.bGeneralVarioDisplay) {
      Ui.switchToView(new MyViewVariometer(),
                      new MyViewVariometerDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.switchToView(new MyViewVarioplot(),
                      new MyViewVarioplotDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

}
