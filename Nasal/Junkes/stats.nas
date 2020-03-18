var display = screen.display.new(20, 10);
display.setcolor(1, 0.3, 0.3);
display.setfont("SANS_12B", 12);
display.interval = 0;
display.format = "%.4g";
display.redraw();

var stats = 0;

var showStats = func {
  
  display.add("orientation/heading-magnetic-deg");
  display.add("position/gear-agl-ft");
  display.add("position/altitude-ft");
  display.add("velocities/airspeed-kt");
  display.add("velocities/vertical-speed-fps");
  display.add("controls/flight/flaps");
  display.add("consumables/fuel/total-fuel-norm");
  display.add("controls/engines/engine/throttle");
  display.add("controls/engines/engine/mixture");
  display.add("controls/engines/engine/propeller-pitch");
  display.add("autopilot/route-manager/destination/field-elevation-ft");
  display.add("autopilot/route-manager/route/num");
  display.add("autopilot/route-manager/distance-remaining-nm");
  display.add("autopilot/route-manager/wp/eta-seconds");
  display.add("autopilot/route-manager/wp/dist");
  stats = 1;
}

var hideStats = func {
  display.reset();
  stats = 0;
}

var toogleStats = func {
  if (stats) {
    hideStats();
  } else {
    showStats();
  }
}

showStats();