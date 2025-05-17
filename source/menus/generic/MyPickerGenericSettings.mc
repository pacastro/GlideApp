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
using Toybox.WatchUi as Ui;

class MyPickerGenericSettings extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    if(_context == :contextVariometer) {
      if(_item == :menuVariometerPlotRange) {
        var iVariometerPlotRange = $.oMySettings.loadVariometerPlotRange();
        var oFactory = new PickerFactoryNumber(1, 5, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$ [min]", [Ui.loadResource(Rez.Strings.titleVariometerPlotRange)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOf(iVariometerPlotRange)]});
      }
      else if(_item == :menuVariometerPlotZoom) {
        var iVariometerPlotZoom = $.oMySettings.loadVariometerPlotZoom();
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
                                                   ["1000" ,"500", "200", "100", "50", "20", "10", "5", "2", "1"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$ [m/px]", [Ui.loadResource(Rez.Strings.titleVariometerPlotZoom)]),
                // :text => Ui.loadResource(Rez.Strings.titleVariometerPlotZoom) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iVariometerPlotZoom)]});
      }
    }
    
    else if (_context == :contextSounds) {
      if(_item == :menuMinimumClimb) {
        var iMinimumClimb = $.oMySettings.loadMinimumClimb();
        $.oMySettings.load();  // ... reload potentially modified settings
        var sFormat = $.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f ? "%.01f" : "%.0f";
        var asValues =
          [format("$1$\n$2$", [(0.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(0.1f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(0.2f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(0.3f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(0.4f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(0.5f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed])];
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5], asValues, {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleMinimumClimb) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iMinimumClimb)]});
      }
      else if(_item == :menuMinimumSink) {
        var iMinimumSink = $.oMySettings.loadMinimumSink();
        $.oMySettings.load();  // ... reload potentially modified settings
        var sFormat = $.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f ? "%.01f" : "%.0f";
        var asValues =
          [format("$1$\n$2$", [(-1.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(-2.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(-3.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(-4.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(-6.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(-10.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed])];
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5], asValues, {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleMinimumSink) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iMinimumSink)]});
      }
    }

    else if (_context == :contextOx) {
      if(_item == :menuOxCritical) {
        var iOxCritical = $.oMySettings.loadOxCritical();
        var oFactory = new PickerFactoryNumber(75, 90, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$ %", [Ui.loadResource(Rez.Strings.titleOxCritical)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOf(iOxCritical)]});
      }
    }
  }
}

class MyPickerGenericSettingsDelegate extends Ui.PickerDelegate {

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
    if(self.context == :contextVariometer) {
      if(self.item == :menuVariometerPlotRange) {
        $.oMySettings.saveVariometerPlotRange(_amValues[0] as Number);
        focus = 7;
      }
      else if(self.item == :menuVariometerPlotZoom) {
        $.oMySettings.saveVariometerPlotZoom(_amValues[0] as Number);
        focus = 8;
      }
    }
    
    else if(self.context == :contextSounds) {
      if(self.item == :menuMinimumClimb) {
        $.oMySettings.saveMinimumClimb(_amValues[0] as Number);
        focus = 2;
      }
      else if(self.item == :menuMinimumSink) {
        $.oMySettings.saveMinimumSink(_amValues[0] as Number);
        focus = 3;
      }
    }

    else if(self.context == :contextOx) {
      if(self.item == :menuOxCritical) {
        $.oMySettings.saveOxCritical(_amValues[0] as Number);
        focus = 2;
      }
    }

    Ui.popView(Ui.SLIDE_IMMEDIATE);
    Ui.switchToView(new MyMenu2Generic(self.parent, focus), new MyMenu2GenericDelegate(self.parent, false), WatchUi.SLIDE_RIGHT);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_RIGHT);
    return true;
  }

}
