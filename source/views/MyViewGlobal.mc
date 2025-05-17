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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewGlobal extends MyViewHeader {

  //
  // VARIABLES
  //

  // Resources
  // ... drawable
  protected var oRezDrawableGlobal as MyDrawableGlobal?;
  // ... fields
  protected var oRezValueTopLeft as Ui.Text?;
  protected var oRezValueTopRight as Ui.Text?;
  protected var oRezValueTopRightB as Ui.Text?;
  protected var oRezValueLeft as Ui.Text?;
  protected var oRezValueCenter as Ui.Text?;
  protected var oRezValueRight as Ui.Text?;
  protected var oRezValueBottomLeft as Ui.Text?;
  protected var oRezValueBottomRight as Ui.Text?;

  //
  // FUNCTIONS: MyViewHeader (override/implement)
  //

  function initialize() {
    MyViewHeader.initialize();

    // Display mode
    // ... internal
    self.bHeaderOnly = false;
  }

  function onLayout(_oDC) {
    MyViewHeader.onLayout(_oDC);

    // Load resources
    // ... drawable
    self.oRezDrawableGlobal = View.findDrawableById("MyDrawableGlobal") as MyDrawableGlobal;
    // ... fields
    self.oRezValueTopLeft = View.findDrawableById("valueTopLeft") as Ui.Text;
    self.oRezValueTopRight = View.findDrawableById("valueTopRight") as Ui.Text;
    self.oRezValueTopRightB = View.findDrawableById("valueTopRightB") as Ui.Text;
    self.oRezValueLeft = View.findDrawableById("valueLeft") as Ui.Text;
    self.oRezValueCenter = View.findDrawableById("valueCenter") as Ui.Text;
    self.oRezValueRight = View.findDrawableById("valueRight") as Ui.Text;
    self.oRezValueBottomLeft = View.findDrawableById("valueBottomLeft") as Ui.Text;
    self.oRezValueBottomRight = View.findDrawableById("valueBottomRight") as Ui.Text;
  }
}

class MyViewGlobalDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: MyViewHeaderDelegate.onMenu()");
    var focus = ($.oMySettings.bGeneralMapDisplay ? [0, 0, 2, 0, 0, 0, ($.oMySettings.bGeneralChartDisplay ? 5 : 0)] 
                                                  : [0, 0, 2, 0, 0, ($.oMySettings.bGeneralChartDisplay ? 5 : 0)]).indexOf($.oMyProcessing.iIsCurrent);
    Ui.pushView(new MyMenu2Generic(:menuSettings, focus < 0 ? 0 : focus),
                new MyMenu2GenericDelegate(:menuSettings, false),
                Ui.SLIDE_LEFT);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewHeaderDelegate.onSelect()");
    if($.oMyActivity == null && ((bActStop ? !bActPause : false) ? $.oMyProcessing.iIsCurrent != 5 : true)) {
      Ui.pushView(new Ui.Confirmation(Ui.loadResource(Rez.Strings.titleActivityStart) + "?"),
                  new MyMenuGenericConfirmDelegate(:contextActivity, :actionStart, false),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if(bActStop && !bActPause && $.oMyProcessing.iIsCurrent == 5) {
      var aMenu = new Ui.Menu();
      if(Ui has :ActionMenu) {
        aMenu = new Ui.ActionMenu(null);
        aMenu.addItem(new Ui.ActionMenuItem({:label=>"Done"}, :done));
        aMenu.addItem(new Ui.ActionMenuItem({:label=>"Back"}, :back));
        aMenu.addItem(new Ui.ActionMenuItem({:label=>"Clear"}, :clear));
        Ui.showActionMenu(aMenu, new MyActionMenuDelegate());
      }
      else {
        aMenu.addItem("Done", :done);
        aMenu.addItem("Back", :back);
        aMenu.addItem("Clear", :clear);
        Ui.pushView(aMenu, new MyAMenuDelegate(), Ui.SLIDE_LEFT);
      }
    }
    else {
      Ui.pushView(new MyMenu2Generic(:menuActivity, 0),
                  new MyMenu2GenericDelegate(:menuActivity, false),
                  Ui.SLIDE_BLINK);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: MyViewHeaderDelegate.onBack()");
    if(($.oMyProcessing.iIsCurrent == 5)&&($.oMySettings.bGeneralChartDisplay)&&(bActStop ? bActPause : true)) {
      var iChartIdx = ($.oMySettings.loadChartDisplay() + 1) % 6;
      while(!chartRun(iChartIdx)) { iChartIdx = (iChartIdx+1) % 6; }
      $.oMySettings.saveChartDisplay(iChartIdx as Number);
      $.oMySettings.setChartDisplay(iChartIdx as Number);
      Ui.requestUpdate();
    } 
    else {
      if($.oMyActivity == null) {
        return false;
      } 
      else if(($.oMyProcessing.iIsCurrent == 1)&&($.oMySettings.bGeneralOxDisplay)) {
        iViewGenOxIdx = (iViewGenOxIdx+1) % 2;
        Ui.switchToView(new MyViewGeneral(),
                        new MyViewGeneralDelegate(),
                        Ui.SLIDE_IMMEDIATE);
      }
    }
    return true;
  }
}

class MyActionMenuDelegate extends Ui.ActionMenuDelegate  {
  function initialize() { ActionMenuDelegate.initialize(); }

  function onSelect(_item) {
    if(_item.getId() == :done) { Ui.popView(Ui.SLIDE_IMMEDIATE); }
    else if(_item.getId() == :back) { $.bActPause = true; }  // using bActPause instead of a new global variable
    else if(_item.getId() == :clear) { $.bActStop = false; }
    $.oMySettings.saveChartDisplay(0);
    $.oMySettings.setChartDisplay(0);
    Ui.switchToView(new MyViewTimers(), new MyViewTimersDelegate(), Ui.SLIDE_IMMEDIATE);
  }
}

class MyAMenuDelegate extends Ui.MenuInputDelegate  {
  function initialize() { MenuInputDelegate.initialize(); }

  function onMenuItem(_item) {
    if(_item == :done) { Ui.popView(Ui.SLIDE_IMMEDIATE); }
    else if(_item == :back) { $.bActPause = true; }  // using bActPause instead of a new global variable
    else if(_item == :clear) { $.bActStop = false; }
    $.oMySettings.saveChartDisplay(0);
    $.oMySettings.setChartDisplay(0);
  }
}
