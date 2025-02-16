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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Display mode (intent)
var iMyViewVarioplotPanZoom as Number = 0;
// Scale bar
var iScaleBarSize as Number = 0;
var sScaleBarUnit as Number = 0;
var iPlotScaleBarSize = 40 as Number; // Maximum size of the plot scale bar in pixels

class MyViewVarioplot extends MyViewHeader {

  //CONSTANTS
  public const TIME_CONSTANT = 4;

  //
  // VARIABLES
  //
  // Display mode (internal)
  private var iPanZoom as Number = 0;
  private var fMapRotation as Float = 0;
  // Resources
  // ... buttons
  private var oRezButtonKeyUp as Ui.Drawable?;
  private var oRezButtonKeyDown as Ui.Drawable?;

  // ... fonts
  private var oRezFontPlot as Ui.FontResource?;
  private var oRezFontPlotS as Ui.FontResource?;
  private var iFontPlotHeight as Number = 0;

  // Layout-specific
  private var iLayoutCenter as Number = 120;
  private var iLayoutClipY as Number = 31;
  private var iLayoutClipW as Number = 240;
  private var iLayoutClipH as Number = 178;
  private var iLayoutValueXleft as Number = 40;
  private var iLayoutValueXright as Number = 200;
  private var iLayoutValueYtop as Number = 30;
  private var iLayoutValueYcenter as Number = 119;
  private var iLayoutValueYbottom as Number = 190;
  private var iDotRadius = 5 as Number;
  private var iCompassRadius = 20 as Number;

  // Color scale
  private var aiScale as Array<Number> = [-3000, -2000, -1000, -50, 50, 1000, 2000, 3000] as Array<Number>;


  //
  // FUNCTIONS: Layout-specific
  //

  (:layout_240x240)
  function initLayout() as Void {
    self.iLayoutCenter = 120;
    self.iLayoutClipY = 31;
    self.iLayoutClipW = 240;
    self.iLayoutClipH = 178;
    self.iLayoutValueXleft = 40;
    self.iLayoutValueXright = 199;
    self.iLayoutValueYtop = 30;
    self.iLayoutValueYcenter = 110;
    self.iLayoutValueYbottom = 188;
    self.iDotRadius = 3;
    self.iCompassRadius = 10;
    $.iPlotScaleBarSize = 48;
  }

  (:layout_260x260)
  function initLayout() as Void {
    self.iLayoutCenter = 130;
    self.iLayoutClipY = 34;
    self.iLayoutClipW = 260;
    self.iLayoutClipH = 192;
    self.iLayoutValueXleft = 43;
    self.iLayoutValueXright = 218;
    self.iLayoutValueYtop = 33;
    self.iLayoutValueYcenter = 119;
    self.iLayoutValueYbottom = 205;
    self.iDotRadius = 4;
    self.iCompassRadius = 12;
    $.iPlotScaleBarSize = 52;
  }

  (:layout_280x280)
  function initLayout() as Void {
    self.iLayoutCenter = 140;
    self.iLayoutClipY = 36;
    self.iLayoutClipW = 280;
    self.iLayoutClipH = 208;
    self.iLayoutValueXleft = 47;
    self.iLayoutValueXright = 235;
    self.iLayoutValueYtop = 35;
    self.iLayoutValueYcenter = 128;
    self.iLayoutValueYbottom = 220;
    self.iDotRadius = 5;
    self.iCompassRadius = 14;
    $.iPlotScaleBarSize = 56;
  }

  (:layout_360x360)
  function initLayout() as Void {
    self.iLayoutCenter = 180;
    self.iLayoutClipY = 46;
    self.iLayoutClipW = 360;
    self.iLayoutClipH = 268;
    self.iLayoutValueXleft = 61;
    self.iLayoutValueXright = 299;
    self.iLayoutValueYtop = 45;
    self.iLayoutValueYcenter = 167;
    self.iLayoutValueYbottom = 288;
    self.iDotRadius = 6;
    self.iCompassRadius = 14;
    $.iPlotScaleBarSize = 72;
  }

  (:layout_390x390)
  function initLayout() as Void {
    self.iLayoutCenter = 195;
    self.iLayoutClipY = 50;
    self.iLayoutClipW = 390;
    self.iLayoutClipH = 290;
    self.iLayoutValueXleft = 66;
    self.iLayoutValueXright = 324;
    self.iLayoutValueYtop = 49;
    self.iLayoutValueYcenter = 183;
    self.iLayoutValueYbottom = 314;
    self.iDotRadius = 7;
    self.iCompassRadius = 16;
    $.iPlotScaleBarSize = 78;
  }

  (:layout_416x416)
  function initLayout() as Void {
    self.iLayoutCenter = 208;
    self.iLayoutClipY = 53;
    self.iLayoutClipW = 416;
    self.iLayoutClipH = 309;
    self.iLayoutValueXleft = 70;
    self.iLayoutValueXright = 346;
    self.iLayoutValueYtop = 52;
    self.iLayoutValueYcenter = 198;
    self.iLayoutValueYbottom = 336;
    self.iDotRadius = 7;
    self.iCompassRadius = 16;
    $.iPlotScaleBarSize = 83;
  }

  (:layout_454x454)
  function initLayout() as Void {
    self.iLayoutCenter = 227;
    self.iLayoutClipY = 58;
    self.iLayoutClipW = 454;
    self.iLayoutClipH = 337;
    self.iLayoutValueXleft = 76;
    self.iLayoutValueXright = 378;
    self.iLayoutValueYtop = 57;
    self.iLayoutValueYcenter = 218;
    self.iLayoutValueYbottom = 368;
    self.iDotRadius = 8;
    self.iCompassRadius = 20;
    $.iPlotScaleBarSize = 91;
  }


  //
  // FUNCTIONS: MyViewHeader (override/implement)
  //

  function initialize() {
    MyViewHeader.initialize();

    // Layout-specific initialization
    self.initLayout();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewVarioplot.prepare()");
    MyViewHeader.prepare();

    // Load resources
    // ... fonts
    self.oRezFontPlot = Ui.loadResource(Rez.Fonts.fontPlot) as Ui.FontResource;
    self.oRezFontPlotS = Ui.loadResource(Rez.Fonts.fontPlotS) as Ui.FontResource;
    self.iFontPlotHeight = Gfx.getFontHeight(oRezFontPlotS);

    // Color scale
    switch($.oMySettings.iVariometerRange) {
    default:
    case 0:
      self.aiScale = [-3000, -2000, -1000, -50, 50, 1000, 2000, 3000] as Array<Number>;
      break;
    case 1:
      self.aiScale = [-6000, -4000, -2000, -100, 100, 2000, 4000, 6000] as Array<Number>;
      break;
    case 2:
      self.aiScale = [-9000, -6000, -3000, -150, 150, 3000, 6000, 9000] as Array<Number>;
      break;
    }

    // Unmute tones
    (App.getApp() as MyApp).unmuteTones();
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.onUpdate()");

    // Update layout
    MyViewHeader.updateLayout(true);
    View.onUpdate(_oDC);
    self.drawPlot(_oDC);
    self.drawValues(_oDC);

    // Draw buttons
    if($.iMyViewVarioplotPanZoom) {
      if(self.oRezButtonKeyUp == null or self.oRezButtonKeyDown == null
         or self.iPanZoom != $.iMyViewVarioplotPanZoom) {
        if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom in/out
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonPlus();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonMinus();
        }
        self.iPanZoom = $.iMyViewVarioplotPanZoom;
      }
      (self.oRezButtonKeyUp as Ui.Drawable).draw(_oDC);
      (self.oRezButtonKeyDown as Ui.Drawable).draw(_oDC);
    }
    else {
      self.oRezButtonKeyUp = null;
      self.oRezButtonKeyDown = null;
    }
  }

  function rotateCoordinate(_fOriginLong, _fOriginLat, _fLong, _fLat, _fThetaSin, _fThetaCos) {
    var fLongDiff = _fLong - _fOriginLong;
    var fLatDiff = _fLat - _fOriginLat;
    var fLongDiffRot = fLongDiff * _fThetaCos - fLatDiff * _fThetaSin;
    var fLatDiffRot = fLongDiff * _fThetaSin + fLatDiff * _fThetaCos;
    return [fLongDiffRot + _fOriginLong, fLatDiffRot + _fOriginLat];
  }

  function drawArrow(_oDC as Gfx.Dc, _iCenterX, _iCenterY, _iRadius, _fAngle, _fThickness,  _iColorFg, _iColorBg) as Void {
    // Draw background
    if (_iColorBg != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(_iColorBg, Gfx.COLOR_TRANSPARENT);
      _oDC.fillCircle(_iCenterX, _iCenterY, _iRadius + 1);
    }

    // Draw arrow
    if (_iColorFg == Gfx.COLOR_TRANSPARENT) { return; }
    var fArrowWidth = Math.PI * (1 - _fThickness);
    var fArrowBackLeft = _fAngle - fArrowWidth;
    var fArrowBackRight = _fAngle + fArrowWidth;

    var aiiArrow = [
      [_iCenterX + _iRadius * Math.sin(_fAngle),         _iCenterY - _iRadius * Math.cos(_fAngle)],
      [_iCenterX + _iRadius * Math.sin(fArrowBackLeft),  _iCenterY - _iRadius * Math.cos(fArrowBackLeft)],
      [_iCenterX + _iRadius * 0.2f * Math.sin(_fAngle + Math.PI),  _iCenterY - _iRadius * 0.2f * Math.cos(_fAngle - Math.PI)],
      [_iCenterX + _iRadius * Math.sin(fArrowBackRight), _iCenterY - _iRadius * Math.cos(fArrowBackRight)]
    ];

    _oDC.setColor(_iColorFg, Gfx.COLOR_TRANSPARENT);
    _oDC.fillPolygon(aiiArrow);
  }

  function drawPlot(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.drawPlot()");
    var iNowEpoch = Time.now().value();

    // Draw plot
    _oDC.setPenWidth(3);
    var iPlotIndex = $.oMyProcessing.iPlotIndex;
    var iVariometerPlotRange = $.oMySettings.iVariometerPlotRange * 60;
    if(iPlotIndex < 0) {
      // No data
      return;
    }

    // ... end (center) location
    var iEndIndex = iPlotIndex;
    var iEndEpoch = $.oMyProcessing.aiPlotEpoch[iEndIndex];
    if(iEndEpoch < 0 or iNowEpoch-iEndEpoch > iVariometerPlotRange) {
      // No data or data too old
      return;
    }
    var iEndLatitude = $.oMyProcessing.aiPlotLatitude[iEndIndex];
    var iEndLongitude = $.oMyProcessing.aiPlotLongitude[iEndIndex];

    // ... start location
    var iStartEpoch = iNowEpoch-iVariometerPlotRange;

    // ... plot
    _oDC.setClip(0, self.iLayoutClipY, self.iLayoutClipW, self.iLayoutClipH);
    var iCurrentIndex = (iEndIndex-iVariometerPlotRange+1+$.oMyProcessing.PLOTBUFFER_SIZE)%($.oMyProcessing.PLOTBUFFER_SIZE);
    var fZoomX = $.oMySettings.fVariometerPlotZoom * Math.cos(iEndLatitude / 495035534.9930312523f);
    var fZoomY = $.oMySettings.fVariometerPlotZoom;
    var iMaxDeltaEpoch = self.TIME_CONSTANT;
    var iLastEpoch = iEndEpoch;  //
    var iLastX = 0;
    var iLastY = 0;
    var iLastColor = 0;
    var bDraw = false;
    var bHeadingUp = LangUtils.notNaN($.oMyProcessing.fHeading) && $.oMySettings.iVariometerPlotOrientation == 1;
    var fHeadingSin = 0;
    var fHeadingCos = 1;
    if (bHeadingUp) {
      fHeadingSin = Math.sin($.oMyProcessing.fHeading);
      fHeadingCos = Math.cos($.oMyProcessing.fHeading);
      fMapRotation = $.oMyProcessing.fHeading;
    } else {
      fMapRotation = 0;
    }
    for(var i=iVariometerPlotRange; i>0; i--) {
      var iCurrentEpoch = $.oMyProcessing.aiPlotEpoch[iCurrentIndex];
      if(iCurrentEpoch >= 0 and iCurrentEpoch >= iStartEpoch) {
        if(iCurrentEpoch-iLastEpoch <= iMaxDeltaEpoch) {
          var fLong = $.oMyProcessing.aiPlotLongitude[iCurrentIndex];
          var fLat = $.oMyProcessing.aiPlotLatitude[iCurrentIndex];
          if (bHeadingUp) {
            var rotated = rotateCoordinate(iEndLongitude, iEndLatitude, fLong, fLat, fHeadingSin, fHeadingCos);
            fLong = rotated[0];
            fLat = rotated[1];
          }
          var iCurrentX = self.iLayoutCenter+((fLong-iEndLongitude)*fZoomX).toNumber();
          var iCurrentY = self.iLayoutCenter-((fLat-iEndLatitude)*fZoomY).toNumber();
          var iCurrentVariometer = $.oMyProcessing.aiPlotVariometer[iCurrentIndex];
          if(bDraw) {
            var iCurrentColor = self.getDrawColor(iCurrentVariometer);
            if(iCurrentX != iLastX or iCurrentY != iLastY or iCurrentColor != iLastColor) {  // ... better a few comparison than drawLine() for nothing
              _oDC.setColor(iCurrentColor, Gfx.COLOR_TRANSPARENT);
              _oDC.drawLine(iLastX, iLastY, iCurrentX, iCurrentY);
              if(i == 1) {
                _oDC.fillCircle(iCurrentX, iCurrentY, self.iDotRadius);
              }
            }
            iLastColor = iCurrentColor;
          }
          else {
            iLastColor = -1;
          }
          iLastX = iCurrentX;
          iLastY = iCurrentY;
          bDraw = true;
        }
        else {
          bDraw = false;
        }
        iLastEpoch = iCurrentEpoch;
      }
      else {
        bDraw = false;
      }
      iCurrentIndex = (iCurrentIndex+1) % MyProcessing.PLOTBUFFER_SIZE;
    }

    // Draw detected thermal if enabled
    if($.oMyProcessing.iCenterLongitude != 0 && $.oMyProcessing.iCenterLatitude != 0 && $.oMyProcessing.iStandardDev != 0) {
      var fCenterLong = $.oMyProcessing.iCenterLongitude;
      var fCenterLat = $.oMyProcessing.iCenterLatitude;
      var fWindLong = $.oMyProcessing.fCenterWindOffsetLongitude;
      var fWindLat = $.oMyProcessing.fCenterWindOffsetLatitude;
      if (bHeadingUp) {
        var rotated = rotateCoordinate(iEndLongitude, iEndLatitude, fCenterLong, fCenterLat, fHeadingSin, fHeadingCos);
        fCenterLong = rotated[0];
        fCenterLat = rotated[1];
        rotated = rotateCoordinate(0, 0, fWindLong, fWindLat, fHeadingSin, fHeadingCos);
        fWindLong = rotated[0];
        fWindLat = rotated[1];
      }
      var myX = self.iLayoutCenter + ((fCenterLong-iEndLongitude)*fZoomX).toNumber() + (fWindLong / $.oMySettings.fVariometerPlotScale).toNumber();
      var myY = self.iLayoutCenter - ((fCenterLat-iEndLatitude)*fZoomY).toNumber() - (fWindLat / $.oMySettings.fVariometerPlotScale).toNumber();
      _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
      _oDC.drawCircle(myX, myY, ($.oMyProcessing.iStandardDev*fZoomY).toNumber());
    }
    
    // Draw compass
    if (bHeadingUp) {
      var iCompassX = self.iLayoutCenter;
      var iCompassY = self.iLayoutValueYtop + iCompassRadius + 2;

      // Draw compass arrow
      var fCompassDir = -fMapRotation;
      // var iCompassBg = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_DK_GRAY;
      drawArrow(_oDC, iCompassX, iCompassY, iCompassRadius, fCompassDir, 0.15f, Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);

      // Draw compass text
      _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText(iCompassX, iCompassY, self.oRezFontPlotS as Ui.FontResource, "N", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }
    // ... cardinal points
    else {
      _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYtop, self.oRezFontPlotS as Ui.FontResource, "N", Gfx.TEXT_JUSTIFY_CENTER);
      _oDC.drawText(self.iLayoutValueXright*1.14, self.iLayoutValueYcenter, self.oRezFontPlotS as Ui.FontResource, "E", Gfx.TEXT_JUSTIFY_LEFT);
      _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYbottom*1.03, self.oRezFontPlotS as Ui.FontResource, "S", Gfx.TEXT_JUSTIFY_CENTER);
    }

    //Sys.println(format("DEBUG: centerX, centerY, iEndLongitude, iEndLatitude = $1$, $2$, $3$, $4$", [$.oMyProcessing.iCenterLongitude, $.oMyProcessing.iCenterLatitude, iEndLongitude, iEndLatitude]));
    _oDC.clearClip();
  }

  function getDrawColor(_iGain) as Number {
    if(_iGain > self.aiScale[7]) {
      return 0xAAFFAA;
    }
    else if(_iGain > self.aiScale[6]) {
      return 0x00FF00;
    }
    else if(_iGain > self.aiScale[5]) {
      return 0x00AA00;
    }
    else if(_iGain > self.aiScale[4]) {
      return 0x55AA55;
    }
    else if(_iGain < self.aiScale[0]) {
      return 0xFFAAAA;
    }
    else if(_iGain < self.aiScale[1]) {
      return 0xFF0000;
    }
    else if(_iGain < self.aiScale[2]) {
      return 0xAA0000;
    }
    else if(_iGain < self.aiScale[3]) {
      return 0xAA5555;
    }
    else {
      return 0xAAAAAA;
    }
  }

  function drawValues(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.drawValues()");

    // Draw values
    var fValue;
    var sValue;

    _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);

    // ... altitude
    if(LangUtils.notNaN($.oMyProcessing.fAltitude)) {
      fValue = $.oMyProcessing.fAltitude * $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }

    if($.oMyProcessing.aiPointAltitude.size() >= $.oMyProcessing.PLOTBUFFER_SIZE && $.oMyProcessing.iPlotIndex >=0) {
      // Get average elevation change per second over last 20 seconds (in mm)
      var elevationChange = 1000 * ($.oMyProcessing.aiPointAltitude[$.oMyProcessing.iPlotIndex] - $.oMyProcessing.aiPointAltitude[($.oMyProcessing.iPlotIndex + $.oMyProcessing.PLOTBUFFER_SIZE - 20) % $.oMyProcessing.PLOTBUFFER_SIZE]) / 20;
      
      if(elevationChange.abs() < self.aiScale[7]) { //Only apply color changes for "weaker" thermals, when checking gain at a glance makes sense
        var altitudeTextColor = self.getDrawColor(elevationChange);
        _oDC.setColor(altitudeTextColor, Gfx.COLOR_TRANSPARENT);
      } 
    }
    _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYtop, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_LEFT);
    _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);

    // ... thermal info
    if ($.oMyProcessing.bCirclingCount >= 5) {
      // Draw thermal time
      var iThermalTime = Time.now().value() - $.oMyProcessing.iCirclingStartEpoch;
      var iThermalTimeMinutes = iThermalTime / 60;
      var iThermalTimeSeconds = iThermalTime % 60;
      sValue = Lang.format("$1$:$2$", [iThermalTimeMinutes.format("%02d"), iThermalTimeSeconds.format("%02d")]);
      _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYtop + self.iFontPlotHeight * 1.3, self.oRezFontPlotS as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_LEFT);

      // Draw thermal altitude gain
      var iThermalGain = $.oMyProcessing.fAltitude - $.oMyProcessing.fCirclingStartAltitude;
      fValue = iThermalGain * $.oMySettings.fUnitElevationCoefficient;
      var cThermalGainColor = self.getDrawColor(1000 * iThermalGain);
      if (fValue < 0) {
        sValue = fValue.format("%.0f");
      } else {
        sValue = "+" + fValue.format("%.0f");
      }
      sValue += $.oMySettings.sUnitElevation;
      _oDC.setColor(cThermalGainColor, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYtop + self.iFontPlotHeight * 2.2, self.oRezFontPlotS as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_LEFT);
      _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);
    }

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

    // ... wind dir
    if ($.oMyProcessing.bWindValid) {
      fValue = $.oMyProcessing.iWindDirection;
      if($.oMySettings.iUnitDirection == 1) {
        sValue = $.oMyProcessing.convertDirection(fValue);
      } else {
        sValue = fValue.format("%d");
      }

      // Draw wind arrow
      var iWindX = 5 + iCompassRadius;
      var iWindY = self.iLayoutValueYcenter - self.iFontPlotHeight - iCompassRadius;
      // var iWindBg = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY;
      drawArrow(_oDC, iWindX, iWindY, iCompassRadius * 0.9, Math.toRadians(fValue + 180) - fMapRotation, 0.12f, Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor?Gfx.COLOR_DK_BLUE:Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
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

    _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);
    // ... ground speed
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and LangUtils.notNaN($.oMyProcessing.fGroundSpeed)) {
      fValue = $.oMyProcessing.fGroundSpeed * $.oMySettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYbottom, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitHorizontalSpeed]), Gfx.TEXT_JUSTIFY_LEFT);

    // ... finesse
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and !$.oMyProcessing.bAscent and LangUtils.notNaN($.oMyProcessing.fFinesse)) {
      fValue = $.oMyProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN2;
    }
    _oDC.drawText(self.iLayoutValueXright, self.iLayoutValueYbottom, self.oRezFontPlot as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_RIGHT);
  
    // ... plot scale
    fValue = $.iScaleBarSize;
    sValue = $.sScaleBarUnit;
    _oDC.setColor(self.iColorTextGr, Gfx.COLOR_TRANSPARENT);
    var iScaleBarHeight = self.iLayoutValueYbottom - self.iFontPlotHeight;
    var iScaleBarStart = self.iLayoutValueXright + 21;
    var iScaleBarEnd = iScaleBarStart - fValue.toNumber();
    _oDC.drawLine(iScaleBarStart, iScaleBarHeight, iScaleBarEnd, iScaleBarHeight); // Horizontal line
    _oDC.drawLine(iScaleBarStart, iScaleBarHeight, iScaleBarStart, iScaleBarHeight - 3); // Left vertical line
    _oDC.drawLine(iScaleBarEnd, iScaleBarHeight, iScaleBarEnd, iScaleBarHeight - 3); // Right vertical line
    _oDC.drawText(iScaleBarStart, iScaleBarHeight, self.oRezFontPlotS as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_RIGHT);
    _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);

  }

  function onHide() {
    MyViewHeader.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();

    $.iMyViewVarioplotPanZoom = 0;
    // Free resources
    // ... buttons
    self.oRezButtonKeyUp = null;
    self.oRezButtonKeyDown = null;
  }

}

function calculateScaleBar(iMaxBarSize as Lang.Number, fPlotScale as Lang.Float, sUnit as Lang.String, fUnitCoefficient as Lang.Float) as Array<Lang.Number or Lang.String> {
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
        return [iBarSize, iSizeSnap + sUnit];
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
      return [0, "ERR"];
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
        return [iBarSize, iSizeSnap + sUnit];
      }
    }

    // Failed again, do not try snapping
    return [iMaxBarSize, fMaxBarScale.format("%.0f") + sUnit];
}

class MyViewVarioplotDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
    var scaleBar = calculateScaleBar($.iPlotScaleBarSize, $.oMySettings.fVariometerPlotScale, $.oMySettings.sUnitDistance, $.oMySettings.fUnitDistanceCoefficient);
    $.iScaleBarSize = scaleBar[0];
    $.sScaleBarUnit = scaleBar[1];
  }

  // function onMenu() {
  //   //Sys.println("DEBUG: MyViewVarioplotDelegate.onMenu()");
  //   Ui.pushView(new MyMenuGeneric(:menuSettings),
  //               new MyMenuGenericDelegate(:menuSettings),
  //               Ui.SLIDE_IMMEDIATE);
  //   return true;
  // }
  function onMenu() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onMenu()");
    if($.iMyViewVarioplotPanZoom) {
      $.iMyViewVarioplotPanZoom = 0;  // ... cancel pan/zoom
      Ui.pushView(new MyMenuGeneric(:menuSettings),
                  new MyMenuGenericDelegate(:menuSettings),
                  Ui.SLIDE_IMMEDIATE);
    }
    else {
      $.iMyViewVarioplotPanZoom = 1;  // ... enter pan/zoom
      Ui.requestUpdate();
    }
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onSelect()");
    if($.oMyActivity == null) {
      Ui.pushView(new MyMenuGenericConfirm(:contextActivity, :actionStart),
                  new MyMenuGenericConfirmDelegate(:contextActivity, :actionStart, false),
                  Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new MyMenuGeneric(:menuActivity),
                  new MyMenuGenericDelegate(:menuActivity),
                  Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onBack()");
    if($.iMyViewVarioplotPanZoom) {
      $.iMyViewVarioplotPanZoom = 0;  // ... cancel pan/zoom
      Ui.requestUpdate();
      return true;
    }
    else if($.oMyActivity != null) {
      return true;
    }
    return false;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onPreviousPage()");
    if($.iMyViewVarioplotPanZoom == 0) {
      Ui.switchToView(new MyViewVariometer(),
                      new MyViewVariometerDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    else if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom in
      $.oMySettings.setVariometerPlotZoom($.oMySettings.iVariometerPlotZoom+1);
      App.Properties.setValue("userVariometerPlotZoom", $.oMySettings.iVariometerPlotZoom);
      var scaleBar = calculateScaleBar($.iPlotScaleBarSize, $.oMySettings.fVariometerPlotScale, $.oMySettings.sUnitDistance, $.oMySettings.fUnitDistanceCoefficient);
      $.iScaleBarSize = scaleBar[0];
      $.sScaleBarUnit = scaleBar[1];
      Ui.requestUpdate();
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onNextPage()");
    if($.iMyViewVarioplotPanZoom == 0) {
        Ui.switchToView(new MyViewTimers(),
                        new MyViewTimersDelegate(),
                        Ui.SLIDE_IMMEDIATE);
    }
    else if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom out
      $.oMySettings.setVariometerPlotZoom($.oMySettings.iVariometerPlotZoom-1);
      App.Properties.setValue("userVariometerPlotZoom", $.oMySettings.iVariometerPlotZoom);
      var scaleBar = calculateScaleBar($.iPlotScaleBarSize, $.oMySettings.fVariometerPlotScale, $.oMySettings.sUnitDistance, $.oMySettings.fUnitDistanceCoefficient);
      $.iScaleBarSize = scaleBar[0];
      $.sScaleBarUnit = scaleBar[1];
      Ui.requestUpdate();
    }
    return true;
  }

}




