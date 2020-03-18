################# Aircraft specific ############################
var cruiseSpeed = 220;
var turnSpeed = 180;
var appSpeed = 120;
var descentSpeed = 150;
var climbSpeed = 170;
var climbFPM = 1300;
var descentFPM = -2000;
var mixture = 1;
var throttle = 0;
var propellerPitch = 1;
var flaps = 0;
var reverseON = 0;
################################################################

var listener = setlistener("autopilot/route-manager/distance-remaining-nm", func(n){
  var lastWPIndex = (getprop("autopilot/route-manager/route/num")-1);
  var currentWPIndex = getprop("autopilot/route-manager/current-wp");
  var agl = getprop("position/gear-agl-ft");
  if (currentWPIndex == lastWPIndex) {
    # dc6b.message.write("Route Manager - Last Waypoint: " ~ getprop("autopilot/route-manager/route/wp["~lastWPIndex~"]/id"));
    var difAltitude = getprop("position/altitude-ft") - getprop("autopilot/route-manager/destination/field-elevation-ft");
    var fpm = (difAltitude / (getprop("autopilot/route-manager/ete") + 2)) * 60;
    if (difAltitude > 50) {
      setprop("autopilot/settings/target-speed-kt", 120);
      setprop("controls/flight/flaps", 1);
      setprop("autopilot/settings/vertical-speed-fpm", fpm * -1);
      setprop("autopilot/locks/altitude", "vertical-speed-hold");
    }
    if (agl < 10 and agl > 1) {
      setprop("autopilot/locks/altitude", "altitude-hold");
      setprop("autopilot/settings/target-speed-kt", 0);
    }
    if (agl < 1) {
      setprop("autopilot/locks/altitude", "");
      setprop("autopilot/locks/heading", "");
      setprop("autopilot/locks/speed", "");
      setprop("controls/flight/aileron", 0);
      setprop("controls/flight/elevator", 0);
      setprop("controls/flight/rudder", 0);
    }
    setprop("controls/gear/gear-down", 'true');
  } else {
    if (agl > 500) {
      setprop("controls/gear/gear-down", 'false');
    }
    if (currentWPIndex == 0) {
      setprop("autopilot/route-manager/current-wp", currentWPIndex += 1);
    }
    if (currentWPIndex == 1 and getprop("velocities/airspeed-kt") > 100) {
      setprop("autopilot/settings/vertical-speed-fpm", 1500);
      setprop("autopilot/locks/altitude", "vertical-speed-hold");
    }
    if (getprop("autopilot/route-manager/wp/eta-seconds") != nil and getprop("autopilot/route-manager/wp/eta-seconds") < (getprop("velocities/airspeed-kt") / 10)) {
      setprop("autopilot/route-manager/current-wp", currentWPIndex += 1);
      setprop("autopilot/locks/altitude", "altitude-hold");
    }
    if (currentWPIndex == (lastWPIndex -2)) {
      setprop("autopilot/settings/target-speed-kt", 150);
      setprop("controls/flight/flaps", 0.7);
    }
    # dc6b.message.write("Route Manager - Waypoint: " ~ getprop("autopilot/route-manager/route/wp["~currentWPIndex~"]/id"));
  }
}, 0, 0);