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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MySettings {

  //
  // VARIABLES
  //

  // Settings
  // ... altimeter
  public var fAltimeterCalibrationQNH as Float = 101325.0f;
  // ... variometer
  public var iVariometerRange as Number = 0;
  public var bVariometerAutoThermal as Boolean = true;
  public var bVariometerThermalDetect as Boolean = true;
  public var iVariometerSmoothing as Number = 1;
  public var iVariometerPlotRange as Number = 2;
  public var iVariometerPlotZoom as Number = 6;
  // ... sounds
  public var bSoundsVariometerTones as Boolean = false;
  public var bVariometerVibrations as Boolean = false;
  public var iMinimumClimb as Number = 2; // Default value of 0.2m/s climb threshold before sounds and vibrations are triggered
  public var iMinimumSink as Number = 1;
  // ... activity
  public var bActivityAutoStart as Boolean = false; //Auto-start recording after launch
  public var fActivityAutoSpeedStart as Float = 5.56f;
  // ... general
  public var iGeneralBackgroundColor as Number = Gfx.COLOR_WHITE;
  // ... units
  public var iUnitDistance as Number = -1;
  public var iUnitElevation as Number = -1;
  public var iUnitPressure as Number = -1;
  public var iUnitRateOfTurn as Number = 0;
  public var iUnitWindSpeed as Number = -1;
  public var iUnitDirection as Number = 1;
  public var iUnitHeading as Number = 0;
  public var bUnitTimeUTC as Boolean = false;

  // Units
  // ... symbols
  public var sUnitDistance as String = "km";
  public var sUnitHorizontalSpeed as String = "km/h";
  public var sUnitElevation as String = "m";
  public var sUnitVerticalSpeed as String = "m/s";
  public var sUnitPressure as String = "mb";
  public var sUnitRateOfTurn as String = "°/s";
  public var sUnitWindSpeed as String = "km/h";
  public var sUnitDirection as String = "txt";
  public var sUnitHeading as String = "txt";
  public var sUnitTime as String = "LT";
  // ... conversion coefficients
  public var fUnitDistanceCoefficient as Float = 0.001f;
  public var fUnitHorizontalSpeedCoefficient as Float = 3.6f;
  public var fUnitElevationCoefficient as Float = 1.0f;
  public var fUnitVerticalSpeedCoefficient as Float = 1.0f;
  public var fUnitPressureCoefficient as Float = 0.01f;
  public var fUnitWindSpeedCoefficient as Float = 3.6f;
  public var fUnitRateOfTurnCoefficient as Float = 57.2957795131f;

  // Other
  public var fVariometerRange as Float = 3.0f;
  public var iVariometerPlotOrientation as Number = 0;
  public var fVariometerPlotZoom as Float = 0.0030866666667f;
  public var fVariometerPlotScale as Number = 1.0f;
  public var fMinimumClimb as Float = 0.2;
  public var fMinimumSink as Float = 2.0;
  public var fVariometerSmoothing as Float = 0.5; //Standard deviation of altitude measurement at fixed altitude

  //
  // FUNCTIONS: self
  //

  function load() as Void {
    // Settings
    // ... altimeter
    self.setAltimeterCalibrationQNH(self.loadAltimeterCalibrationQNH());
    // ... variometer
    self.setVariometerRange(self.loadVariometerRange());
    self.setVariometerPlotOrientation(self.loadVariometerPlotOrientation());
    self.setVariometerAutoThermal(self.loadVariometerAutoThermal());
    self.setVariometerThermalDetect(self.loadVariometerThermalDetect());
    self.setVariometerSmoothing(self.loadVariometerSmoothing());
    self.setVariometerPlotRange(self.loadVariometerPlotRange());
    self.setVariometerPlotZoom(self.loadVariometerPlotZoom());
    // ... sounds and vibration
    self.setSoundsVariometerTones(self.loadSoundsVariometerTones());
    self.setVariometerVibrations(self.loadVariometerVibrations());
    self.setMinimumClimb(self.loadMinimumClimb());
    self.setMinimumSink(self.loadMinimumSink());
    // ... activity
    self.setActivityAutoStart(self.loadActivityAutoStart());
    self.setActivityAutoSpeedStart(self.loadActivityAutoSpeedStart());
    // ... general
    self.setGeneralBackgroundColor(self.loadGeneralBackgroundColor());
    // ... units
    self.setUnitDistance(self.loadUnitDistance());
    self.setUnitElevation(self.loadUnitElevation());
    self.setUnitPressure(self.loadUnitPressure());
    self.setUnitRateOfTurn(self.loadUnitRateOfTurn());
    self.setUnitWindSpeed(self.loadUnitWindSpeed());
    self.setUnitDirection(self.loadUnitDirection());
    self.setUnitHeading(self.loadUnitHeading());
    self.setUnitTimeUTC(self.loadUnitTimeUTC());
  }

  function loadAltimeterCalibrationQNH() as Float {  // [Pa]
    var fValue = App.Properties.getValue("userAltimeterCalibrationQNH") as Float?;
    return fValue != null ? fValue : 101325.0f;
  }
  function saveAltimeterCalibrationQNH(_fValue as Float) as Void {  // [Pa]
    App.Properties.setValue("userAltimeterCalibrationQNH", _fValue as App.PropertyValueType);
  }
  function setAltimeterCalibrationQNH(_fValue as Float) as Void {  // [Pa]
    // REF: https://en.wikipedia.org/wiki/Atmospheric_pressure#Records
    if(_fValue > 110000.0f) {
      _fValue = 110000.0f;
    }
    else if(_fValue < 85000.0f) {
      _fValue = 85000.0f;
    }
    self.fAltimeterCalibrationQNH = _fValue;
  }

  function loadVariometerRange() as Number {
    var iValue = App.Properties.getValue("userVariometerRange") as Number?;
    return iValue != null ? iValue : 0;
  }
  function saveVariometerRange(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerRange", _iValue as App.PropertyValueType);
  }
  function setVariometerRange(_iValue as Number) as Void {
    if(_iValue > 2) {
      _iValue = 2;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerRange = _iValue;
    switch(self.iVariometerRange) {
    case 0: self.fVariometerRange = 3.0f; break;
    case 1: self.fVariometerRange = 6.0f; break;
    case 2: self.fVariometerRange = 9.0f; break;
    }
  }

  function loadVariometerPlotOrientation () as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userVariometerPlotOrientation"), 0);
  }
  function saveVariometerPlotOrientation (_iValue as Number) as Void {
    App.Properties.setValue("userVariometerPlotOrientation", _iValue as App.PropertyValueType);
  }
  function setVariometerPlotOrientation (_iValue as Number) as Void {
    if(_iValue > 1) {
      _iValue = 1;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerPlotOrientation = _iValue;
  }

  function loadVariometerPlotRange() as Number {
    var iValue = App.Properties.getValue("userVariometerPlotRange") as Number?;
    return iValue != null ? iValue : 1;
  }
  function saveVariometerPlotRange(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerPlotRange", _iValue as App.PropertyValueType);
  }
  function setVariometerPlotRange(_iValue as Number) as Void {
    if(_iValue > 5) {
      _iValue = 5;
    }
    else if(_iValue < 1) {
      _iValue = 1;
    }
    self.iVariometerPlotRange = _iValue;
  }

  function loadVariometerPlotZoom() as Number {
    var iValue = App.Properties.getValue("userVariometerPlotZoom") as Number?;
    return iValue != null ? iValue : 6;
  }
  function saveVariometerPlotZoom(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerPlotZoom", _iValue as App.PropertyValueType);
  }
  function setVariometerPlotZoom(_iValue as Number) as Void {
    if(_iValue > 9) {
      _iValue = 9;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerPlotZoom = _iValue;
    switch(self.iVariometerPlotZoom) {
    case 0: self.fVariometerPlotZoom = 0.0000308666667f; self.fVariometerPlotScale = 1000.0f; break;  // 1000m/px
    case 1: self.fVariometerPlotZoom = 0.0000617333333f; self.fVariometerPlotScale = 500.0f; break;  // 500m/px
    case 2: self.fVariometerPlotZoom = 0.0001543333333f; self.fVariometerPlotScale = 200.0f; break;  // 200m/px
    case 3: self.fVariometerPlotZoom = 0.0003086666667f; self.fVariometerPlotScale = 100.0f; break;  // 100m/px
    case 4: self.fVariometerPlotZoom = 0.0006173333333f; self.fVariometerPlotScale = 50.0f; break;  // 50m/px
    case 5: self.fVariometerPlotZoom = 0.0015433333333f; self.fVariometerPlotScale = 20.0f; break;  // 20m/px
    case 6: self.fVariometerPlotZoom = 0.0030866666667f; self.fVariometerPlotScale = 10.0f; break;  // 10m/px
    case 7: self.fVariometerPlotZoom = 0.0061733333333f; self.fVariometerPlotScale = 5.0f; break;  // 5m/px
    case 8: self.fVariometerPlotZoom = 0.0154333333333f; self.fVariometerPlotScale = 2.0f; break;  // 2m/px
    case 9: self.fVariometerPlotZoom = 0.0308666666667f; self.fVariometerPlotScale = 1.0f; break;  // 1m/px
    }
  }

  function loadVariometerAutoThermal() as Boolean {
    var bValue = App.Properties.getValue("userVariometerAutoThermal") as Boolean?;
    return bValue != null ? bValue : true;
  }
  function saveVariometerAutoThermal(_bValue as Boolean) as Void {
    App.Properties.setValue("userVariometerAutoThermal", _bValue as App.PropertyValueType);
  }
  function setVariometerAutoThermal(_bValue as Boolean) as Void {
    self.bVariometerAutoThermal = _bValue;
  }

  function loadVariometerThermalDetect() as Boolean {
    var bValue = App.Properties.getValue("userVariometerThermalDetect") as Boolean?;
    return bValue != null ? bValue : true;
  }
  function saveVariometerThermalDetect(_bValue as Boolean) as Void {
    App.Properties.setValue("userVariometerThermalDetect", _bValue as App.PropertyValueType);
  }
  function setVariometerThermalDetect(_bValue as Boolean) as Void {
    self.bVariometerThermalDetect = _bValue;
  }

  function loadVariometerSmoothing() as Number { 
    var iValue = App.Properties.getValue("userVariometerSmoothing") as Number?;
    return iValue != null ? iValue : 1;
  }
  function saveVariometerSmoothing(_iValue as Number) as Void { 
    App.Properties.setValue("userVariometerSmoothing", _iValue as App.PropertyValueType);
  }
  function setVariometerSmoothing(_iValue as Number) as Void {
    if(_iValue > 3) {
      _iValue = 3;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerSmoothing = _iValue;
    switch(self.iVariometerSmoothing) {
    case 0: self.fVariometerSmoothing = 0.2f; break;
    case 1: self.fVariometerSmoothing = 0.5f; break;
    case 2: self.fVariometerSmoothing = 0.7f; break;
    case 3: self.fVariometerSmoothing = 1.0f; break;
    }
  }

  function loadSoundsVariometerTones() as Boolean {
    var bValue = App.Properties.getValue("userSoundsVariometerTones") as Boolean?;
    return bValue != null ? bValue : true;
  }
  function saveSoundsVariometerTones(_bValue as Boolean) as Void {
    App.Properties.setValue("userSoundsVariometerTones", _bValue as App.PropertyValueType);
  }
  function setSoundsVariometerTones(_bValue as Boolean) as Void {
    self.bSoundsVariometerTones = _bValue;
  }

  function loadVariometerVibrations() as Boolean {
    var bValue = App.Properties.getValue("userVariometerVibrations") as Boolean?;
    return bValue != null ? bValue : true;
  }
  function saveVariometerVibrations(_bValue as Boolean) as Void {
    App.Properties.setValue("userVariometerVibrations", _bValue as App.PropertyValueType);
  }
  function setVariometerVibrations(_bValue as Boolean) as Void {
    self.bVariometerVibrations = _bValue;
  }

  function loadMinimumClimb() as Number { 
    var iValue = App.Properties.getValue("userMinimumClimb") as Number?;
    return iValue != null ? iValue : 2;
  }
  function saveMinimumClimb(_iValue as Number) as Void {  // [m/s]
    App.Properties.setValue("userMinimumClimb", _iValue as App.PropertyValueType);
  }
  function setMinimumClimb(_iValue as Number) as Void {
    if(_iValue > 5) {
      _iValue = 5;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iMinimumClimb = _iValue;
    switch(self.iMinimumClimb) {
    case 0: self.fMinimumClimb = 0.0f; break;
    case 1: self.fMinimumClimb = 0.1f; break;
    case 2: self.fMinimumClimb = 0.2f; break;
    case 3: self.fMinimumClimb = 0.3f; break;
    case 4: self.fMinimumClimb = 0.4f; break;
    case 5: self.fMinimumClimb = 0.5f; break;
    }
  }

  function loadMinimumSink() as Number { 
    var iValue = App.Properties.getValue("userMinimumSink") as Number?;
    return iValue != null ? iValue : 1;
  }
  function saveMinimumSink(_iValue as Number) as Void {  // [m/s]
    App.Properties.setValue("userMinimumSink", _iValue as App.PropertyValueType);
  }
  function setMinimumSink(_iValue as Number) as Void {
    if(_iValue > 5) {
      _iValue = 5;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iMinimumSink = _iValue;
    switch(self.iMinimumSink) {
    case 0: self.fMinimumSink = -1.0f; break;
    case 1: self.fMinimumSink = -2.0f; break;
    case 2: self.fMinimumSink = -3.0f; break;
    case 3: self.fMinimumSink = -4.0f; break;
    case 4: self.fMinimumSink = -6.0f; break;
    case 5: self.fMinimumSink = -10.0f; break;
    }
  }

  function loadActivityAutoStart() as Boolean {
    var bValue = App.Properties.getValue("userActivityAutoStart") as Boolean?;
    return bValue != null ? bValue : true;
  }
  function saveActivityAutoStart(_bValue as Boolean) as Void {
    App.Properties.setValue("userActivityAutoStart", _bValue as App.PropertyValueType);
  }
  function setActivityAutoStart(_bValue as Boolean) as Void {
    self.bActivityAutoStart = _bValue;
  }

  function loadActivityAutoSpeedStart() as Float {  // [m/s]
    var fValue = App.Properties.getValue("userActivityAutoSpeedStart") as Float?;
    return fValue != null ? fValue : 5.56f;
  }
  function saveActivityAutoSpeedStart(_fValue as Float) as Void {  // [m/s]
    App.Properties.setValue("userActivityAutoSpeedStart", _fValue as App.PropertyValueType);
  }
  function setActivityAutoSpeedStart(_fValue as Float) as Void {  // [m/s]
    if(_fValue > 99.9f) {
      _fValue = 99.9f;
    }
    else if(_fValue < 0.0f) {
      _fValue = 0.0f;
    }
    self.fActivityAutoSpeedStart = _fValue;
  }

  function loadGeneralBackgroundColor() as Number {
    var iValue = App.Properties.getValue("userGeneralBackgroundColor") as Number?;
    return iValue != null ? iValue : Gfx.COLOR_WHITE;
  }
  function saveGeneralBackgroundColor(_iValue as Number) as Void {
    App.Properties.setValue("userGeneralBackgroundColor", _iValue as App.PropertyValueType);
  }
  function setGeneralBackgroundColor(_iValue as Number) as Void {
    self.iGeneralBackgroundColor = _iValue;
  }
  
  function loadUnitDistance() as Number {
    var iValue = App.Properties.getValue("userUnitDistance") as Number?;
    return iValue != null ? iValue : -1;
  }
  function saveUnitDistance(_iValue as Number) as Void {
    App.Properties.setValue("userUnitDistance", _iValue as App.PropertyValueType);
  }
  function setUnitDistance(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 2) {
      _iValue = -1;
    }
    self.iUnitDistance = _iValue;
    if(self.iUnitDistance < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
        _iValue = oDeviceSettings.distanceUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == 2) {  // ... nautical
      // ... [nm]
      self.sUnitDistance = "nm";
      self.fUnitDistanceCoefficient = 0.000539956803456f;  // ... m -> nm
      // ... [kt]
      self.sUnitHorizontalSpeed = "kt";
      self.fUnitHorizontalSpeedCoefficient = 1.94384449244f;  // ... m/s -> kt
    }
    else if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
      // ... [sm]
      self.sUnitDistance = "sm";
      self.fUnitDistanceCoefficient = 0.000621371192237f;  // ... m -> sm
      // ... [mph]
      self.sUnitHorizontalSpeed = "mph";
      self.fUnitHorizontalSpeedCoefficient = 2.23693629205f;  // ... m/s -> mph
    }
    else {  // ... metric
      // ... [km]
      self.sUnitDistance = "km";
      self.fUnitDistanceCoefficient = 0.001f;  // ... m -> km
      // ... [kph]
      self.sUnitHorizontalSpeed = "kph";
      self.fUnitHorizontalSpeedCoefficient = 3.6f;  // ... m/s -> km/h
    }
  }

  function loadUnitElevation() as Number {
    var iValue = App.Properties.getValue("userUnitElevation") as Number?;
    return iValue != null ? iValue : -1;
  }
  function saveUnitElevation(_iValue as Number) as Void {
    App.Properties.setValue("userUnitElevation", _iValue as App.PropertyValueType);
  }
  function setUnitElevation(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = -1;
    }
    self.iUnitElevation = _iValue;
    if(self.iUnitElevation < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :elevationUnits and oDeviceSettings.elevationUnits != null) {
        _iValue = oDeviceSettings.elevationUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
      // ... [ft]
      self.sUnitElevation = "ft";
      self.fUnitElevationCoefficient = 3.280839895f;  // ... m -> ft
      // ... [ft/min]
      self.sUnitVerticalSpeed = "ft/m";
      self.fUnitVerticalSpeedCoefficient = 196.8503937f;  // ... m/s -> ft/min
    }
    else {  // ... metric
      // ... [m]
      self.sUnitElevation = "m";
      self.fUnitElevationCoefficient = 1.0f;  // ... m -> m
      // ... [m/s]
      self.sUnitVerticalSpeed = "m/s";
      self.fUnitVerticalSpeedCoefficient = 1.0f;  // ... m/s -> m/s
    }
  }

  function loadUnitPressure() as Number {
    var iValue = App.Properties.getValue("userUnitPressure") as Number?;
    return iValue != null ? iValue : -1;
  }
  function saveUnitPressure(_iValue as Number) as Void {
    App.Properties.setValue("userUnitPressure", _iValue as App.PropertyValueType);
  }
  function setUnitPressure(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = -1;
    }
    self.iUnitPressure = _iValue;
    if(self.iUnitPressure < 0) {  // ... auto
      // NOTE: assume weight units are a good indicator of preferred pressure units
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :weightUnits and oDeviceSettings.weightUnits != null) {
        _iValue = oDeviceSettings.weightUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
      // ... [inHg]
      self.sUnitPressure = "inHg";
      self.fUnitPressureCoefficient = 0.0002953f;  // ... Pa -> inHg
    }
    else {  // ... metric
      // ... [mb/hPa]
      self.sUnitPressure = "mb";
      self.fUnitPressureCoefficient = 0.01f;  // ... Pa -> mb/hPa
    }
  }

  function loadUnitRateOfTurn() as Number {
    var iValue = App.Properties.getValue("userUnitRateOfTurn") as Number?;
    return iValue != null ? iValue : 0;
  }
  function saveUnitRateOfTurn(_iValue as Number) as Void {
    App.Properties.setValue("userUnitRateOfTurn", _iValue as App.PropertyValueType);
  }
  function setUnitRateOfTurn(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = 0;
    }
    self.iUnitRateOfTurn = _iValue;
    if(_iValue == 1) {  // ... revolution-per-minute
      // ... [rpm]
      self.sUnitRateOfTurn = "rpm";
      self.fUnitRateOfTurnCoefficient = 9.54929658551f;  // ... rad/s -> rpm
    }
    else {  // ... degree-per-second
      // ... [deg/s]
      self.sUnitRateOfTurn = "°/s";
      self.fUnitRateOfTurnCoefficient = 57.2957795131f;  // ... rad/s -> deg/s
    }
  }
  
  function loadUnitDirection() as Number {
    var iValue = App.Properties.getValue("userUnitDirection") as Number?;
    return iValue != null ? iValue : 1;
  }
  function saveUnitDirection(_iValue as Number) as Void {
    App.Properties.setValue("userUnitDirection", _iValue as App.PropertyValueType);
  }
  function setUnitDirection(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = 1;
    }
    self.iUnitDirection = _iValue;
    if(_iValue == 1) {  // ... Text
      // ... txt
      self.sUnitDirection = "txt";
    }
    else {  // ... Degrees
      self.sUnitDirection = "°";
    }
  }

  function loadUnitHeading() as Number {
    var iValue = App.Properties.getValue("userUnitHeading") as Number?;
    return iValue != null ? iValue : 1;
  }
  function saveUnitHeading(_iValue as Number) as Void {
    App.Properties.setValue("userUnitHeading", _iValue as App.PropertyValueType);
  }
  function setUnitHeading(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = 1;
    }
    self.iUnitHeading = _iValue;
    if(_iValue == 1) {  // ... Text
      // ... txt
      self.sUnitHeading = "txt";
    }
    else {  // ... Degrees
      self.sUnitHeading = "°";
    }
  }

  function loadUnitWindSpeed() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userUnitWindSpeed"), 1);
  }
  function saveUnitWindSpeed(_iValue as Number) as Void {
    App.Properties.setValue("userUnitWindSpeed", _iValue as App.PropertyValueType);
  }
  function setUnitWindSpeed(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 3) {
      _iValue = -1;
    }
    self.sUnitWindSpeed = _iValue;
    if(self.sUnitWindSpeed < 0) {  // ... auto
      _iValue = App.Properties.getValue("userUnitDistance") as Number?;
    }

    if (_iValue == Sys.UNIT_METRIC) {
      self.sUnitWindSpeed = "kph";
      self.fUnitWindSpeedCoefficient = 3.6f;  // ... m/s -> km/h
    } else if (_iValue == Sys.UNIT_STATUTE) {
      self.sUnitWindSpeed = "mph";
      self.fUnitWindSpeedCoefficient = 2.23693629205f;  // ... m/s -> mph
    } else if (_iValue == 2) {
      self.sUnitWindSpeed = "kt";
      self.fUnitWindSpeedCoefficient = 1.94384449244f;  // ... m/s -> kt
    } else {
      self.sUnitWindSpeed = "m/s";
      self.fUnitWindSpeedCoefficient = 1.0f;  // ... m/s -> m/s
    }
  }

  function loadUnitTimeUTC() as Boolean {
    var bValue = App.Properties.getValue("userUnitTimeUTC") as Boolean?;
    return bValue != null ? bValue : false;
  }
  function saveUnitTimeUTC(_bValue as Boolean) as Void {
    App.Properties.setValue("userUnitTimeUTC", _bValue as App.PropertyValueType);
  }
  function setUnitTimeUTC(_bValue as Boolean) as Void {
    self.bUnitTimeUTC = _bValue;
    if(_bValue) {
      self.sUnitTime = "Z";
    }
    else {
      self.sUnitTime = "LT";
    }
  }

}
