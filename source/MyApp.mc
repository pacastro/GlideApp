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
using Toybox.Application as App;
using Toybox.Attention as Attn;
using Toybox.Communications as Comm;
using Toybox.Position as Pos;
using Toybox.Sensor;
using Toybox.SensorHistory as SH;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi as Ui;


using Toybox.Time.Gregorian;

//
// GLOBALS
//

// Application settings
var oMySettings as MySettings = new MySettings() ;

// (Last) position location/altitude
var oMyPositionLocation as Pos.Location?;
var fMyPositionAltitude as Float = NaN;

// Sensors filter
var oMyKalmanFilter as MyKalmanFilter = new MyKalmanFilter();

// Internal altimeter
var oMyAltimeter as MyAltimeter = new MyAltimeter();
var bAltimeter as Boolean = (Activity.getActivityInfo() has :rawAmbientPressure);

// Processing logic
var oMyProcessing as MyProcessing = new MyProcessing();
var oMyTimeStart as Time.Moment = Time.now();

// Log
var iMyLogIndex as Number = -1;

// Chart
var oChartModelAlt = new MyChartModel();
var oChartModelAsc = new MyChartModel();
var oChartModelCrt = new MyChartModel();
var oChartModelSpd = new MyChartModel();
var oChartModelHR = new MyChartModel();
var oChartModelg = new MyChartModel();

var bChartReset = false;
var bRangeChange = false;

// Map
var bMHChange = false;

// Activity session (recording)
var oMyActivity as MyActivity?;
var bActStart = false;
var bActStop = false;
var bActPause = false;
var oDispTime as Time.Moment = Time.now();

// var oProgBarTime = null;

// Current view
var oMyView as MyView?;
var iViewGenOxIdx = 1;

// Show Timer
var bViewTimer = false;
var oTimeLastTimer = new Time.Moment(Time.now().value() + 60 * 60);

//
// CONSTANTS
//

// Storage slots
const MY_STORAGE_SLOTS = 100;

// No-value strings
// NOTE: Those ought to be defined in the MyApp class like other constants but code then fails with an "Invalid Value" error when called upon; BUG?
const MY_NOVALUE_BLANK = "";
const MY_NOVALUE_LEN2 = "--";
const MY_NOVALUE_LEN3 = "---";
const MY_NOVALUE_LEN4 = "----";
const MY_NOVALUE_LEN6 = "--.----";


//
// CLASS
//

class MyApp extends App.AppBase {

  //
  // CONSTANTS
  //

  //
  // VARIABLES
  //

  // Timers
  // ... UI update
  private var oUpdateTimer as Timer.Timer?;
  private var iUpdateLastEpoch as Number = 0;
  // ... tones
  private var oTonesTimer as Timer.Timer?;
  private var iTonesTick as Number = 1000;
  private var iTonesLastTick as Number = 0;

  // Tones
  private var iTones as Boolean = false;
  private var iVibrations as Boolean = false;
  private var bSinkToneTriggered as Boolean = false;


  //
  // FUNCTIONS: App.AppBase (override/implement)
  //

  function initialize() {
    AppBase.initialize();

    // Log
    // ... last entry index
    var iLogIndex = App.Storage.getValue("storLogIndex") as Number?;
    if(iLogIndex != null) {
      $.iMyLogIndex = iLogIndex;
    }

    // Timers
    $.oMyTimeStart = Time.now();

  }

  function onStart(state) {
    // Sys.println("DEBUG: MyApp.onStart()");

    // Load settings
    self.loadSettings();

    // Enable sensor events
    Sensor.setEnabledSensors([] as Array<Sensor.SensorType>);  // ... we need just the acceleration
    // Sensor.setEnabledSensors([Sensor.SENSOR_ONBOARD_HEARTRATE, Sensor.SENSOR_ONBOARD_PULSE_OXIMETRY]);
    Sensor.enableSensorEvents(method(:onSensorEvent));
    
    // Enable position events
    self.enablePositioning();

    // Start UI update timer (every multiple of 5 seconds, to save energy)
    // NOTE: in normal circumstances, UI update will be triggered by position events (every ~1 second)
    self.oUpdateTimer = new Timer.Timer();
    // var iUpdateTimerDelay = (60-Sys.getClockTime().sec)%5;
    // Sys.println(Sys.getClockTime().sec + "  iUpD  " + iUpdateTimerDelay);
    // if(iUpdateTimerDelay > 0) {
    //   (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer_init), 1000*iUpdateTimerDelay, false);
    // }
    // else {
      (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 5000, true);
    // }
  }

  function onStop(state) {
    //Sys.println("DEBUG: MyApp.onStop()");

    // Stop timers
    // ... UI update
    if(self.oUpdateTimer != null) {
      (self.oUpdateTimer as Timer.Timer).stop();
      self.oUpdateTimer = null;
    }
    // ... tones
    if(self.oTonesTimer != null) {
      (self.oTonesTimer as Timer.Timer).stop();
      self.oTonesTimer = null;
    }

    // Disable position events
    Pos.enableLocationEvents(Pos.LOCATION_DISABLE, method(:onLocationEvent));

    // Disable sensor events
    Sensor.enableSensorEvents(null);
  }

  function getInitialView() {
    //Sys.println("DEBUG: MyApp.getInitialView()");

    return [ new MyViewGeneral(), new MyViewGeneralDelegate() ];
  }

  function onSettingsChanged() {
    // Sys.println("DEBUG: MyApp.onSettingsChanged()");
    self.loadSettings();
    self.updateUi(Time.now().value());
    if($.oMyProcessing.bIsPrevious == 5) {
      Ui.switchToView(new MyViewTimers(), new MyViewTimersDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }


  //
  // FUNCTIONS: self
  //

  function loadSettings() as Void {
    //Sys.println("DEBUG: MyApp.loadSettings()");

    // Load settings
    $.oMySettings.load();

    // Apply settings

    $.oMyAltimeter.importSettings();
    self.enablePositioning();

    // ... tones
    self.muteTones();
  }

  function onSensorEvent(_oInfo as Sensor.Info) as Void {
    //Sys.println("DEBUG: MyApp.onSensorEvent());
    var oTimeNow = Time.now();
    var iEpoch = oTimeNow.value();

    // Process altimeter data
    var oActivityInfo = Activity.getActivityInfo();  // ... we need *raw ambient* pressure
    if(oActivityInfo != null) {
      if(oActivityInfo has :rawAmbientPressure and oActivityInfo.rawAmbientPressure != null) {
        $.oMyAltimeter.setQFE(oActivityInfo.rawAmbientPressure as Float);
        //Sys.println(format("First altimeter run $1$", [$.oMyAltimeter.bFirstRun]));        
        //Initial automated calibration based on watch altitude
        if($.oMyAltimeter.bFirstRun && _oInfo has :altitude && _oInfo.altitude != null) {
          $.oMyAltimeter.bFirstRun = false;
          $.oMyAltimeter.setAltitudeActual(_oInfo.altitude);
          $.oMySettings.saveAltimeterCalibrationQNH($.oMyAltimeter.fQNH);
        }
      }
    }

    // Process sensor data
    $.oMyProcessing.processSensorInfo(_oInfo, Time.now().value());
    if($.oMyActivity != null) {
      ($.oMyActivity as MyActivity).processSensorInfo(_oInfo, iEpoch, oTimeNow); // Log Altitude
    }

    // Save FIT fields
    if($.oMyActivity != null) {
      ($.oMyActivity as MyActivity).setSpO2($.oMyProcessing.iOxFit);
      ($.oMyActivity as MyActivity).setBarometricAltitude($.oMyProcessing.fAltitude);
      ($.oMyActivity as MyActivity).setVerticalSpeed($.oMyProcessing.fVariometer);
      ($.oMyActivity as MyActivity).setRateOfTurn($.oMyProcessing.fRateOfTurn);
      ($.oMyActivity as MyActivity).setAcceleration($.oMyProcessing.fAcceleration);
    }

    // Chart
    if((($.oMyActivity != null) || !($.oMySettings.bChartShow)) && ($.oMyProcessing.fAltitude != null)) {
      oChartModelAlt.new_value(_oInfo.altitude);
      oChartModelAsc.new_value(($.oMyActivity != null)?$.oMyActivity.fGlobalAscent:0);
      oChartModelCrt.new_value($.oMyProcessing.fVariometer_filtered);
      oChartModelSpd.new_value($.oMyProcessing.fGroundSpeed);
      oChartModelHR.new_value($.oMyProcessing.iHR);
      oChartModelg.new_value($.oMyProcessing.fAcceleration);
    }

    if(bChartReset) {
      oChartModelAlt.reset();
      oChartModelAsc.reset();
      oChartModelCrt.reset();
      oChartModelSpd.reset();
      oChartModelHR.reset();
      oChartModelg.reset();
      bChartReset = false;
    }
  }


  function enablePositioning() as Void {
    var callback = method(:onLocationEvent);

    // use ConnectIQ 3.3.6 :configuration option
    if (Pos has :hasConfigurationSupport) {

        var options = {
            :acquisitionType => Pos.LOCATION_CONTINUOUS
        };

        if (Pos has :POSITIONING_MODE_AVIATION) {
           options[:mode] = Pos.POSITIONING_MODE_AVIATION;
        }

        // pick a configuration that is supported
        var configurations = [
            Pos.CONFIGURATION_SAT_IQ,
            Pos.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5,
            Pos.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1,
            Pos.CONFIGURATION_GPS_GLONASS,
            Pos.CONFIGURATION_GPS_GALILEO,
            Pos.CONFIGURATION_GPS_BEIDOU,
            Pos.CONFIGURATION_GPS,
        ];

        for (var i = 0; i < configurations.size(); ++i) {
            var configuration = configurations[i];

            if (Pos.hasConfigurationSupport( configuration )) {
                options[:configuration] = configuration;

                try {
                  Pos.enableLocationEvents(options, callback);
                  return;                
                } catch(e) {
                  //Just keep going
                }
            }
        }
    }

    // CIQ < 3.2.0
    Pos.enableLocationEvents(Pos.LOCATION_CONTINUOUS, callback);
  }


  function onLocationEvent(_oInfo as Pos.Info) as Void {
    //Sys.println("DEBUG: MyApp.onLocationEvent()");
    var oTimeNow = Time.now();
    var iEpoch = oTimeNow.value();

    // Save location
    if(_oInfo has :position) {
      $.oMyPositionLocation = _oInfo.position;
    }

    // Save altitude
    if(_oInfo has :altitude and _oInfo.altitude != null) {
      $.fMyPositionAltitude = _oInfo.altitude as Float;
    }

    // Process position data
    $.oMyProcessing.processPositionInfo(_oInfo, iEpoch);
    if($.oMyActivity != null) {
      ($.oMyActivity as MyActivity).processPositionInfo(_oInfo, iEpoch, oTimeNow); // Log Distance
    }

    // Automatic Activity recording
    if($.oMySettings.bActivityAutoStart and LangUtils.notNaN($.oMyProcessing.fGroundSpeed)) {
      if(($.oMyActivity == null)&&(Time.now().subtract(oDispTime).value()>1)) { // autostart 1 sec delay for no falsestarts (superfast autostarts)
        if($.oMySettings.fActivityAutoSpeedStart > 0.0f
           and $.oMyProcessing.fGroundSpeed > $.oMySettings.fActivityAutoSpeedStart) {
          $.oMyActivity = new MyActivity();
          $.oMyActivity.start();
        }
      }
    }

    // UI update
    self.updateUi(iEpoch);
  }

  // function onUpdateTimer_init() as Void {
  //   //Sys.println("DEBUG: MyApp.onUpdateTimer_init()");
  //   self.onUpdateTimer();
  //   self.oUpdateTimer = new Timer.Timer();
  //   (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 5000, true);
  // }

  function onUpdateTimer() as Void {
    // Sys.println("DEBUG: MyApp.onUpdateTimer()");
    var iEpoch = Time.now().value();
    if(iEpoch-self.iUpdateLastEpoch > 1) {
      self.updateUi(iEpoch);
    }
  }

  function onTonesTimer() as Void {
    //Sys.println("DEBUG: MyApp.onTonesTimer()");
    self.playTones();
    self.iTonesTick++;
  }

  function updateUi(_iEpoch as Number) as Void {
    // Sys.println("DEBUG: MyApp.updateUi()");

    // Check sensor data age
    if($.oMyProcessing.iSensorEpoch >= 0 and _iEpoch-$.oMyProcessing.iSensorEpoch > 10) {
      $.oMyProcessing.resetSensorData();
      $.oMyAltimeter.reset();
    }

    // Check position data age
    if($.oMyProcessing.iPositionEpoch >= 0 and _iEpoch-$.oMyProcessing.iPositionEpoch > 10) {
      $.oMyProcessing.resetPositionData();
    }

    // Update UI
    if($.oMyView != null) {
      ($.oMyView as MyView).updateUi();
      self.iUpdateLastEpoch = _iEpoch;
    }

    // if((oProgBarTime!=null)&&Time.now().subtract(oProgBarTime).value()>=1) {
    //   $.ResetProgressDelegate.barCallback();
    // } // if needed maybe better onSensorEvent? (free 1 timer)
  }

  function muteTones() as Void {
    // Stop tones timers
    if(self.oTonesTimer != null) {
      (self.oTonesTimer as Timer.Timer).stop();
      self.oTonesTimer = null;
    }
  }

  function unmuteTones() as Void {
    // Enable tones
    self.iTones = false;
    if(Toybox.Attention has :playTone) {
      if($.oMySettings.bSoundsVariometerTones) {
        self.iTones = true;
      }
    }

    if(Toybox.Attention has :vibrate) {
      if($.oMySettings.bVariometerVibrations) {
        self.iVibrations = true;
      }
    }

    // Start tones timer
    // NOTE: For variometer tones, we need a 10Hz <-> 100ms resolution;
    if(self.iTones || self.iVibrations) {
      self.iTonesTick = 1000;
      self.iTonesLastTick = 0;
      self.oTonesTimer = new Timer.Timer();
      self.oTonesTimer.start(method(:onTonesTimer), 100, true);
    }
  }

  function playTones() as Void {
    //Sys.println(format("DEBUG: MyApp.playTones() @ $1$", [self.iTonesTick]));
    // Variometer
    // ALGO: Tones "tick" is 100ms; I try to do a curve that is similar to the Skybean vario
    // Medium curve in terms of tone length, pause, and one frequency.
    // Tones need to be more frequent than in GliderSK even at low climb rates to be able to
    // properly map thermals (especially broken up thermals)
    if(self.iTones || self.iVibrations) {
      // Alert tones (priority over variometer)
      if(($.oMyProcessing.iOx != null) && $.oMySettings.bOxVibrate && ($.oMyProcessing.iOx <= $.oMySettings.iOxCritical)) {
        if(Time.now().value() % 3 == 0) {
          var vibeData = [new Attention.VibeProfile(80, 200),
                          new Attention.VibeProfile(0, 600),
                          new Attention.VibeProfile(50, 200)];
          Attention.vibrate(vibeData);
        }
        return;
      }

      var fValue = $.oMyProcessing.fVariometer_filtered;
      var iDeltaTick = (self.iTonesTick-self.iTonesLastTick) > 8 ? 8 : self.iTonesTick-self.iTonesLastTick;
      if(fValue >= $.oMySettings.fMinimumClimb && iDeltaTick >= 8.0f - fValue) {
        //Sys.println(format("DEBUG: playTone: variometer @ $1$", [self.iTonesTick]));
        var iToneLength = (iDeltaTick > 2) ? iDeltaTick * 50 - 100: 50;
        if(self.iTones) {
          var iToneFrequency = (400 + fValue * 100) > 1100 ? 1100 : (400 + fValue * 100).toNumber();
          var toneProfile = [new Attn.ToneProfile(iToneFrequency, iToneLength)]; //contrary to Garmin API Doc, first parameter seems to be frequency, and second length
          Attn.playTone({:toneProfile=>toneProfile});
        }
        if(self.iVibrations) {
          var vibeData = [new Attn.VibeProfile(100, (iToneLength > 200) ? iToneLength / 2 : 50)]; //Keeping vibration length shorter than tone for battery and wrist!
          Attn.vibrate(vibeData);
        }
        self.iTonesLastTick = self.iTonesTick;
        return;
      }
      else if(fValue <= $.oMySettings.fMinimumSink && !self.bSinkToneTriggered && self.iTones) {
        var toneProfile = [new Attn.ToneProfile(220, 2000)];
        Attn.playTone({:toneProfile=>toneProfile});
        self.bSinkToneTriggered = true;
      }
      //Reset minimum sink tone if we get significantly above it
      if(fValue >= $.oMySettings.fMinimumSink + 1.0f && self.bSinkToneTriggered) {
        self.bSinkToneTriggered = false;
      }
    }
  }

  function clearStorageLogs() as Void {
    //Sys.println("DEBUG: MyApp.clearStorageLogs()");
    for(var n=0; n<$.MY_STORAGE_SLOTS; n++) {
      var s = n.format("%02d");
      App.Storage.deleteValue(format("storLog$1$", [s]));
    }
    App.Storage.deleteValue("storLogIndex");
    $.iMyLogIndex = -1;
    if(Toybox.Attention has :playTone) {
        Attn.playTone(Attn.TONE_RESET);
    }
  }

  function calculateScaleBar(iMaxBarSize as Lang.Number, fPlotScale as Lang.Float, sUnit as Lang.String, fUnitCoefficient as Lang.Float) as Void {
    var iMinBarSize = 10;
    var fMinBarScale = iMinBarSize * fUnitCoefficient * fPlotScale;
    var fMaxBarScale = iMaxBarSize * fUnitCoefficient * fPlotScale;

    var aiSizeSnap = [10, 5, 2, 1];

    // Try to find a nice size
    for (var i = 0; i < aiSizeSnap.size(); i++) {
      var iSize = aiSizeSnap[i];
      var iSizeSnap = (fMaxBarScale / iSize).toNumber() * iSize;
      if (iSizeSnap >= fMinBarScale && iSizeSnap <= fMaxBarScale) {
        var iBarSize = iMaxBarSize * iSizeSnap / fMaxBarScale;
        // return [iBarSize.toNumber(), iSizeSnap + sUnit];
        $.iScaleBarSize = iBarSize.toNumber();
        $.sScaleBarUnit = iSizeSnap + sUnit;
        return;
      }
    }

    // Failed, try smaller unit
    if ($.oMySettings.sUnitDistance.equals("nm") || $.oMySettings.sUnitDistance.equals("sm")) {
      sUnit = "ft";
      fUnitCoefficient = 3.280839895f;
    } else if ($.oMySettings.sUnitDistance.equals("km")) {
      sUnit = "m";
      fUnitCoefficient = 1.0f;
    } else {
      // "Unreachable" Unknown unit...
      // return [0, "ERR"];
      $.iScaleBarSize = 0;
      $.sScaleBarUnit = "ERR";
      return;
    }

    aiSizeSnap = [1000, 500, 200, 100, 50, 10];
    fMinBarScale = iMinBarSize * fUnitCoefficient * fPlotScale;
    fMaxBarScale = iMaxBarSize * fUnitCoefficient * fPlotScale;

    // Try to find a nice size with the smaller unit
    for (var i = 0; i < aiSizeSnap.size(); i++) {
      var iSize = aiSizeSnap[i];
      var iSizeSnap = (fMaxBarScale / iSize).toNumber() * iSize;
      if (iSizeSnap >= fMinBarScale && iSizeSnap <= fMaxBarScale) {
        var iBarSize = iMaxBarSize * iSizeSnap / fMaxBarScale;
        // return [iBarSize.toNumber(), iSizeSnap + sUnit];
        $.iScaleBarSize = iBarSize.toNumber();
        $.sScaleBarUnit = iSizeSnap + sUnit;
        return;
      }
    }

    // Failed again, do not try snapping
    // return [iMaxBarSize, fMaxBarScale.format("%.0f") + sUnit];
    $.iScaleBarSize = iMaxBarSize;
    $.sScaleBarUnit = fMaxBarScale.format("%.0f") + sUnit;
  }

}
