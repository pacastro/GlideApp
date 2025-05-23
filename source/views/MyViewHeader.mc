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
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewHeader extends MyView {

  //
  // VARIABLES
  //

  // Display mode (internal)
  protected var bHeaderOnly as Boolean = true;

  // Resources
  // ... drawable
  private var oRezDrawableHeader as MyDrawableHeader?;
  private var oRezDrawableCenter as Ui.Drawable?;
  // ... header
  private var oRezValueBatteryLevel as Ui.Text?;
  private var oRezValueActivityStatus as Ui.Text?;
  // ... footer
  protected var oRezValueFooter as Ui.Text?;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    // Sys.println("DEBUG: MyViewHeader.initialize()");
    if($.oMyActivity != null) { $.oTimeLastTimer = Time.now();}  // view ET timer
    MyView.initialize();

    // ... Center borders
    if(!($.oMySettings.bGeneralChartDisplay&&($.oMyProcessing.iIsCurrent == 5))) { self.oRezDrawableCenter = new Rez.Drawables.drawCenterBorders(); }
  }

  function onLayout(_oDC) {
    View.setLayout(self.bHeaderOnly ? Rez.Layouts.layoutHeader(_oDC) : Rez.Layouts.layoutGlobal(_oDC));

    // Load resources
    // ... drawable
    self.oRezDrawableHeader = View.findDrawableById("MyDrawableHeader") as MyDrawableHeader;
    // ... header
    self.oRezValueBatteryLevel = View.findDrawableById("valueBatteryLevel") as Ui.Text;
    self.oRezValueActivityStatus = View.findDrawableById("valueActivityStatus") as Ui.Text;
    // ... footer
    self.oRezValueFooter = View.findDrawableById("valueFooter") as Ui.Text;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: MyViewHeader.onUpdate()");

    // Update layout
    self.updateLayout(true);
    MyView.onUpdate(_oDC);

    if(!(self.oRezDrawableCenter == null)) { self.oRezDrawableCenter.draw(_oDC); }
  }

  //
  // FUNCTIONS: MyView (override/implement)
  //

  function updateLayout(_bUpdateTime) {
    // Sys.println("DEBUG: MyViewHeader.updateLayout()");
    MyView.updateLayout(_bUpdateTime);
    // Set colors
    // ... background
    (self.oRezDrawableHeader as MyDrawableHeader).setColorBackground($.oMySettings.iGeneralBackgroundColor);
    
    // Set header/footer values
    var sValue;

    // ... battery level
    (self.oRezValueBatteryLevel as Ui.Text).setColor(self.iColorText);
    (self.oRezValueBatteryLevel as Ui.Text).setText(format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]));

    // ... activity status
    if($.oMyActivity == null) {  // ... stand-by
      (self.oRezValueActivityStatus as Ui.Text).setColor(self.iColorText);
      sValue = self.sValueActivityStandby;
    }
    else if(($.oMyActivity as MyActivity).isRecording()) {  // ... recording
      (self.oRezValueActivityStatus as Ui.Text).setColor(Gfx.COLOR_RED);
      sValue = self.sValueActivityRecording;
    }
    else {  // ... paused
      (self.oRezValueActivityStatus as Ui.Text).setColor(Gfx.COLOR_YELLOW);
      sValue = self.sValueActivityPaused;
    }
    (self.oRezValueActivityStatus as Ui.Text).setText(sValue);

    // ... time
    if(_bUpdateTime) {
      var oTimeNow = Time.now();
      var oTimer = oTimeNow;
      if($.oMyActivity != null) {
        oTimer = new Time.Moment(oTimeNow.subtract(($.oMyActivity).oTimeStart).value());
      }
      else {
        oTimer = new Time.Moment(oTimeNow.subtract(oTimer).value());
      }
      $.bViewTimer = oTimeNow.subtract($.oTimeLastTimer).value()<10?true:false;
      var oTimeInfo = ($.oMySettings.bUnitTimeUTC || $.bViewTimer || $.oMySettings.bGeneralETDisplay)? Gregorian.utcInfo(($.bViewTimer||$.oMySettings.bGeneralETDisplay)?oTimer:oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
      (self.oRezValueFooter as Ui.Text).setColor(self.iColorText);
      (self.oRezValueFooter as Ui.Text).setText(format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), ($.bViewTimer||$.oMySettings.bGeneralETDisplay)?"ET":$.oMySettings.sUnitTime]));
    }
  }

}
