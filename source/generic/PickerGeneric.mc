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
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class PickerGeneric extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_sTitle as String, _fValue as Float?, _iUnit as Number?, _bAllowNegative as Boolean, _type as Symbol) {
    // Input validation
    // ... unit
    var iUnit = _iUnit != null ? _iUnit : -1;
    if(_type == :speed) {
      if(iUnit < 0 or iUnit > 2) {
        var oDeviceSettings = Sys.getDeviceSettings();
        if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
          iUnit = oDeviceSettings.distanceUnits;
        }
        else {
          iUnit = Sys.UNIT_METRIC;
        }
      }
      // ... value
      var fValue = (_fValue != null and LangUtils.notNaN(_fValue)) ? _fValue : 0.0f;

      // Use user-specified speed unit (NB: SI units are always used internally)
      // PRECISION: 0.1 (* 10)
      var sUnit = "km/h";
      var iMaxSignificant = 9;
      if(iUnit == 2) {
        sUnit = "kt";
        iMaxSignificant = 6;
        fValue *= 19.4384449244f;  // m/s -> kt (* 10)
        if(fValue > 6999.0f) {
          fValue = 6999.0f;
        }
        else if(fValue < -6999.0f) {
          fValue = -6999.0f;
        }
      }
      else if(iUnit == Sys.UNIT_STATUTE) {
        sUnit = "mph";
        iMaxSignificant = 7;
        fValue *= 22.3693629205f;  // m/s -> mph (* 10)
        if(fValue > 7999.0f) {
          fValue = 7999.0f;
        }
        else if(fValue < -7999.0f) {
          fValue = -7999.0f;
        }
      }
      else {
        fValue *= 36.0f;  // m/s -> km/h (* 10)
        if(fValue > 9999.0f) {
          fValue = 9999.0f;
        }
        else if(fValue < -9999.0f) {
          fValue = -9999.0f;
        }
      }
      if(!_bAllowNegative and fValue < 0.0f) {
        fValue = 0.0f;
      }

      // Split components
      var aiValues = new Array<Number>[5];
      aiValues[0] = fValue < 0.0f ? 0 : 1;
      fValue = fValue.abs() + 0.05f;
      aiValues[4] = fValue.toNumber() % 10;
      fValue = fValue / 10.0f;
      aiValues[3] = fValue.toNumber() % 10;
      fValue = fValue / 10.0f;
      aiValues[2] = fValue.toNumber() % 10;
      fValue = fValue / 10.0f;
      aiValues[1] = fValue.toNumber();

      // Initialize picker
      Picker.initialize({
          :title => new Ui.Text({
              :text => format("$1$ [$2$]", [_sTitle, sUnit]),
              :font => Gfx.FONT_TINY,
              :locX => Ui.LAYOUT_HALIGN_CENTER,
              :locY => Ui.LAYOUT_VALIGN_BOTTOM,
              :color => Gfx.COLOR_BLUE}),
          :pattern => [_bAllowNegative ? new PickerFactoryDictionary([-1, 1], ["-", "+"], null) : new Ui.Text({}),
                      new PickerFactoryNumber(0, iMaxSignificant, null),
                      new PickerFactoryNumber(0, 9, null),
                      new PickerFactoryNumber(0, 9, {:langFormat => "$1$."}),
                      new PickerFactoryNumber(0, 9, null)],
          :defaults => aiValues});
      }

    else if(_type == :elevation) {
      if(iUnit < 0) {
        var oDeviceSettings = Sys.getDeviceSettings();
        if(oDeviceSettings has :elevationUnits and oDeviceSettings.elevationUnits != null) {
          iUnit = oDeviceSettings.elevationUnits;
        }
        else {
          iUnit = Sys.UNIT_METRIC;
        }
      }
      // ... value
      var fValue = (_fValue != null and LangUtils.notNaN(_fValue)) ? _fValue : 0.0f;

      // Use user-specified elevation unit (NB: metric units are always used internally)
      // PRECISION: 1
      var sUnit = "m";
      var iMaxSignificant = 9;
      if(iUnit == Sys.UNIT_STATUTE) {
        sUnit = "ft";
        iMaxSignificant = 31;
        fValue /= 0.3048f;  // m -> ft
        if(fValue > 31999.0f) {
          fValue = 31999.0f;
        }
        else if(fValue < -31999.0f) {
          fValue = -31999.0f;
        }
      }
      else {
        if(fValue > 9999.0f) {
          fValue = 9999.0f;
        }
        else if(fValue < -9999.0f) {
          fValue = -9999.0f;
        }
      }
      if(!_bAllowNegative and fValue < 0.0f) {
        fValue = 0.0f;
      }

      // Split components
      var aiValues = new Array<Number>[5];
      aiValues[0] = fValue < 0.0f ? 0 : 1;
      fValue = fValue.abs() + 0.05f;
      aiValues[4] = fValue.toNumber() % 10;
      fValue = fValue / 10.0f;
      aiValues[3] = fValue.toNumber() % 10;
      fValue = fValue / 10.0f;
      aiValues[2] = fValue.toNumber() % 10;
      fValue = fValue / 10.0f;
      aiValues[1] = fValue.toNumber();

      // Initialize picker
      Picker.initialize({
          :title => new Ui.Text({
              :text => format("$1$ [$2$]", [_sTitle, sUnit]),
              :font => Gfx.FONT_TINY,
              :locX => Ui.LAYOUT_HALIGN_CENTER,
              :locY => Ui.LAYOUT_VALIGN_BOTTOM,
              :color => Gfx.COLOR_BLUE}),
          :pattern => [_bAllowNegative ? new PickerFactoryDictionary([-1, 1], ["-", "+"], null) : new Ui.Text({}),
                      new PickerFactoryNumber(0, iMaxSignificant, {:langFormat => "$1$ '"}),
                      new PickerFactoryNumber(0, 9, null),
                      new PickerFactoryNumber(0, 9, null),
                      new PickerFactoryNumber(0, 9, null)],
          :defaults => aiValues});
    }

    else if(_type == :pressure) {
      if(iUnit < 0) {
        var oDeviceSettings = Sys.getDeviceSettings();
        if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
          iUnit = oDeviceSettings.distanceUnits;
        }
        else {
          iUnit = Sys.UNIT_METRIC;
        }
      }
      // ... value
      var fValue = (_fValue != null and LangUtils.notNaN(_fValue)) ? _fValue : 0.0f;

      // Use user-specified pressure unit (NB: metric units are always used internally)
      // PRECISION: metric 0.1 (* 10) / statute 0.001 (* 1000)
      var sUnit = "mb";
      var iMaxSignificant = 10;
      if(iUnit == Sys.UNIT_STATUTE) {
        sUnit = "inHg";
        iMaxSignificant = 31;
        fValue *= 0.2953f;  // Pa -> inHg (* 1000)
        if(fValue > 31999.0f) {
          fValue = 31999.0f;
        }
        else if(fValue < -31999.0f) {
          fValue = -31999.0f;
        }
      }
      else {
        fValue *= 0.1f;  // Pa -> mb (* 10)
        if(fValue > 10999.0f) {
          fValue = 10999.0f;
        }
        else if(fValue < -10999.0f) {
          fValue = -10999.0f;
        }
      }
      if(!_bAllowNegative and fValue < 0.0f) {
        fValue = 0.0f;
      }

      // Split components
      var aiValues = new Array<Number>[5];
      aiValues[0] = fValue < 0.0f ? 0 : 1;
      fValue = fValue.abs() + 0.05f;
      aiValues[4] = fValue.toNumber() % 10;
      fValue = fValue / 10.0f;
      aiValues[3] = fValue.toNumber() % 10;
      fValue = fValue / 10.0f;
      aiValues[2] = fValue.toNumber() % 10;
      fValue = fValue / 10.0f;
      aiValues[1] = fValue.toNumber();

      // Initialize picker
      Picker.initialize({
          :title => new Ui.Text({
              :text => format("$1$ [$2$]", [_sTitle, sUnit]),
              :font => Gfx.FONT_TINY,
              :locX => Ui.LAYOUT_HALIGN_CENTER,
              :locY => Ui.LAYOUT_VALIGN_BOTTOM,
              :color => Gfx.COLOR_BLUE}),
          :pattern => [_bAllowNegative ? new PickerFactoryDictionary([-1, 1], ["-", "+"], null) : new Ui.Text({}),
                      new PickerFactoryNumber(0, iMaxSignificant, iUnit == Sys.UNIT_STATUTE ? {:langFormat => "$1$."} : null),
                      new PickerFactoryNumber(0, 9, null),
                      new PickerFactoryNumber(0, 9, iUnit == Sys.UNIT_METRIC ? {:langFormat => "$1$."} : null),
                      new PickerFactoryNumber(0, 9, null)],
          :defaults => aiValues});
    }
  }
}
