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
using Toybox.Activity;
using Toybox.ActivityRecording as AR;
using Toybox.Application as App;
using Toybox.Attention as Attn;
using Toybox.FitContributor as FC;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.System as Sys;

//
// CLASS
//

class MyActivity {

  //
  // CONSTANTS
  //

  // FIT fields (as per resources/fit.xml)
  // ... record
  public const FITFIELD_SpO2 = 0;
  public const FITFIELD_BAROMETRICALTITUDE = 1;
  public const FITFIELD_VERTICALSPEED = 2;
  public const FITFIELD_ACCELERATION = 3;
  public const FITFIELD_RATEOFTURN = 4;
  
  // ... lap

  // ... session
  public const FITFIELD_GLOBALDISTANCE = 80;
  public const FITFIELD_GLOBALASCENT = 81;
  public const FITFIELD_GLOBALELAPSEDASCENT = 82;
  public const FITFIELD_GLOBALALTITUDEMIN = 83;
  public const FITFIELD_GLOBALTIMEALTITUDEMIN = 84;
  public const FITFIELD_GLOBALALTITUDEMAX = 85;
  public const FITFIELD_GLOBALTIMEALTITUDEMAX = 86;
  // Time constant
  private const TIME_CONSTANT = 3;


  //
  // VARIABLES
  //

  // Session
  // ... recording
  public var oSession as AR.Session;
  public var oTimeStart as Time.Moment?;
  public var oTimeStop as Time.Moment?;
  public var oTimePause as Time.Duration?;
  public var oTimePauseTot as Time.Duration?;
  // ... session
  public var fGlobalDistance as Float = 0.0f;
  public var fGlobalAscent as Float = 0.0f;
  public var iGlobalElapsedAscent as Number = 0;
  public var fGlobalAltitudeMin as Float = NaN;
  public var oGlobalTimeAltitudeMin as Time.Moment?;
  public var fGlobalAltitudeMax as Float = NaN;
  public var oGlobalTimeAltitudeMax as Time.Moment?;
  // ... internals
  private var iEpochLast as Number = -1;
  private var adPositionRadiansLast as Array<Double>?;
  private var fAltitudeLast as Float = NaN;

  // FIT fields
  // ... (unit conversion) coefficients
  private var bUnitCoefficient_TimeUTC as Boolean = false;
  private var fUnitCoefficient_Distance as Float = 1.0f;
  private var fUnitCoefficient_Altitude as Float = 1.0f;
  private var fUnitCoefficient_VerticalSpeed as Float = 1.0f;
  private var fUnitCoefficient_RateOfTurn as Float = 1.0f;
  // ... record
  private var oFitField_SpO2 as FC.Field;
  private var oFitField_BarometricAltitude as FC.Field;
  private var oFitField_VerticalSpeed as FC.Field;
  private var oFitField_RateOfTurn as FC.Field;
  private var oFitField_Acceleration as FC.Field;
  // ... session
  private var oFitField_GlobalDistance as FC.Field;
  private var oFitField_GlobalAscent as FC.Field;
  private var oFitField_GlobalElapsedAscent as FC.Field;
  private var oFitField_GlobalAltitudeMin as FC.Field;
  private var oFitField_GlobalTimeAltitudeMin as FC.Field;
  private var oFitField_GlobalAltitudeMax as FC.Field;
  private var oFitField_GlobalTimeAltitudeMax as FC.Field;

  //
  // FUNCTIONS: self
  //

  function initialize() {
    //Sys.println("DEBUG: MyActivity.initialize()");

    // Session (recording)
    // SPORT_FLYING = 20 (since API 3.0.10)
    oSession = AR.createSession({
        :name => "GlideApp",
        :sport => 20 as AR.Sport2});
        // :subSport => AR.SUB_SPORT_GENERIC});

    // FIT fields

    // ... (unit conversion) coefficients
    bUnitCoefficient_TimeUTC = $.oMySettings.bUnitTimeUTC;
    fUnitCoefficient_Distance = $.oMySettings.fUnitDistanceCoefficient;
    fUnitCoefficient_Altitude = $.oMySettings.fUnitElevationCoefficient;
    fUnitCoefficient_VerticalSpeed = $.oMySettings.fUnitVerticalSpeedCoefficient;
    fUnitCoefficient_RateOfTurn = $.oMySettings.fUnitRateOfTurnCoefficient;

    // ... record
    oFitField_SpO2 =
      oSession.createField("SpO2",
                           MyActivity.FITFIELD_SpO2,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_RECORD, :units => "%"});
    oFitField_BarometricAltitude =
      oSession.createField("BarometricAltitude",
                           MyActivity.FITFIELD_BAROMETRICALTITUDE,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_RECORD, :units => $.oMySettings.sUnitElevation});
    oFitField_VerticalSpeed =
      oSession.createField("VerticalSpeed",
                           MyActivity.FITFIELD_VERTICALSPEED,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_RECORD, :units => $.oMySettings.sUnitVerticalSpeed});
    oFitField_RateOfTurn =
      oSession.createField("RateOfTurn",
                           MyActivity.FITFIELD_RATEOFTURN,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_RECORD, :units => $.oMySettings.sUnitRateOfTurn});
    oFitField_Acceleration =
      oSession.createField("Acceleration",
                           MyActivity.FITFIELD_ACCELERATION,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_RECORD, :units => "g"});

    // ... session
    oFitField_GlobalDistance =
      oSession.createField("Distance",
                           MyActivity.FITFIELD_GLOBALDISTANCE,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_SESSION, :units => $.oMySettings.sUnitDistance});
    oFitField_GlobalAscent =
      oSession.createField("Ascent",
                           MyActivity.FITFIELD_GLOBALASCENT,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_SESSION, :units => $.oMySettings.sUnitElevation});
    oFitField_GlobalElapsedAscent =
      oSession.createField("ElapsedAscent",
                           MyActivity.FITFIELD_GLOBALELAPSEDASCENT,
                           FC.DATA_TYPE_STRING,
                           {:mesgType => FC.MESG_TYPE_SESSION, :count => 9});
    oFitField_GlobalAltitudeMin =
      oSession.createField("AltitudeMin",
                           MyActivity.FITFIELD_GLOBALALTITUDEMIN,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_SESSION, :units => $.oMySettings.sUnitElevation});
    oFitField_GlobalTimeAltitudeMin =
      oSession.createField("TimeAltitudeMin",
                           MyActivity.FITFIELD_GLOBALTIMEALTITUDEMIN,
                           FC.DATA_TYPE_STRING,
                           {:mesgType => FC.MESG_TYPE_SESSION, :count => 9, :units => $.oMySettings.sUnitTime});
    oFitField_GlobalAltitudeMax =
      oSession.createField("AltitudeMax",
                           MyActivity.FITFIELD_GLOBALALTITUDEMAX,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_SESSION, :units => $.oMySettings.sUnitElevation});
    oFitField_GlobalTimeAltitudeMax =
      oSession.createField("TimeAltitudeMax",
                           MyActivity.FITFIELD_GLOBALTIMEALTITUDEMAX,
                           FC.DATA_TYPE_STRING,
                           {:mesgType => FC.MESG_TYPE_SESSION, :count => 9, :units => $.oMySettings.sUnitTime});

  }


  //
  // FUNCTIONS: self (session)
  //

  function start() as Void {
    //Sys.println("DEBUG: MyActivity.start()");

    self.resetLog(true);
    self.oSession.start();
    self.oTimeStart = Time.now();
    self.oTimePauseTot = new Time.Duration(0);
    if(Toybox.Attention has :playTone) {
      Attn.playTone(Attn.TONE_START);
    }
    bActStop = false;
    bActStart = true;
    oDispTime = Time.now();
    bChartReset = true;
  }

  function isRecording() as Boolean {
    //Sys.println("DEBUG: MyActivity.isRecording()");

    return self.oSession.isRecording();
  }

  function pause() as Void {
    //Sys.println("DEBUG: MyActivity.pause()");

    if(!self.oSession.isRecording()) {
      return;
    }
    self.oTimeStop = Time.now();
    self.oSession.stop();
    if(Toybox.Attention has :playTone) {
      Attn.playTone(Attn.TONE_STOP);
    }
    bActStart = false;
    bActPause = true;
    oDispTime = Time.now();
  }

  function resume() as Void {
    //Sys.println("DEBUG: MyActivity.resume()");

    if(self.oSession.isRecording()) {
      return;
    }
    if(oTimeStop!=null) {
      self.oTimePause = Time.now().subtract(oTimeStop);
      self.oTimePauseTot = oTimePauseTot.add(oTimePause);
    }
    self.oSession.start();
    if(Toybox.Attention has :playTone) {
      Attn.playTone(Attn.TONE_START);
    }
    bActStart = true;
    oDispTime = Time.now();
  }

  function stop(_bSave as Boolean) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.stop($1$)", [_bSave]));

    if(self.oSession.isRecording()) {
      self.oSession.stop();
    }
    else if(oTimeStop!=null) {
      self.oTimePause = Time.now().subtract(oTimeStop);
      self.oTimePauseTot = oTimePauseTot.add(oTimePause);
    }
    if(_bSave) {
      self.oTimeStop = Time.now();
      self.saveLog(true);
      self.oSession.save();
      if(Toybox.Attention has :playTone) {
        Attn.playTone(Attn.TONE_STOP);
      }
    }
    else {
      self.oSession.discard();
      if(Toybox.Attention has :playTone) {
        Attn.playTone(Attn.TONE_RESET);
      }
    }
    self.oTimeStart = null;
    self.oTimeStop = null;
    bActStart = false;
    bActPause = false;
    bActStop = true;
    oDispTime = Time.now();
  }


  //
  // FUNCTIONS: self (log)
  //

  function resetLog(_bSession as Boolean) as Void {
    self.iEpochLast = -1;
    self.adPositionRadiansLast = null;
    self.fAltitudeLast = NaN;
    // ... session
    if(_bSession) {
      self.fGlobalDistance = 0.0f;
      self.fGlobalAscent = 0.0f;
      self.iGlobalElapsedAscent = 0;
      self.fGlobalAltitudeMin = NaN;
      self.oGlobalTimeAltitudeMin = null;
      self.fGlobalAltitudeMax = NaN;
      self.oGlobalTimeAltitudeMax = null;
    }
  }

  function processPositionInfo(_oInfo as Pos.Info, _iEpoch as Number, _oTimeNow as Time.Moment) as Void {
    //Sys.println("DEBUG: MyActivity.processPositionInfo()");

    // NOTE: We use Pos.Info.altitude to remain consistent with other (internal) Activity position/altitude data
    if(!self.oSession.isRecording()
       or !(_oInfo has :accuracy) or _oInfo.accuracy < Pos.QUALITY_GOOD
       or !(_oInfo has :position) or _oInfo.position == null
       or !(_oInfo has :altitude) or _oInfo.altitude == null
       or _iEpoch - self.iEpochLast < self.TIME_CONSTANT) {
      return;
    }

    // Distance (non-thermalling)
    var adPositionRadians = (_oInfo.position as Pos.Location).toRadians();
    if(self.adPositionRadiansLast != null) {
      var fLegLength = LangUtils.distanceEstimate(self.adPositionRadiansLast, adPositionRadians);
      if(fLegLength > 500.0f) {  // # 1000m = 1km should be bigger than thermalling diameter/trying 500m
        self.adPositionRadiansLast = adPositionRadians;
        // ... session
        self.fGlobalDistance += fLegLength;
      }
    }
    else {
      self.adPositionRadiansLast = adPositionRadians;
    }

    // Ascent
    if(self.iEpochLast >= 0 and (_oInfo.altitude as Float) > self.fAltitudeLast) {
      // ... session
      self.fGlobalAscent += ((_oInfo.altitude as Float) - self.fAltitudeLast);
      self.iGlobalElapsedAscent += (_iEpoch - self.iEpochLast);
    }
    self.fAltitudeLast = _oInfo.altitude as Float;

    // Altitude
    // ... session
    if(!((_oInfo.altitude as Float) >= self.fGlobalAltitudeMin)) {  // NB: ... >= NaN is always false
      self.fGlobalAltitudeMin = _oInfo.altitude as Float;
      self.oGlobalTimeAltitudeMin = _oTimeNow;
    }
    if(!((_oInfo.altitude as Float) <= self.fGlobalAltitudeMax)) {  // NB: ... <= NaN is always false
      self.fGlobalAltitudeMax = _oInfo.altitude as Float;
      self.oGlobalTimeAltitudeMax = _oTimeNow;
    }

    // Epoch
    self.iEpochLast = _iEpoch;
  }

  function saveLog(_bSession as Boolean) as Void {
    // FIT fields
    // ... session
    if(_bSession) {
      self.setGlobalDistance(self.fGlobalDistance);
      self.setGlobalAscent(self.fGlobalAscent);
      self.setGlobalElapsedAscent(self.iGlobalElapsedAscent);
      self.setGlobalAltitudeMin(self.fGlobalAltitudeMin);
      self.setGlobalTimeAltitudeMin(self.oGlobalTimeAltitudeMin);
      self.setGlobalAltitudeMax(self.fGlobalAltitudeMax);
      self.setGlobalTimeAltitudeMax(self.oGlobalTimeAltitudeMax);
    }

    // Log entry
    if(_bSession) {
      var dictLog = {
        "timeStart" => self.oTimeStart != null ? (self.oTimeStart as Time.Moment).value() : null,
        "timeStop" => self.oTimeStop != null ? (self.oTimeStop as Time.Moment).value() : null,
        "timePause" => self.oTimePauseTot != null ? (self.oTimePauseTot as Time.Duration).value() : null,
        "distance" => LangUtils.notNaN(self.fGlobalDistance) ? self.fGlobalDistance : null,
        "ascent" => LangUtils.notNaN(self.fGlobalAscent) ? self.fGlobalAscent : null,
        "elapsedAscent" => LangUtils.notNaN(self.iGlobalElapsedAscent) ? self.iGlobalElapsedAscent : null,
        "altitudeMin" => LangUtils.notNaN(self.fGlobalAltitudeMin) ? self.fGlobalAltitudeMin : null,
        "timeAltitudeMin" => self.oGlobalTimeAltitudeMin != null ? (self.oGlobalTimeAltitudeMin as Time.Moment).value() : null,
        "altitudeMax" => LangUtils.notNaN(self.fGlobalAltitudeMax) ? self.fGlobalAltitudeMax : null,
        "timeAltitudeMax" => self.oGlobalTimeAltitudeMax != null ? (self.oGlobalTimeAltitudeMax as Time.Moment).value() : null,
      };
      $.iMyLogIndex = ($.iMyLogIndex + 1) % $.MY_STORAGE_SLOTS;
      var s = $.iMyLogIndex.format("%02d");
      App.Storage.setValue(Lang.format("storLog$1$", [s]), dictLog as App.PropertyValueType);
      App.Storage.setValue("storLogIndex", $.iMyLogIndex as App.PropertyValueType);
    }
  }


  //
  // FUNCTIONS: self (fields)
  //

  // Record

  function setSpO2(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setSpO2($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_SpO2.setData(_fValue);
    }
  }

  function setBarometricAltitude(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setBarometricAltitude($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_BarometricAltitude.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setVerticalSpeed(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setVerticalSpeed($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_VerticalSpeed.setData(_fValue * self.fUnitCoefficient_VerticalSpeed);
    }
  }

  function setRateOfTurn(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setRateOfTurn($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_RateOfTurn.setData(_fValue * self.fUnitCoefficient_RateOfTurn);
    }
  }

  function setAcceleration(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setAcceleration($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_Acceleration.setData(_fValue);
    }
  }

  // Session

  function setGlobalDistance(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalDistance($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_GlobalDistance.setData(_fValue * self.fUnitCoefficient_Distance);
    }
  }

  function setGlobalAscent(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalAscent($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_GlobalAscent.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setGlobalElapsedAscent(_iElapsed as Number?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalElapsedAscent($1$)", [_iElapsed]));
    self.oFitField_GlobalElapsedAscent.setData(LangUtils.formatElapsed(_iElapsed, true));
  }

  function setGlobalAltitudeMin(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalAltitudeMin($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_GlobalAltitudeMin.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setGlobalTimeAltitudeMin(_oTime as Time.Moment?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalTimeAltitudeMin($1$)", [_oTime.value()]));
    self.oFitField_GlobalTimeAltitudeMin.setData(LangUtils.formatTime(_oTime, self.bUnitCoefficient_TimeUTC, true));
  }

  function setGlobalAltitudeMax(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalAltitudeMax($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_GlobalAltitudeMax.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setGlobalTimeAltitudeMax(_oTime as Time.Moment?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalTimeAltitudeMax($1$)", [_oTime.value()]));
    self.oFitField_GlobalTimeAltitudeMax.setData(LangUtils.formatTime(_oTime, self.bUnitCoefficient_TimeUTC, true));
  }

}
