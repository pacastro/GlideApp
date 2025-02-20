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
      Menu2.setTitle(Rez.Strings.titleSettingsChart);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleChartMinMax, null, :menuChartMinMax, $.oMySettings.bChartMinMax, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleChartValue, null, :menuChartValue, $.oMySettings.bChartValue, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleChartShow, {:enabled=>"activity recording", :disabled=>"always on"}, :menuChartShow, $.oMySettings.bChartShow, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleChartRange, {:enabled=>"4 hrs", :disabled=>"30 min (chart reset)"}, :menuChartRange, $.oMySettings.bChartRange, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleChartDisplay, $.oMySettings.sChartDisplay, :menuChartDisplay, {}));
    }

    else if(menu == :menuSettingsMap) {
      Menu2.setTitle(Rez.Strings.titleSettingsMap);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleMapHeader, null, :menuMapHeader, $.oMySettings.bMapHeader, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleMapData, null, :menuMapData, $.oMySettings.bMapData, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
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
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitDistance, $.oMySettings.sUnitDistance, :menuUnitDistance, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitElevation, $.oMySettings.sUnitElevation, :menuUnitElevation, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitPressure, $.oMySettings.sUnitPressure, :menuUnitPressure, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitRateOfTurn, $.oMySettings.sUnitRateOfTurn, :menuUnitRateOfTurn, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitWindSpeed, $.oMySettings.sUnitWindSpeed, :menuUnitWindSpeed, {}));
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
   (:icon) var NoExclude as Symbol = :NoExclude;

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize(_menu as Symbol) {
    Menu2InputDelegate.initialize();
    self.menu = _menu;
  }

  function onSelect(_item as Ui.MenuItem) {
    var item = _item as Ui.ToggleMenuItem;
    var itemId = _item.getId() as Symbol;
    if(self.menu == :menuSettings) {
      if(itemId == :menuInfo) {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.switchToView(new MyViewInfo(), new MyViewInfoDelegate(), Ui.SLIDE_IMMEDIATE);
      }
      else {
        Ui.pushView(new MyMenu2Generic(itemId, 0),
                    new MyMenu2GenericDelegate(itemId),
                    Ui.SLIDE_IMMEDIATE);
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
        $.oMySettings.setGeneralOxDisplay(item.isEnabled());
      }
      else if(itemId == :menuGeneralVarioDisplay) {
        $.oMySettings.saveGeneralVarioDisplay(item.isEnabled());
        $.oMySettings.setGeneralVarioDisplay(item.isEnabled());
      }
      else if(itemId == :menuGeneralMapDisplay) {
        $.oMySettings.saveGeneralMapDisplay(item.isEnabled());
        $.oMySettings.setGeneralMapDisplay(item.isEnabled());
      }
      else if(itemId == :menuGeneralChartDisplay) {
        $.oMySettings.saveGeneralChartDisplay(item.isEnabled());
        $.oMySettings.setGeneralChartDisplay($.oMySettings.loadGeneralChartDisplay());
        if($.oMyProcessing.bIsPrevious == 5) {
          Ui.popView(Ui.SLIDE_IMMEDIATE);
          Ui.popView(Ui.SLIDE_IMMEDIATE);
          Ui.switchToView(new MyViewTimers(), new MyViewTimersDelegate(), Ui.SLIDE_IMMEDIATE);
        }
      }
      else if(itemId == :menuGeneralETDisplay) {
        $.oMySettings.saveGeneralETDisplay(item.isEnabled());
        $.oMySettings.setGeneralETDisplay(item.isEnabled());
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
                    new MyMenu2GenericDelegate(:menuAltimeterCalibration),
                    Ui.SLIDE_IMMEDIATE);
      }
    }
    else if(self.menu == :menuAltimeterCalibration) {
      if(itemId == :menuAltimeterCalibrationQNH) {
        Ui.pushView(new MyPickerGenericPressure(:contextSettings, :itemAltimeterCalibration),
                    new MyPickerGenericPressureDelegate(:contextSettings, :itemAltimeterCalibration, self.menu),
                    Ui.SLIDE_LEFT);
      }
      else if(itemId == :menuAltimeterCalibrationElevation) {
        Ui.pushView(new MyPickerGenericElevation(:contextSettings, :itemAltimeterCalibration),
                    new MyPickerGenericElevationDelegate(:contextSettings, :itemAltimeterCalibration, self.menu),
                    Ui.SLIDE_LEFT);
      }
    }

    else if(self.menu == :menuSettingsVariometer) {
      if(itemId == :menuVariometerAutoThermal) {
        $.oMySettings.saveVariometerAutoThermal(item.isEnabled());
        $.oMySettings.setVariometerAutoThermal(item.isEnabled());
      }
      else if(itemId == :menuVariometerThermalDetect) {
        $.oMySettings.saveVariometerThermalDetect(item.isEnabled());
        $.oMySettings.setVariometerThermalDetect(item.isEnabled());
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
        Ui.pushView(new MyPickerGenericSpeed(:contextSettings, :itemActivityAutoSpeedStart),
                    new MyPickerGenericSpeedDelegate(:contextSettings, :itemActivityAutoSpeedStart, self.menu),
                    Ui.SLIDE_LEFT);
      }
    }

    else if(self.menu == :menuSettingsChart) {
      if(itemId == :menuChartMinMax) {
        $.oMySettings.saveChartMinMax(item.isEnabled());
        $.oMySettings.setChartMinMax(item.isEnabled());
      }
      else if(itemId == :menuChartValue) {
        $.oMySettings.saveChartValue(item.isEnabled());
        $.oMySettings.setChartValue(item.isEnabled());
      }
      else if(itemId == :menuChartShow) {
        $.oMySettings.saveChartShow(item.isEnabled());
        $.oMySettings.setChartShow(item.isEnabled());
      }
      else if(itemId == :menuChartRange) {
        $.oMySettings.saveChartRange(item.isEnabled());
        $.oMySettings.setChartRange(item.isEnabled());
        bRangeChange = true;
        // if(!_item.isEnabled()) { bChartReset = true; }
      }
      else if(itemId == :menuChartDisplay) {
        Ui.pushView(new MyPickerGenericSettings(:contextChart, itemId),
                    new MyPickerGenericSettingsDelegate(:contextChart, itemId, self.menu),
                    Ui.SLIDE_LEFT);
      }
    }

    else if(self.menu == :menuSettingsMap) {
      if(itemId == :menuMapHeader) {
        $.oMySettings.saveMapHeader(item.isEnabled());
        $.oMySettings.setMapHeader(item.isEnabled());
        bMHChange = true;
      }
      else if(itemId == :menuMapData) {
        $.oMySettings.saveMapData(item.isEnabled());
        $.oMySettings.setMapData(item.isEnabled());
      }
    }

    else if(self.menu == :menuSettingsOx) {
      if(itemId == :menuOxMeasure) {
        $.oMySettings.saveOxMeasure(item.isEnabled());
        $.oMySettings.setOxMeasure(item.isEnabled());
      }
      else if(itemId == :menuOxElevation) {
        Ui.pushView(new MyPickerGenericElevation(:contextOx, itemId),
                    new MyPickerGenericElevationDelegate(:contextOx, itemId, self.menu),
                    Ui.SLIDE_LEFT);
      }
      else if(itemId == :menuOxCritical) {
        Ui.pushView(new MyPickerGenericSettings(:contextOx, itemId),
                new MyPickerGenericSettingsDelegate(:contextOx, itemId, self.menu),
                Ui.SLIDE_LEFT);
    }
      else if(itemId == :menuOxVibrate) {
        $.oMySettings.saveOxVibrate(item.isEnabled());
        $.oMySettings.setOxVibrate(item.isEnabled());
      }
    }

    else if(self.menu == :menuSettingsUnits) {
        Ui.pushView(new MyPickerGenericSettings(:contextUnit, itemId),
                    new MyPickerGenericSettingsDelegate(:contextUnit, itemId, self.menu),
                    Ui.SLIDE_LEFT);
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
                    new MyMenuGenericConfirmDelegate(:contextActivity, :actionSave, true),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuActivityDiscard) {
        Ui.pushView((self has :NoExclude)?(new MyMenuConfirmDiscard()) : (new Ui.Confirmation(Ui.loadResource(Rez.Strings.titleActivityDiscard) + "?")),
                    (self has :NoExclude)?(new MyMenuConfirmDiscardDelegate(:actionDiscard, true)) : (new MyMenuGenericConfirmDelegate(:contextActivity, :actionDiscard, false)),
                    Ui.SLIDE_IMMEDIATE);
      }
    }
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
