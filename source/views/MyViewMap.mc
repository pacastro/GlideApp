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
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;



//! This view shows a map on the screen with markers and a polyline
// class MyViewMap extends Ui.MapView {
class MyViewMap extends Ui.MapTrackView {

    // VARIABLES
    //
    // Display mode (internal)
    protected var bHeaderOnly as Boolean = true;

    // Resources
    // ... strings
    protected var sValueActivityStandby as String = "SBY";
    protected var sValueActivityRecording as String = "REC";
    protected var sValueActivityPaused as String = "PSD";
    // ... fonts
    private var oRezFontPlot as Ui.FontResource?;
    private var oRezFontPlotS as Ui.FontResource?;
    private var iFontPlotHeight as Number = 0;
    // ... header
    private var oRezValueBatteryLevel as Ui.Text?;
    private var oRezValueActivityStatus as Ui.Text?;
    public var oRezDrawableHeader as MyDrawableHeader?;
    // ... footer
    protected var oRezValueFooter as Ui.Text?;

    // Layout-specific
    // private var iLayoutCenter as Number = (Sys.getDeviceSettings().screenWidth * 0.5).toNumber();
    // private var iLayoutClipY as Number = (Sys.getDeviceSettings().screenHeight * 0.13).toNumber();
    // private var iLayoutClipW as Number = Sys.getDeviceSettings().screenWidth;
    // private var iLayoutClipH as Number = (Sys.getDeviceSettings().screenHeight * 0.742).toNumber();
    private var iLayoutValueXleft as Number = (Sys.getDeviceSettings().screenWidth * 0.165).toNumber();
    private var iLayoutValueXright as Number = Sys.getDeviceSettings().screenWidth - iLayoutValueXleft;
    private var iLayoutValueYtop as Number = (Sys.getDeviceSettings().screenHeight * 0.125).toNumber();
    private var iLayoutValueYcenter as Number = (Sys.getDeviceSettings().screenHeight * 0.476).toNumber();
    private var iLayoutValueYbottom as Number = Sys.getDeviceSettings().screenHeight - iLayoutValueYtop;
    // private var iDotRadius as Number = (Sys.getDeviceSettings().screenWidth * 0.0164).toNumber();
    // private var iCompassRadius as Number = (Sys.getDeviceSettings().screenHeight * 0.0385).toNumber();

    // Color
    private var iColorText = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK;

    // ... Polyline
    // private var oPolyTrack as Ui.MapPolyline?;
    // private var myTarget as Pos.Location?;

    //! Constructor
    public function initialize() {
        $.oMyProcessing.iIsCurrent = 4;
        if($.oMyActivity != null) { $.oTimeLastTimer = Time.now();}  // view ET timer
        // MapView.initialize();
        MapTrackView.initialize();

        // set the current mode for the map to be preview
        setMapMode(Ui.MAP_MODE_PREVIEW);

        // set Popyline
        // self.oPolyTrack = new Ui.MapPolyline();
        // self.oPolyTrack.setColor(Gfx.COLOR_GREEN);
        // self.oPolyTrack.setWidth((Sys.getDeviceSettings().screenHeight/100).toNumber());

        // create the bounding box for the map area
        var lat = App.Properties.getValue("userLastLat") as Float;
        var lon = App.Properties.getValue("userLastLon") as Float;
        if(($.oMyPositionLocation!=null) || ($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE)) {
            lat = $.oMyPositionLocation.toDegrees()[0].toFloat();
            lon = $.oMyPositionLocation.toDegrees()[1].toFloat();
            App.Properties.setValue("userLastLat", lat as App.PropertyValueType);
            App.Properties.setValue("userLastLon", lon as App.PropertyValueType);
        }
        var top_left = new Pos.Location( {:latitude=> lat + 0.066, :longitude=> lon + 0.0896, :format=> :degrees});
        var bottom_right = new Pos.Location( {:latitude=> lat - 0.066, :longitude=> lon - 0.0896, :format=> :degrees});
        MapView.setMapVisibleArea(top_left, bottom_right);

        // // set the bound box for the screen area to focus the map on
        MapView.setScreenVisibleArea(0, 0, System.getDeviceSettings().screenWidth, System.getDeviceSettings().screenHeight);
    }

    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc as Gfx.Dc) as Void {
        View.setLayout($.oMySettings.bMapHeader?Rez.Layouts.layoutHeader(dc) : Rez.Layouts.layoutHeaderClear(dc));
        if($.oMySettings.bMapHeader) {
            // Load resources
            // ... drawable
            self.oRezDrawableHeader = View.findDrawableById("MyDrawableHeader") as MyDrawableHeader;
            // ... header
            self.oRezValueBatteryLevel = View.findDrawableById("valueBatteryLevel") as Ui.Text;
            self.oRezValueActivityStatus = View.findDrawableById("valueActivityStatus") as Ui.Text;
            // ... footer
            self.oRezValueFooter = View.findDrawableById("valueFooter") as Ui.Text;

            iLayoutValueXleft = (Sys.getDeviceSettings().screenWidth * 0.165).toNumber();
            iLayoutValueYtop = (Sys.getDeviceSettings().screenHeight * 0.125).toNumber();
        } else {
            iLayoutValueXleft = (iLayoutValueXleft * 1.55).toNumber();
            iLayoutValueYtop = (iLayoutValueYtop * 0.5).toNumber();
        }
        iLayoutValueXright = Sys.getDeviceSettings().screenWidth - iLayoutValueXleft;
        iLayoutValueYbottom = Sys.getDeviceSettings().screenHeight - iLayoutValueYtop;

        // if(($.oMyPositionLocation!=null) && ($.oMyActivity != null) && ($.oMySettings.bMapTrack)) { 
        //     self.myTarget = new Pos.Location({
        //         :latitude => -23.476,
        //         :longitude => -70.608,
        //         :format => :degrees
        //     });
        //     self.oPolyTrack.clear();
        //     self.oPolyTrack.addLocation(self.myTarget);
        //     self.oPolyTrack.addLocation($.oMyPositionLocation);
        //     MapView.setPolyline(self.oPolyTrack);
        // }
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    public function onShow() as Void {
        // Sys.println("DEBUG: MyViewMap.onShow()");

        // (Re)load settings
        (App.getApp() as MyApp).loadSettings();

        // Load resources
        // ... fonts
        self.oRezFontPlot = Ui.loadResource(Rez.Fonts.fontPlotS) as Ui.FontResource;
        self.oRezFontPlotS = Ui.loadResource(Rez.Fonts.fontPlotS) as Ui.FontResource;
        self.iFontPlotHeight = Gfx.getFontHeight(oRezFontPlotS);
        
        if($.oMySettings.bMapHeader) {
            // Load resources (MyView)
            // ... strings
            self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby) as String;
            self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording) as String;
            self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused) as String;
        }
        
        // ... colors
        self.iColorText = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;

        // Layer
        auxLayer = new AuxLayer(true, false, false);

        // Unmute tones
        (App.getApp() as MyApp).unmuteTones();
    }

    //! Update the view
    //! @param dc Device context
    public function onUpdate(dc as Gfx.Dc) as Void {
        if(bMHChange) {
            self.onLayout(dc);
            bMHChange = false;
        }
        // call the parent onUpdate function to redraw the layout
        MapView.onUpdate(dc);
        self.updateLayout(true);
        self.drawValues(dc);

    }

    function updateLayout(_bUpdateTime) {
        //Sys.println("DEBUG: MyViewHeader.updateLayout()");
        if($.oMySettings.bMapHeader) {
            // Set colors
            // ... background
            (self.oRezDrawableHeader as MyDrawableHeader).setColorBackground(Gfx.COLOR_TRANSPARENT);

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

    function drawValues(_oDC as Gfx.Dc) as Void {
        //Sys.println("DEBUG: MyViewVarioplot.drawValues()");
        if($.oMySettings.bMapData) {
            // Draw values
            var fValue;
            var sValue;

            _oDC.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_LT_GRAY);

            // ... altitude
            if(LangUtils.notNaN($.oMyProcessing.fAltitude)) {
                fValue = $.oMyProcessing.fAltitude * $.oMySettings.fUnitElevationCoefficient;
                sValue = fValue.format("%.0f");
            }
            else {
                sValue = $.MY_NOVALUE_LEN3;
            }
            _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYtop, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_LEFT);
        
            // ... variometer
            if(LangUtils.notNaN($.oMyProcessing.fVariometer)) {
                fValue = $.oMyProcessing.fVariometer_filtered * $.oMySettings.fUnitVerticalSpeedCoefficient;
                if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
                    sValue = fValue.format("%+.1f");
                }
                else {
                    sValue = fValue.format("%+.0f");
                }
            }
            else {
                sValue = $.MY_NOVALUE_LEN3;
            }
            _oDC.drawText(self.iLayoutValueXright, self.iLayoutValueYtop, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitVerticalSpeed]), Gfx.TEXT_JUSTIFY_RIGHT);

            // ... ground speed
            if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and LangUtils.notNaN($.oMyProcessing.fGroundSpeed)) {
                fValue = $.oMyProcessing.fGroundSpeed * $.oMySettings.fUnitHorizontalSpeedCoefficient;
                sValue = fValue.format("%.0f");
            }
            else {
                sValue = $.MY_NOVALUE_LEN3;
            }
            _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYbottom - Gfx.getFontHeight(oRezFontPlot), self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitHorizontalSpeed]), Gfx.TEXT_JUSTIFY_LEFT);

            // ... finesse
            if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and !$.oMyProcessing.bAscent and LangUtils.notNaN($.oMyProcessing.fFinesse)) {
                fValue = $.oMyProcessing.fFinesse;
                sValue = fValue.format("%.0f");
            }
            else {
                sValue = $.MY_NOVALUE_LEN2;
            }
            _oDC.drawText(self.iLayoutValueXright, self.iLayoutValueYbottom - Gfx.getFontHeight(oRezFontPlot), self.oRezFontPlot as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_RIGHT);

            // ... wind dir
            if ($.oMyProcessing.bWindValid) {
                fValue = $.oMyProcessing.iWindDirection;
                if($.oMySettings.iUnitDirection == 1) {
                    sValue = $.oMyProcessing.convertDirection(fValue);
                } else {
                    sValue = fValue.format("%d");
                }
            }
            else {
                sValue = $.MY_NOVALUE_LEN3;
            }
            _oDC.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
            _oDC.drawText(5, self.iLayoutValueYcenter - self.iFontPlotHeight, self.oRezFontPlotS as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_LEFT);

            // ... wind speed
            if ($.oMyProcessing.bWindValid) {
                fValue = $.oMyProcessing.fWindSpeed * $.oMySettings.fUnitWindSpeedCoefficient;
                sValue = fValue.format("%.0f");
            }
            else {
                sValue = $.MY_NOVALUE_LEN3;
            }
            _oDC.drawText(5, self.iLayoutValueYcenter, self.oRezFontPlotS as Ui.FontResource, (sValue.equals($.MY_NOVALUE_LEN3)?"W":"Wind"), Gfx.TEXT_JUSTIFY_LEFT);
            _oDC.drawText(5, self.iLayoutValueYcenter + self.iFontPlotHeight, self.oRezFontPlotS as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_LEFT);
            _oDC.drawText(5, self.iLayoutValueYcenter + self.iFontPlotHeight*2, self.oRezFontPlotS as Ui.FontResource, (sValue.equals($.MY_NOVALUE_LEN3)?"":$.oMySettings.sUnitWindSpeed), Gfx.TEXT_JUSTIFY_LEFT);
        }
    }

    function onHide() {
        auxLayer.onHide();
        
        // Mute tones
        (App.getApp() as MyApp).muteTones();
    }
}


class MyViewMapDelegate extends Ui.BehaviorDelegate {

    private var _view as Ui.MapView;

    //! Constructor
    //! @param view The associated map view
    public function initialize(view as Ui.MapView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onMenu() {
    //Sys.println("DEBUG: MyViewHeaderDelegate.onMenu()");
        Ui.pushView(new MyMenu2Generic(:menuSettings, 5),
                    new MyMenu2GenericDelegate(:menuSettings, false),
                    Ui.SLIDE_LEFT);
        return true;
    }
    //! Handle the back event
    //! @return true if handled, false otherwise
    public function onBack() as Boolean {
        // if current mode is preview mode them pop the view
        if (_view.getMapMode() == Ui.MAP_MODE_PREVIEW) {
            if($.oMyActivity != null) {
                $.oTimeLastTimer = Time.now();  // view ET timer
                return true;
            }
            return false;
        } else {
            // if browse mode change the mode to preview
            _view.setMapMode(Ui.MAP_MODE_PREVIEW);
        }
        return true;
    }

    //! Handle the select button
    //! @return true if handled, false otherwise
    public function onSelect() as Boolean {
        // on enter button press change the map view to browse mode
        _view.setMapMode(Ui.MAP_MODE_BROWSE);
        return true;
    }

    function onPreviousPage() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onPreviousPage()");
        Ui.switchToView(new MyViewVarioplot(),
                        new MyViewVarioplotDelegate(),
                        Ui.SLIDE_IMMEDIATE);
    return true;
  }

    function onNextPage() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onNextPage()");
        Ui.switchToView(new MyViewTimers(),
                        new MyViewTimersDelegate(),
                        Ui.SLIDE_IMMEDIATE);
    return true;
  }
}
