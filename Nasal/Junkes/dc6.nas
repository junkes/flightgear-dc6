var horizontalNavigation = func {
  var routeManagerActive = getprop("autopilot/route-manager/active");
  var wpDist = getprop("autopilot/route-manager/wp/dist") or 0;
  var currentWPIndex = getprop("autopilot/route-manager/current-wp") or 0;
  var nextWPIndex = currentWPIndex + 1;
  var routeNum = getprop("autopilot/route-manager/route/num") or 0;
  var lastWPIndex = routeNum - 1;
  if(routeManagerActive) {
    if(wpDist < 1) {
      if (nextWPIndex == lastWPIndex) { 
        # ignore last wp
        return;
      } else {
        setprop("autopilot/route-manager/current-wp", nextWPIndex);
        dc6b.message.write("Route Manager - Waypoint: " ~nextWPIndex~"/"~lastWPIndex~);
      }
    }
  }
}

var verticalNavigation = func {
  var apON = getprop("autopilot/switches/ap");
  var gpsON = getprop("autopilot/switches/gps");
  var navON = getprop("autopilot/switches/nav");
  var apprON = getprop("autopilot/switches/appr");
  var altON = getprop("autopilot/switches/alt");
  var vsON = getprop("autopilot/switches/pitch");
  var speedKT = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
  var altFT = getprop("instrumentation/gps/indicated-altitude-ft");
  var targetAltFT = getprop("autopilot/settings/target-altitude-ft");
  var aglFT = getprop("position/gear-agl-ft");
  var destinationFieldElevationFT = getprop("autopilot/route-manager/destination/field-elevation-ft");
  var navCourse = getprop("instrumentation/nav/radials/selected-deg");
  var headingDeg = getprop("instrumentation/gps/indicated-track-magnetic-deg");
  var navInRange = getprop("instrumentation/nav/in-range");

  if (gpsON and aglFT > 500) {
    setprop("controls/gear/gear-down", 'false');
  }

  if (apON and (gpsON or navON) and speedKT > 110) {
    var mixture = 1;

    if (!navON and navInRange) {
      if (((navCourse - headingDeg) < 30) and ((navCourse - headingDeg) > -30)) {
        setprop("autopilot/switches/nav", 'true');
        dc6b.message.write("Autopilot nav ON");
      }
    }

    if (navON and !apprON and ((targetAltFT - destinationFieldElevationFT) <= 2100) ) {
      setprop("autopilot/switches/appr", 'true');
      setprop("controls/gear/gear-down", 'true');
      setprop("autopilot/settings/target-speed-kt", 125);
      setprop("controls/flight/flaps", 1);
      setprop("controls/engines/engine[0]/mixture", 1);
      setprop("controls/engines/engine[1]/mixture", 1);
      setprop("controls/engines/engine[2]/mixture", 1);
      setprop("controls/engines/engine[3]/mixture", 1);
      dc6b.message.write("Autopilot appr ON");
      dc6b.message.write("Gears down");
      flaps = 1;
      mixture = 1;
    }

    if (altON and altFT > (targetAltFT + 300)) {
      setprop("autopilot/settings/target-speed-kt", 150);
      setprop("autopilot/settings/vertical-speed-fpm", -2000);
      setprop("autopilot/switches/pitch", 1);
      setprop("controls/flight/flaps", 0.5);
      setprop("controls/engines/engine[0]/mixture", mixture);
      setprop("controls/engines/engine[1]/mixture", mixture);
      setprop("controls/engines/engine[2]/mixture", mixture);
      setprop("controls/engines/engine[3]/mixture", mixture);
      
      dc6b.message.write("Setting target speed: 150 kt");
      dc6b.message.write("Setting flaps: 50%");
      dc6b.message.write("Setting vertical speed: -2000 fpm");
      dc6b.message.write("Setting mixture: " ~ mixture);
    }

    if (altON and altFT < (targetAltFT - 300)) {
      setprop("autopilot/settings/target-speed-kt", 150);
      setprop("autopilot/settings/vertical-speed-fpm", 1000);
      setprop("autopilot/switches/pitch", 1);
      setprop("controls/flight/flaps", 0.5);
      setprop("controls/engines/engine[0]/mixture", mixture);
      setprop("controls/engines/engine[1]/mixture", mixture);
      setprop("controls/engines/engine[2]/mixture", mixture);
      setprop("controls/engines/engine[3]/mixture", mixture);

      dc6b.message.write("Setting target speed: 150 kt");
      dc6b.message.write("Setting flaps: 50%");
      dc6b.message.write("Setting vertical speed: 1000 fpm");
      dc6b.message.write("Setting mixture: " ~ mixture);
    }

    if (vsON and altFT > (targetAltFT - 300) and altFT < (targetAltFT + 300)) {
      mixture = 0.6;
      var speed = 220;
      var flaps = 0;

      # if (!navON and navInRange) {
      #   if (((navCourse - headingDeg) < 30) and ((navCourse - headingDeg) > -30)) {
      #     setprop("autopilot/switches/nav", 'true');
      #     dc6b.message.write("Autopilot nav ON");
      #   }
      # }

      # if (navON and ((targetAltFT - destinationFieldElevationFT) <= 2100) ) {
      #   setprop("autopilot/switches/appr", 'true');
      #   setprop("controls/gear/gear-down", 'true');
      #   dc6b.message.write("Autopilot appr ON");
      #   dc6b.message.write("Gears down");
      #   flaps = 1;
      #   speed = 125;
      #   mixture = 1;
      # }

      setprop("autopilot/switches/alt", 'true');
      setprop("controls/flight/flaps", flaps);
      setprop("controls/engines/engine[0]/mixture", mixture);
      setprop("controls/engines/engine[1]/mixture", mixture);
      setprop("controls/engines/engine[2]/mixture", mixture);
      setprop("controls/engines/engine[3]/mixture", mixture);
      setprop("autopilot/settings/target-speed-kt", speed);
      dc6b.message.write("Setting target speed: " ~ speed ~ " kt");
      dc6b.message.write("Setting altitude hold: " ~ targetAltFT ~ "ft");
      dc6b.message.write("Setting mixture: " ~ mixture);
    }
  }

  if (apON and navON and speedKT > 110) {
  }
}

var main = func {
  horizontalNavigation();
  verticalNavigation();
  settimer(main, 2);
}

main();
