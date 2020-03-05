# for yasim help with the pushback function 

var proprev_enable	= props.globals.getNode("/controls/engines/reverser_allow");
var proprev_controls	= props.globals.getNode("/engines/engine[0]/running");

setlistener("/controls/engines/engine[0]/throttle", func(throttle) {
    var throttle = throttle.getValue();  
    if (proprev_enable.getBoolValue()) {
      setprop("/sim/model/pushback/target-speed-fps", -throttle );
    }
});

# Enabled , disabled prop reverser 
toggle_reverse_lockout = func {
  if (!proprev_enable.getValue()) {					# Disabled, toggle to enable
    proprev_enable.setValue(1);
    props.globals.getNode("/sim/model/pushback/enabled", 1 ).setBoolValue(1);
    props.globals.initNode("/sim/model/pushback/target-speed-fps", getprop("engines/engine[0]/throttle")*-1 );
    setprop("controls/engines/engine[0]/propeller-pitch", 0);
    setprop("controls/engines/engine[1]/propeller-pitch", 0);
    setprop("controls/engines/engine[2]/propeller-pitch", 0);
    setprop("controls/engines/engine[3]/propeller-pitch", 0);
    setprop("/sim/model/pushback/target-speed-fps", getprop("engines/engine[0]/throttle")*-1);
    setprop("/sim/model/pushback/force", 1);
    print("gear 0 rodando a ", getprop("gear/gear[0]/tire-rpm"), " rpm");
    print("Reverso ligado");
    print("controls/engines/engine[0]/propeller-pitch ", getprop("engines/engine[0]/propeller-pitch"));
    dc6b.switch5SoundToggle();
  } else {						
    proprev_enable.setValue(0);
    setprop("/sim/model/pushback/enabled", 0 );
    setprop("/sim/model/pushback/target-speed-fps", 0 );
    setprop("/sim/model/pushback/force", 0);
    settimer(func(){
      setprop("controls/engines/engine[0]/propeller-pitch", 1);
      setprop("controls/engines/engine[1]/propeller-pitch", 1);
      setprop("controls/engines/engine[2]/propeller-pitch", 1);
      setprop("controls/engines/engine[3]/propeller-pitch", 1);
      print("controls/engines/engine[0]/propeller-pitch ", getprop("engines/engine[0]/propeller-pitch"));
    }, 5);
    dc6b.switch5SoundToggle();
    print("Reverso desligado");
  }
}

# pitch set to 0 and set throttle as target-speed-fps
toggle_prop_reverse = func {
  if (!proprev_enable.getValue()) { return; }				# Can't toggle reverse if locked out
  if (proprev_controls.getValue()) {		# Using eng 1 as master

      # if(getprop("controls/engines/engine[0]/propeller-pitch") == 1){
      #   setprop("controls/engines/engine[0]/propeller-pitch", 0);
      #   setprop("controls/engines/engine[1]/propeller-pitch", 0);
      #   setprop("controls/engines/engine[2]/propeller-pitch", 0);
      #   setprop("controls/engines/engine[3]/propeller-pitch", 0);
      #   dc6b.switch6SoundToggle();
      # }else{
      #   setprop("controls/engines/engine[0]/propeller-pitch", 1);
      #   setprop("controls/engines/engine[1]/propeller-pitch", 1);
      #   setprop("controls/engines/engine[2]/propeller-pitch", 1);
      #   setprop("controls/engines/engine[3]/propeller-pitch", 1);
      #   dc6b.switch6SoundToggle();
      # }

  }
}

################################################### Adicionado por Julio Junkes #########################################################

setlistener("instrumentation/airspeed-indicator/indicated-speed-kt", func(kt) {

  # se gear 0 for menor que 100 rpm então desativa o reverse automaticamente
  if( proprev_enable.getValue() and proprev_controls.getValue() and kt.getValue() < 10 ) {
    print("Velocidade: ", kt.getValue(), " kt");
    # proprev_enable.setValue(0);
    # setprop("/sim/model/pushback/enabled", 0 );
    # setprop("/sim/model/pushback/target-speed-fps", 0 );
    # setprop("/sim/model/pushback/force", 0);

    toggle_reverse_lockout();

    # reduz o throttle automaticamente
    setprop("controls/engines/engine[0]/throttle", 0);
    setprop("controls/engines/engine[1]/throttle", 0);
    setprop("controls/engines/engine[2]/throttle", 0);
    setprop("controls/engines/engine[3]/throttle", 0);
    print("Throttle dos 4 motores configurado automaticamente para ", getprop("controls/engines/engine[0]/throttle"));
  }
  
});

var voando = 0;

setlistener("position/gear-agl-ft", func(ft) {
  var kt = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
  if (ft.getValue() > 500 and voando == 0) {
    voando = 1;
    print("Voando...");
  } else {
    if (voando == 1 and ft.getValue() < 500) {
      voando = 2;
      print("Pousando...");
    }
  }

  if (getprop("autopilot/switches/ap") and ft.getValue() < 30 and voando > 0 and kt > 10) {
    setprop("autopilot/locks/altitude", 'altitude-hold');
    setprop("autopilot/locks/heading", '');
    setprop("autopilot/locks/speed", '');
    setprop("controls/engines/engine[0]/throttle", 0);
    setprop("controls/engines/engine[1]/throttle", 0);
    setprop("controls/engines/engine[2]/throttle", 0);
    setprop("controls/engines/engine[3]/throttle", 0);
    print("Preparando para o toque ...");
  }
  
  if (ft.getValue() < 2 and voando > 0 and kt > 10) {
    voando = 0;

    setprop("autopilot/locks/altitude", '');
    setprop("autopilot/locks/heading", '');
    setprop("autopilot/locks/speed", '');
    print("Autopilot desligado ...");
    
    setprop("controls/flight/aileron", 0);
    setprop("controls/flight/aileron-trim", 0);
    setprop("controls/flight/elevator", 0);
    setprop("controls/flight/elevator-trim", 0);
    setprop("controls/flight/rudder", 0);
    setprop("controls/flight/rudder-trim", 0);
    setprop("controls/flight/flaps", 0);
    print("Controles e trims centralizados ...");

    settimer(func(){
      # liga o reverso automaticamente...
      toggle_reverse_lockout();

      # aumenta o throttle automaticamente para o máximo...
      setprop("controls/engines/engine[0]/throttle", 1);
      setprop("controls/engines/engine[1]/throttle", 1);
      setprop("controls/engines/engine[2]/throttle", 1);
      setprop("controls/engines/engine[3]/throttle", 1);
    }, 5, 0);
  }
});
