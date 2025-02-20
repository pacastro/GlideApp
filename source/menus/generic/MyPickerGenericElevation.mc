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
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class MyPickerGenericElevation extends PickerGenericElevation {

  //
  // FUNCTIONS: PickerGenericElevation (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    if(_context == :contextSettings) {

      if(_item == :itemAltimeterCalibration) {
        PickerGenericElevation.initialize(Ui.loadResource(Rez.Strings.titleAltimeterCalibrationElevation) as String,
                                          $.oMyAltimeter.fAltitudeActual,
                                          $.oMySettings.iUnitElevation as Number,
                                          false);
      }
    }
    else if(_context == :contextOx) {

      if(_item == :menuOxElevation) {
        PickerGenericElevation.initialize(Ui.loadResource(Rez.Strings.titleOxElevation) as String,
                                          $.oMySettings.iOxElevation.toFloat(),
                                          $.oMySettings.iUnitElevation as Number,
                                          false);
      }
    }
  }

}

class MyPickerGenericElevationDelegate extends Ui.PickerDelegate {

  //
  // VARIABLES
  //

  private var context as Symbol = :contextNone;
  private var item as Symbol = :itemNone;
  private var parent as Symbol = :parentNone;
  private var focus as Number = 0;

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol, _parent as Symbol) {
    PickerDelegate.initialize();
    self.context = _context;
    self.item = _item;
    self.parent = _parent;
  }

  function onAccept(_amValues) {
    // Input validation
    // ... unit
    var iUnit = $.oMySettings.iUnitElevation != null ? $.oMySettings.iUnitElevation : -1;
    if(iUnit < 0) {
      var oDeviceSettings = System.getDeviceSettings();
      if(oDeviceSettings has :elevationUnits and oDeviceSettings.elevationUnits != null) {
        iUnit = oDeviceSettings.elevationUnits;
      }
      else {
        iUnit = System.UNIT_METRIC;
      }
    }
    // Assemble components
    var fValue = _amValues[1]*1000.0f + _amValues[2]*100.0f + _amValues[3]*10.0f + _amValues[4];
    if(_amValues[0] != null) {
      fValue *= _amValues[0];
    }
    // Use user-specified elevation unit (NB: metric units are always used internally)
    if(iUnit == System.UNIT_STATUTE) {
      fValue *= 0.3048f;  // ft -> m
    }
    
    if(self.context == :contextSettings) {

      if(self.item == :itemAltimeterCalibration) {
        $.oMyAltimeter.setAltitudeActual(fValue);
        $.oMySettings.saveAltimeterCalibrationQNH($.oMyAltimeter.fQNH);
        focus = 1;
      }
    }
    else if(self.context == :contextOx) {

      if(self.item == :menuOxElevation) {
        $.oMySettings.saveOxElevation(fValue.toNumber());

        focus = 1;
      }
    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    Ui.switchToView(new MyMenu2Generic(self.parent, focus), new MyMenu2GenericDelegate(self.parent), WatchUi.SLIDE_RIGHT);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_RIGHT);
    return true;
  }

}
