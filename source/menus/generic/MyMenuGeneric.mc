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
using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;


class MyMenu2Generic extends Ui.Menu2 {

  private var menu as Symbol = :menuNone;
  (:icon) var NoExclude as Symbol = :NoExclude;
  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //
  function initialize(_menu as Symbol, _focus as Number) {
    Menu2.initialize({:focus=>_focus});
    menu = _menu;
    $.oMySettings.load();
    (App.getApp() as MyApp).calculateScaleBar($.iPlotScaleBarSize, $.oMySettings.fVariometerPlotScale, $.oMySettings.sUnitDistance, $.oMySettings.fUnitDistanceCoefficient);
    var sFormat = $.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f ? "%.1f" : "%.0f";
  
    if(menu == :menuSettings) {
      Menu2.setTitle((self has :NoExclude)?(new $.DrawableMenu(:title)):Rez.Strings.titleSettings);
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsGeneral, null, :menuSettingsGeneral, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsAltimeter, null, :menuSettingsAltimeter, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsVariometer, null, :menuSettingsVariometer, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsSounds, null, :menuSettingsSounds, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsActivity, null, :menuSettingsActivity, {}));
      if($.oMySettings.loadGeneralMapDisplay()) {
        Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsMap, null, :menuSettingsMap, {}));
      }
      if($.oMySettings.loadGeneralChartDisplay()) {
        Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsChart, null, :menuSettingsChart, {}));
      }
      if($.oMySettings.loadGeneralOxDisplay()) {
        Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsOx, null, :menuSettingsOx, {}));
      }
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsUnits, null, :menuSettingsUnits, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleInfo, null, :menuInfo, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleAbout, null, :menuAbout, {}));
    }

    else if(menu == :menuSettingsGeneral) {
      Menu2.setTitle(Rez.Strings.titleSettingsGeneral);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleGeneralBackgroundColor, {:enabled=>"Black", :disabled=>"White"}, :menuGeneralBackgroundColor, ($.oMySettings.iGeneralBackgroundColor?false:true), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleGeneralOxDisplay, null, :menuGeneralOxDisplay, $.oMySettings.bGeneralOxDisplay, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleGeneralVarioDisplay, null, :menuGeneralVarioDisplay, $.oMySettings.bGeneralVarioDisplay, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      if(Ui has :MapView) {
        Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleGeneralMapDisplay, null, :menuGeneralMapDisplay, $.oMySettings.bGeneralMapDisplay, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      }
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleGeneralChartDisplay, null, :menuGeneralChartDisplay, $.oMySettings.bGeneralChartDisplay, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleGeneralETDisplay, null, :menuGeneralETDisplay, $.oMySettings.bGeneralETDisplay, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleStorageClearLastLog, null, :menuStorageClearLastLog, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleStorageClearLogs, null, :menuStorageClearLogs, {}));
    }

    else if(menu == :menuSettingsAltimeter) {
      Menu2.setTitle(Rez.Strings.titleSettingsAltimeter);
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleAltimeterCalibration, null, :menuAltimeterCalibration, {}));
    }
    else if(menu == :menuAltimeterCalibration) {
      Menu2.setTitle(Rez.Strings.titleAltimeterCalibration);
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleAltimeterCalibrationQNH, format("$1$ $2$", [($.oMySettings.fAltimeterCalibrationQNH*$.oMySettings.fUnitPressureCoefficient).format("%.2f"), $.oMySettings.sUnitPressure]), :menuAltimeterCalibrationQNH, {}));
      if(LangUtils.notNaN($.oMyAltimeter.fAltitudeActual)) {
        Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleAltimeterCalibrationElevation, format("baro: $1$ $2$", [($.oMyAltimeter.fAltitudeActual*$.oMySettings.fUnitElevationCoefficient).format("%.0f"), $.oMySettings.sUnitElevation]), :menuAltimeterCalibrationElevation, {}));
      }
    }

    else if(menu == :menuSettingsVariometer) {
      Menu2.setTitle(Rez.Strings.titleSettingsVariometer);
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleVariometerRange, format("$1$ $2$", [($.oMySettings.fVariometerRange*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]), :menuVariometerRange, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleVariometerSmoothing, $.oMySettings.fVariometerSmoothingName, :menuVariometerSmoothing, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleVariometerAvgTime, $.oMySettings.fVariometerAvgTime == 0 ? "current data" : ($.oMySettings.fVariometerAvgTime.format("%.0f") + " s"), :menuVariometerAvgTime, {}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVariometerAvgLast, {:enabled=>"Avg last Thermal", :disabled=>"Avg last n sec"}, :menuVariometerAvgLast, $.oMySettings.bVariometerAvgLast, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVariometerdE, null, :menuVariometerdE, $.oMySettings.bVariometerdE, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVariometerAutoThermal, null, :menuVariometerAutoThermal, $.oMySettings.bVariometerAutoThermal, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVariometerThermalDetect, null, :menuVariometerThermalDetect, $.oMySettings.bVariometerThermalDetect, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVariometerPlotOrientation, {:enabled=>"North Up", :disabled=>"Heading Up"}, :menuVariometerPlotOrientation, ($.oMySettings.iVariometerPlotOrientation?false:true), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleVariometerPlotRange, format("$1$ min", [$.oMySettings.iVariometerPlotRange]), :menuVariometerPlotRange, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleVariometerPlotZoom, format("$1$ m/pixel", [$.oMySettings.fVariometerPlotScale.format("%.0f")]), :menuVariometerPlotZoom, {}));
    }

    else if(menu == :menuSettingsSounds) {
      Menu2.setTitle(Rez.Strings.titleSettingsSounds);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleSoundsVariometerTones, null, :menuSoundsVariometerTones, $.oMySettings.bSoundsVariometerTones, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVariometerVibrations, null, :menuVariometerVibrations, $.oMySettings.bVariometerVibrations, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleMinimumClimb, format("$1$ $2$", [($.oMySettings.fMinimumClimb*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]), :menuMinimumClimb, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleMinimumSink, format("$1$ $2$", [($.oMySettings.fMinimumSink*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]), :menuMinimumSink, {}));
    }

    else if(menu == :menuSettingsActivity) {
      Menu2.setTitle(Rez.Strings.titleSettingsActivity);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleActivityAutoStart, null, :menuActivityAutoStart, $.oMySettings.bActivityAutoStart, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleActivityAutoSpeedStart, format("$1$ $2$", [($.oMySettings.fActivityAutoSpeedStart*$.oMySettings.fUnitHorizontalSpeedCoefficient).format("%.0f"), $.oMySettings.sUnitHorizontalSpeed]), :menuActivityAutoSpeedStart, {}));
    }

    else if(menu == :menuSettingsChart) {
      var n = 0;
      for(var i = 0; i < 6; i++) { n += App.Properties.getValue("userChartVars").toUtf8Array()[i] == 49 ? 1 : 0; }
      Menu2.setTitle(Rez.Strings.titleSettingsChart);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleChartMinMax, null, :menuChartMinMax, $.oMySettings.bChartMinMax, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleChartValue, null, :menuChartValue, $.oMySettings.bChartValue, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleChartShow, {:enabled=>"activity recording", :disabled=>"always on"}, :menuChartShow, $.oMySettings.bChartShow, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleChartRange, {:enabled=>"4 hrs", :disabled=>"30 min (chart reset)"}, :menuChartRange, $.oMySettings.bChartRange, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleChartDisplay, $.oMySettings.sChartDisplay, :menuChartDisplay, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleChartVars, format("$1$/6", [n]), :menuChartVars, {}));
    }

    else if(menu == :menuSettingsMap) {
      Menu2.setTitle(Rez.Strings.titleSettingsMap);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleMapHeader, null, :menuMapHeader, $.oMySettings.bMapHeader, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleMapData, null, :menuMapData, $.oMySettings.bMapData, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      // Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleMapTrack, null, :menuMapTrack, $.oMySettings.bMapTrack, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
    }

    else if(menu == :menuSettingsOx) {
      Menu2.setTitle(Rez.Strings.titleSettingsOx);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleOxMeasure, {:enabled=>"over Caution elev", :disabled=>"always on"}, :menuOxMeasure, $.oMySettings.bOxMeasure, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleOxElevation, format("$1$ $2$", [($.oMySettings.iOxElevation*$.oMySettings.fUnitElevationCoefficient).format("%.0f"), $.oMySettings.sUnitElevation]), :menuOxElevation, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleOxCritical, format("$1$ %", [$.oMySettings.iOxCritical]), :menuOxCritical, {}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleOxVibrate, null, :menuOxVibrate, $.oMySettings.bOxVibrate, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
    }

    else if(menu == :menuSettingsUnits) {
      Menu2.setTitle(Rez.Strings.titleSettingsUnits);
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitDistance, format("$1$$2$", [$.oMySettings.sUnitDistance, ($.oMySettings.iUnitDistance < 0 ? "  (auto)" : "")]), :menuUnitDistance, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitElevation, format("$1$$2$", [$.oMySettings.sUnitElevation, ($.oMySettings.iUnitElevation < 0 ? "  (auto)" : "")]), :menuUnitElevation, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitPressure, format("$1$$2$", [$.oMySettings.sUnitPressure, ($.oMySettings.iUnitPressure < 0 ? "  (auto)" : "")]), :menuUnitPressure, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitRateOfTurn, $.oMySettings.sUnitRateOfTurn, :menuUnitRateOfTurn, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitWindSpeed, format("$1$$2$", [$.oMySettings.sUnitWindSpeed, ($.oMySettings.iUnitWindSpeed < 0 ? "  (auto)" : "")]), :menuUnitWindSpeed, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitDirection, $.oMySettings.sUnitDirection, :menuUnitDirection, {}));   
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitHeading, $.oMySettings.sUnitHeading, :menuUnitHeading, {}));    
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitTimeUTC, $.oMySettings.sUnitTime, :menuUnitTimeUTC, {})); 
    }

    else if(menu == :menuAbout) {
      Menu2.setTitle(Rez.Strings.titleAbout);
      Menu2.addItem(new Ui.MenuItem(format("$1$: $2$", [Ui.loadResource(Rez.Strings.titleVersion), Ui.loadResource(Rez.Strings.AppVersion)]), null, :aboutVersion, {}));
      Menu2.addItem(new Ui.MenuItem(format("$1$: GPL 3.0", [Ui.loadResource(Rez.Strings.titleLicense)]), null, :aboutLicense, {}));
      Menu2.addItem(new Ui.MenuItem(format("$1$: Pablo Castro", [Ui.loadResource(Rez.Strings.titleAuthor)]), null, :aboutAuthor, {}));
      Menu2.addItem(new Ui.MenuItem("Based on My Vario Lite", null, :aboutGliderSK, {}));
      Menu2.addItem(new Ui.MenuItem(format("$1$: Yannick Dutertre", [Ui.loadResource(Rez.Strings.titleAuthor)]), null, :aboutAuthor, {}));
      Menu2.addItem(new Ui.MenuItem("Originaly based on Glider SK", null, :aboutGliderSK, {}));
      Menu2.addItem(new Ui.MenuItem(format("$1$: Cédric Dufour", [Ui.loadResource(Rez.Strings.titleAuthor)]), null, :aboutAuthor, {}));
    }

    if(menu == :menuActivity) {
      Menu2.setTitle(Rez.Strings.titleActivity);
      if($.oMyActivity != null) {
        if(($.oMyActivity as MyActivity).isRecording()) {
          Menu2.addItem(new Ui.IconMenuItem(Rez.Strings.titleActivityPause, null, :menuActivityPause, (new $.DrawableMenu(:pause)), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
        }
        else {
          Menu2.addItem(new Ui.IconMenuItem(Rez.Strings.titleActivityResume, null, :menuActivityResume, (new $.DrawableMenu(:resume)), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
        }
        Menu2.addItem(new Ui.IconMenuItem(Rez.Strings.titleActivitySave, null, :menuActivitySave, (new $.DrawableMenu(:save)), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
        Menu2.addItem(new Ui.IconMenuItem(Rez.Strings.titleActivityDiscard, null, :menuActivityDiscard, (new $.DrawableMenu(:discard)), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
      }
    }
  }
}

class MyMenu2GenericDelegate extends Ui.Menu2InputDelegate {

  //
  // VARIABLES
  //

  private var menu as Symbol = :menuNone;
  private var check as Boolean = false;
  (:icon) var NoExclude as Symbol = :NoExclude;

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize(_menu as Symbol, _check as Boolean) {
    Menu2InputDelegate.initialize();
    self.menu = _menu;
    self.check = _check;
  }

  function onSelect(_item) {
    var item = self.check ? _item as Ui.CheckboxMenuItem : _item as Ui.ToggleMenuItem;
    var itemId = self.check ? item.getId() as Number : _item.getId() as Symbol;
    if(self.menu == :menuSettings) {
      if(itemId == :menuInfo) {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.switchToView(new MyViewInfo(), new MyViewInfoDelegate(), Ui.SLIDE_LEFT);
      }
      else {
        Ui.pushView(new MyMenu2Generic(itemId, 0), new MyMenu2GenericDelegate(itemId, false), Ui.SLIDE_LEFT);
      }
    }

    else if(self.menu == :menuSettingsGeneral) {
      if(itemId == :menuGeneralBackgroundColor) {
        $.oMySettings.saveGeneralBackgroundColor(item.isEnabled()?0:1);
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.popView(Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuGeneralOxDisplay) {
        $.oMySettings.saveGeneralOxDisplay(item.isEnabled());
      }
      else if(itemId == :menuGeneralVarioDisplay) {
        $.oMySettings.saveGeneralVarioDisplay(item.isEnabled());
      }
      else if(itemId == :menuGeneralMapDisplay) {
        $.oMySettings.saveGeneralMapDisplay(item.isEnabled());
      }
      else if(itemId == :menuGeneralChartDisplay) {
        $.oMySettings.saveGeneralChartDisplay(item.isEnabled());
        if($.oMyProcessing.iIsCurrent == 5) {
          if(App.Properties.getValue("userChartVars").toNumber() == 0) { App.Properties.setValue("userChartVars", "100000"); chartRun(-1); }
          Ui.popView(Ui.SLIDE_IMMEDIATE);
          Ui.popView(Ui.SLIDE_IMMEDIATE);
          Ui.switchToView(new MyViewTimers(), new MyViewTimersDelegate(), Ui.SLIDE_IMMEDIATE);
        }
      }
      else if(itemId == :menuGeneralETDisplay) {
        $.oMySettings.saveGeneralETDisplay(item.isEnabled());
      }
      else if(itemId == :menuStorageClearLastLog) {
        Ui.pushView((self has :NoExclude)?(new MyMenuConfirmDiscard()) : (new Ui.Confirmation(Ui.loadResource(Rez.Strings.titleActivityDiscard) + "?")),
                    (self has :NoExclude)?(new MyMenuConfirmDiscardDelegate(:actionClearLastLog, false)) : (new MyMenuGenericConfirmDelegate(:contextStorage, :actionClearLastLog, false)),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuStorageClearLogs) {
        Ui.pushView((self has :NoExclude)?(new MyMenuConfirmDiscard()) : (new Ui.Confirmation(Ui.loadResource(Rez.Strings.titleActivityDiscard) + "?")),
                    (self has :NoExclude)?(new MyMenuConfirmDiscardDelegate(:actionClearLogs, false)) : (new MyMenuGenericConfirmDelegate(:contextStorage, :actionClearLogs, false)),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsAltimeter) {
      if(itemId == :menuAltimeterCalibration) {
        Ui.pushView(new MyMenu2Generic(:menuAltimeterCalibration, 0),
                    new MyMenu2GenericDelegate(:menuAltimeterCalibration, false),
                    Ui.SLIDE_IMMEDIATE);
      }
    }
    else if(self.menu == :menuAltimeterCalibration) {
      if(itemId == :menuAltimeterCalibrationQNH) {
        Ui.pushView(new MyPickerGeneric(:contextSettings, :itemAltimeterCalibration, :pressure),
                    new MyPickerGenericDelegate(:contextSettings, :itemAltimeterCalibration, self.menu, :pressure),
                    Ui.SLIDE_LEFT);
      }
      else if(itemId == :menuAltimeterCalibrationElevation) {
        Ui.pushView(new MyPickerGeneric(:contextSettings, :itemAltimeterCalibration, :elevation),
                    new MyPickerGenericDelegate(:contextSettings, :itemAltimeterCalibration, self.menu, :elevation),
                    Ui.SLIDE_LEFT);
      }
    }

    else if(self.menu == :menuSettingsVariometer) {
      if(itemId == :menuVariometerRange) {
        var iUnitIdx = ($.oMySettings.loadVariometerRange() + 1) % 3;
        $.oMySettings.saveVariometerRange(iUnitIdx as Number);
        Ui.switchToView(new MyMenu2Generic(:menuSettingsVariometer, 0), new MyMenu2GenericDelegate(:menuSettingsVariometer, false), Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuVariometerSmoothing) {
        var iUnitIdx = ($.oMySettings.loadVariometerSmoothing() + 1) % 4;
        $.oMySettings.saveVariometerSmoothing(iUnitIdx as Number);
        Ui.switchToView(new MyMenu2Generic(:menuSettingsVariometer, 1), new MyMenu2GenericDelegate(:menuSettingsVariometer, false), Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuVariometerAvgTime) {
        var iUnitIdx = ($.oMySettings.loadVariometerAvgTime() + 1) % 4;
        $.oMySettings.saveVariometerAvgTime(iUnitIdx as Number);
        Ui.switchToView(new MyMenu2Generic(:menuSettingsVariometer, 2), new MyMenu2GenericDelegate(:menuSettingsVariometer, false), Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuVariometerAvgLast) {
        $.oMySettings.saveVariometerAvgLast(item.isEnabled());
      }
      else if(itemId == :menuVariometerdE) {
        $.oMySettings.saveVariometerdE(item.isEnabled());
      }
      else if(itemId == :menuVariometerAutoThermal) {
        $.oMySettings.saveVariometerAutoThermal(item.isEnabled());
      }
      else if(itemId == :menuVariometerThermalDetect) {
        $.oMySettings.saveVariometerThermalDetect(item.isEnabled());
      }
      else if(itemId == :menuVariometerPlotOrientation) {
        $.oMySettings.saveVariometerPlotOrientation(item.isEnabled()?0:1);
      }
      else {
        Ui.pushView(new MyPickerGenericSettings(:contextVariometer, itemId),
                    new MyPickerGenericSettingsDelegate(:contextVariometer, itemId, self.menu),
                    Ui.SLIDE_LEFT);
      }
    }

    else if(self.menu == :menuSettingsSounds) {
      if(itemId == :menuSoundsVariometerTones) {
        $.oMySettings.saveSoundsVariometerTones(item.isEnabled());
        $.oMySettings.setSoundsVariometerTones(item.isEnabled());
      }
      else if(itemId == :menuVariometerVibrations) {
        $.oMySettings.saveVariometerVibrations(item.isEnabled());
        $.oMySettings.setVariometerVibrations(item.isEnabled());
      }
      else {
        Ui.pushView(new MyPickerGenericSettings(:contextSounds, itemId),
                    new MyPickerGenericSettingsDelegate(:contextSounds, itemId, self.menu),
                    Ui.SLIDE_LEFT); 
      }
    }

    else if(self.menu == :menuSettingsActivity) {
      if(itemId == :menuActivityAutoStart) {
        $.oMySettings.saveActivityAutoStart(item.isEnabled());
        $.oMySettings.setActivityAutoStart(item.isEnabled());
      }
      else if(itemId == :menuActivityAutoSpeedStart) {
        Ui.pushView(new MyPickerGeneric(:contextSettings, :itemActivityAutoSpeedStart, :speed),
                    new MyPickerGenericDelegate(:contextSettings, :itemActivityAutoSpeedStart, self.menu, :speed),
                    Ui.SLIDE_LEFT);
      }
    }

    else if(self.menu == :menuSettingsChart) {
      if(itemId == :menuChartMinMax) {
        $.oMySettings.saveChartMinMax(item.isEnabled());
      }
      else if(itemId == :menuChartValue) {
        $.oMySettings.saveChartValue(item.isEnabled());
      }
      else if(itemId == :menuChartShow) {
        $.oMySettings.saveChartShow(item.isEnabled());
      }
      else if(itemId == :menuChartRange) {
        $.oMySettings.saveChartRange(item.isEnabled());
        bRangeChange = true;
        // if(!_item.isEnabled()) { bChartReset = true; }
      }
      else if((itemId == :menuChartDisplay) && (App.Properties.getValue("userChartVars").toNumber() != 0)) {
        var iUnitIdx = ($.oMySettings.loadChartDisplay() + 1) % 6;
        while(!chartRun(iUnitIdx)) { iUnitIdx = (iUnitIdx+1) % 6; }
        $.oMySettings.saveChartDisplay(iUnitIdx as Number);
        Ui.switchToView(new MyMenu2Generic(:menuSettingsChart, 4), new MyMenu2GenericDelegate(:menuSettingsChart, false), Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuChartVars) {
        var Check = new WatchUi.CheckboxMenu({:title=>Rez.Strings.titleChartVars});
        var sRead = App.Properties.getValue("userChartVars");
        Check.addItem(new CheckboxMenuItem("Altitude", null, 0, sRead.substring(0,1).toNumber() == 1 ? true : false, {}));
        Check.addItem(new CheckboxMenuItem("Ascent", null, 1, sRead.substring(1,2).toNumber() == 1 ? true : false, {}));
        Check.addItem(new CheckboxMenuItem("Vert Speed", null, 2, sRead.substring(2,3).toNumber() == 1 ? true : false, {}));
        Check.addItem(new CheckboxMenuItem("Speed", null, 3, sRead.substring(3,4).toNumber() == 1 ? true : false, {}));
        Check.addItem(new CheckboxMenuItem("Heart Rate", null, 4, sRead.substring(4,5).toNumber() == 1 ? true : false, {}));
        Check.addItem(new CheckboxMenuItem("g load", null, 5, sRead.substring(5,6).toNumber() == 1 ? true : false, {}));
        Ui.pushView(Check, new MyMenu2GenericDelegate(:checkChartVars, true), Ui.SLIDE_LEFT);
      }
    }

    else if(self.menu == :checkChartVars) {
      var nAdjust = Math.pow(10,5-itemId).toNumber() * (item.isChecked() ? 1 : -1);
      App.Properties.setValue("userChartVars", (App.Properties.getValue("userChartVars").toNumber() + nAdjust).format("%06i"));
      $.oMySettings.setChartDisplay($.oMySettings.loadChartDisplay());
      chartRun(-1);
    }

    else if(self.menu == :menuSettingsMap) {
      if(itemId == :menuMapHeader) {
        $.oMySettings.saveMapHeader(item.isEnabled());
        bMHChange = true;
      }
      else if(itemId == :menuMapData) {
        $.oMySettings.saveMapData(item.isEnabled());
      }
      else if(itemId == :menuMapTrack) {
        $.oMySettings.saveMapTrack(item.isEnabled());
      }
    }

    else if(self.menu == :menuSettingsOx) {
      if(itemId == :menuOxMeasure) {
        $.oMySettings.saveOxMeasure(item.isEnabled());
      }
      else if(itemId == :menuOxElevation) {
        Ui.pushView(new MyPickerGeneric(:contextOx, itemId, :elevation),
                    new MyPickerGenericDelegate(:contextOx, itemId, self.menu, :elevation),
                    Ui.SLIDE_LEFT);
      }
      else if(itemId == :menuOxCritical) {
        Ui.pushView(new MyPickerGenericSettings(:contextOx, itemId),
                new MyPickerGenericSettingsDelegate(:contextOx, itemId, self.menu),
                Ui.SLIDE_LEFT);
    }
      else if(itemId == :menuOxVibrate) {
        $.oMySettings.saveOxVibrate(item.isEnabled());
      }
    }

    else if(self.menu == :menuSettingsUnits) {
      var iUnitIdx = 0;
      if(itemId == :menuUnitDistance) {
        iUnitIdx = ((($.oMySettings.loadUnitDistance() + 1) + 1) % 4) - 1;
        $.oMySettings.saveUnitDistance(iUnitIdx as Number);
        iUnitIdx = 0;
      }
      else if(itemId == :menuUnitElevation) {
        iUnitIdx = ((($.oMySettings.loadUnitElevation() + 1) + 1) % 3) - 1;
        $.oMySettings.saveUnitElevation(iUnitIdx as Number);
        iUnitIdx = 1;
      }
      else if(itemId == :menuUnitPressure) {
        iUnitIdx = ((($.oMySettings.loadUnitPressure() + 1) + 1) % 3) - 1;
        $.oMySettings.saveUnitPressure(iUnitIdx as Number);
        iUnitIdx = 2;
      }
      else if(itemId == :menuUnitRateOfTurn) {
        iUnitIdx = ($.oMySettings.loadUnitRateOfTurn() + 1) % 2;
        $.oMySettings.saveUnitRateOfTurn(iUnitIdx as Number);
        iUnitIdx = 3;
      }
      else if(itemId == :menuUnitWindSpeed) {
        iUnitIdx = ((($.oMySettings.loadUnitWindSpeed() + 1) + 1) % 5) - 1;
        $.oMySettings.saveUnitWindSpeed(iUnitIdx as Number);
        iUnitIdx = 4;
      }
      else if(itemId == :menuUnitDirection) {
        iUnitIdx = ($.oMySettings.loadUnitDirection() + 1) % 2;
        $.oMySettings.saveUnitDirection(iUnitIdx as Number);
        iUnitIdx = 5;
      }
      else if(itemId == :menuUnitHeading) {
        iUnitIdx = ($.oMySettings.loadUnitHeading() + 1) % 2;
        $.oMySettings.saveUnitHeading(iUnitIdx as Number);
        iUnitIdx = 6;
      }
      else if(itemId == :menuUnitTimeUTC) {
        $.oMySettings.saveUnitTimeUTC(!$.oMySettings.loadUnitTimeUTC() as Boolean);
        iUnitIdx = 7;
      }
      Ui.switchToView(new MyMenu2Generic(:menuSettingsUnits, iUnitIdx), new MyMenu2GenericDelegate(:menuSettingsUnits, false), Ui.SLIDE_IMMEDIATE);
    }

    else if(self.menu == :menuActivity) {
      if(itemId == :menuActivityResume) {
        if($.oMyActivity != null) {
          ($.oMyActivity as MyActivity).resume();
          Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
      }
      else if(itemId == :menuActivityPause) {
        if($.oMyActivity != null) {
          ($.oMyActivity as MyActivity).pause();
          Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
      }
      else if(itemId == :menuActivitySave) {
        Ui.pushView(new Ui.Confirmation(Ui.loadResource(Rez.Strings.titleActivitySave) + "?"),
                    new MyMenuGenericConfirmDelegate(:contextActivity, :actionSave, false),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuActivityDiscard) {
        Ui.pushView((self has :NoExclude)?(new MyMenuConfirmDiscard()) : (new Ui.Confirmation(Ui.loadResource(Rez.Strings.titleActivityDiscard) + "?")),
                    (self has :NoExclude)?(new MyMenuConfirmDiscardDelegate(:actionDiscard, true)) : (new MyMenuGenericConfirmDelegate(:contextActivity, :actionDiscard, true)),
                    Ui.SLIDE_IMMEDIATE);
      }
    }
  }

  function onDone() {
    Ui.popView(Ui.SLIDE_RIGHT);
    if(self.menu == :checkChartVars) { Ui.switchToView(new MyMenu2Generic(:menuSettingsChart, 5), new MyMenu2GenericDelegate(:menuSettingsChart, false), Ui.SLIDE_RIGHT); }
  }
  function onBack() {
    Ui.popView(Ui.SLIDE_RIGHT);
    if(self.menu == :checkChartVars) { Ui.switchToView(new MyMenu2Generic(:menuSettingsChart, 5), new MyMenu2GenericDelegate(:menuSettingsChart, false), Ui.SLIDE_RIGHT); }
  }
}

class DrawableMenu extends Ui.Drawable {
    
  //
  // VARIABLES
  //

  var menu as Symbol = :menuNone;

  //! Constructor
  public function initialize(_menu as Symbol) {
      Drawable.initialize({});
      self.menu = _menu;
  }

  //! Draw the application icon and main menu title
  //! @param dc Device Context
  (:icon)
  public function draw(_oDC) {

    var appIcon = null;
    var bitmapX = 0;
    var bitmapY = 0;

    if(menu==:title) {
      var spacing = 5;
      appIcon = Ui.loadResource($.Rez.Drawables.AppIcon);
      var bitmapWidth = appIcon.getWidth();
      var labelWidth = _oDC.getTextWidthInPixels(Ui.loadResource(Rez.Strings.titleSettings), Graphics.FONT_TINY);

      bitmapX = (_oDC.getWidth() - (bitmapWidth + spacing + labelWidth)) / 2;
      var labelX = bitmapX + bitmapWidth + spacing;
      bitmapY = (_oDC.getHeight() - appIcon.getHeight()) / 2;
      var labelY = _oDC.getHeight() / 2;

      // _oDC.drawBitmap(bitmapX, bitmapY, appIcon);
      _oDC.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      _oDC.drawText(labelX, labelY, Graphics.FONT_TINY, Ui.loadResource(Rez.Strings.titleSettings), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    else if(menu==:pause) {
      appIcon = Ui.loadResource($.Rez.Drawables.pauseIcon);
      bitmapX = (_oDC.getWidth() - appIcon.getWidth()) / 2;
      bitmapY = (_oDC.getHeight() - appIcon.getHeight()) / 2;
    }
    else if(menu==:resume) {
      appIcon = Ui.loadResource($.Rez.Drawables.resumeIcon);
      bitmapX = (_oDC.getWidth() - appIcon.getWidth()) / 2;
      bitmapY = (_oDC.getHeight() - appIcon.getHeight()) / 2;
    }
    else if(menu==:save) {
      appIcon = Ui.loadResource($.Rez.Drawables.saveIcon);
      bitmapX = (_oDC.getWidth() - appIcon.getWidth()) / 2;
      bitmapY = (_oDC.getHeight() - appIcon.getHeight()) / 2;
    }
    else if(menu==:discard) {
      appIcon = Ui.loadResource($.Rez.Drawables.discardIcon);
      bitmapX = (_oDC.getWidth() - appIcon.getWidth()) / 2;
      bitmapY = (_oDC.getHeight() - appIcon.getHeight()) / 2;
    }
    _oDC.drawBitmap(bitmapX, bitmapY, appIcon);
  }
}
