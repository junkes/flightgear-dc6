var display = screen.display.new(20, 10);
display.setcolor(0, 1, 0);
display.setfont("SANS_12B",12);
display.interval = 0;
display.format = "%.4g";
# display.tagformat = "%-25s";
display.redraw();

var stats = 0;

var showStats = func {
  display.add("instrumentation/gps/indicated-altitude-ft");
  display.add("instrumentation/gps/indicated-vertical-speed");
  display.add("instrumentation/gps/indicated-track-magnetic-deg");
  display.add("instrumentation/airspeed-indicator/indicated-speed-kt");
  display.add("controls/flight/flaps");
  display.add("consumables/fuel/total-fuel-norm");
  display.add("instrumentation/nav/in-range");
  display.add("instrumentation/nav/gs-in-range");
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