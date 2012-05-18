// improv_control.ck

// networking stuff  -----------------------------------------------------------
1 => int g_print_osc_debug;
2 => int g_num_players;
int player_inport[g_num_players];
8010 => player_inport[0];                // port for receiving osc from player 1
8011 => player_inport[1];                // port for receiving osc from player 2
8012 => int proc_outport;                  // port for sending osc messages to Processing
//"10.32.142.48" => string proc_client;       // IP address for Processing
"localhost" => string proc_client;       // IP address for Processing

// setup OSC input from iphones
OscRecv osc_in[g_num_players];
OscEvent osc_in_event[g_num_players];
for (0 => int i; i < g_num_players; i++) {
    player_inport[i] => osc_in[i].port;                   // port for receiving osc from player
    osc_in[i].listen();
    //osc_in[i].event("/3/xy", "f f") @=> osc_in_event[i];   // use this one for touchOSC "simple"
    osc_in[i].event("/touch", "f f") @=> osc_in_event[i];    // use this one for touchOSC custom ipad or iphone
}

// setup OSC out to processing
OscSend osc_proc_out;
osc_proc_out.setHost(proc_client, proc_outport);

// stuff for the sequencer -------------------------------------------------------
100 => int bpm;
4 => int ticks_per_beat;   // 1 tick = 16th note
4 => int beats_per_bar;    // 4/4 time
4 => int bars_per_pattern; // 4-bar loop

// event for ticks
class tickEvent extends Event
{
    int tick_num;
}

60::second * (1.0/bpm) * (1.0/ticks_per_beat) => dur tick_t;  // seconds per tick = sec/min * min/beat * beat/tick
ticks_per_beat * beats_per_bar * bars_per_pattern => int g_pattern_len; // ticks per pattern 

// parameter boundaries
[0.0, 0.0] @=> float g_lower_p[];   // pitch
[1.0, 1.0] @=> float g_upper_p[];
[0.0, 0.0] @=> float g_lower_t[];   // timbre
[1.0, 1.0] @=> float g_upper_t[];
[0.0, 0.0] @=> float g_lower_d[];   // density
[1.0, 1.0] @=> float g_upper_d[];

// the program
[[0.0, 0.3, 0.0, 0.0],[0.5, 0.3, 0.2, 0.6]] @=> float g_prg_lower_p[][];   // pitch
[[0.5, 0.4, 1.0, 1.0],[1.0, 0.7, 0.7, 0.8]] @=> float g_prg_upper_p[][];
[[0.1, 0.3, 0.6, 0.4],[0.5, 0.2, 0.3, 0.0]] @=> float g_prg_lower_t[][];   // timbre
[[0.6, 0.4, 1.0, 0.6],[1.0, 0.3, 0.6, 0.5]] @=> float g_prg_upper_t[][];
[[0.5, 0.3, 0.4, 0.3],[0.3, 0.0, 0.0, 0.0]] @=> float g_prg_lower_d[][];   // density
[[1.0, 0.5, 0.6, 0.9],[1.0, 1.0, 1.0, 1.0]] @=> float g_prg_upper_d[][];

4 => int g_game_len;      // number of program changes in a game
0 => int g_current_prg;   // current location in game

// send bounds to Processing
fun void sendBoundsToProcc(int player)
{
    // send pitch and timbre
    osc_proc_out.startMsg("/rect", "i f f f f");
    player => osc_proc_out.addInt;
    g_prg_lower_p[player][g_current_prg] => osc_proc_out.addFloat;
    g_prg_upper_p[player][g_current_prg] => osc_proc_out.addFloat;
    g_prg_lower_t[player][g_current_prg] => osc_proc_out.addFloat;
    g_prg_upper_t[player][g_current_prg] => osc_proc_out.addFloat;
    
    // send density
    osc_proc_out.startMsg("/dens_limit", "i f f");
    player => osc_proc_out.addInt;
    g_prg_lower_d[player][g_current_prg] => osc_proc_out.addFloat;
    g_prg_upper_d[player][g_current_prg] => osc_proc_out.addFloat;
}

tickEvent tick_e;

// audio processing
SndBuf hh_buf => Gain hh_gain => dac; // hi hat
SndBuf kk_buf => Gain kk_gain => dac; // kick
SndBuf sn_buf => Gain sn_gain => dac; // snare
SndBuf cr_buf => Gain cr_gain => dac; // crash

"hihat.wav"  => hh_buf.read;
"kick.wav"   => kk_buf.read;
"snare.wav"  => sn_buf.read;
"crash.wav" => cr_buf.read;

hh_buf.samples() => hh_buf.pos;
kk_buf.samples() => kk_buf.pos;
sn_buf.samples() => sn_buf.pos;
cr_buf.samples() => cr_buf.pos;

[Std.dbtorms(100-12), Std.dbtorms(100-9), Std.dbtorms(100-6)] @=> float note_gains[];

// process to play sequencer 
0 => int g_seq_on;
0 => int g_tick_ct;

Shred shred0;
Shred shred1;
Shred shred2;
Shred shred3;

fun void startStopSequencer()
{
    if ( g_seq_on ) {
        0 => g_seq_on;
        <<< "stopping sequencer ", "" >>>;
    }
    else {
        1 => g_seq_on;     // start the sequencer
        0 => g_tick_ct;
        0 => g_current_prg;
        <<< "starting sequencer", "">>>;
        sendBoundsToProcc(0);
        sendBoundsToProcc(1);
    }
}

fun void tickClock()
{
    while( 1 ) {
        tick_t => now;
        g_tick_ct => tick_e.tick_num;
        tick_e.broadcast();
        g_tick_ct++;
        if (g_tick_ct == g_pattern_len) {
            0 => g_tick_ct;
            if( g_seq_on )
                sendNextProgram();
        }
    }
}

fun void sendNextProgram()
{
    g_current_prg++;
    if (g_current_prg == g_game_len ) {
        startStopSequencer();
        <<< "game finished!", "" >>>;
    }
    else {
        sendBoundsToProcc(0);
        sendBoundsToProcc(1);
        <<< "sending program ", g_current_prg >>>;  // DEBUG
    }
}



// send time progress
fun void sendTimeProgress( tickEvent event )
{
    while( 1 ) {
        event => now;
        if ( (event.tick_num % 4) == 0 ) {
            osc_proc_out.startMsg("/time", "f");
            (event.tick_num + 4)$float  / g_pattern_len => float temp; 
            temp => osc_proc_out.addFloat;
            //<<< "time progress", temp >>>;  // DEBUG
        }
    }
}

// note density stuff --------------------------------------------------------------
// fill a circular buffer with note times
// to calculate density: calculate number of events within a time window,
// where the window is the lesser of g_window_len or the range or times in the buffer
class densityQueue
{
    20 => static int queue_len;
    time buffer[queue_len];
    0 => int write_ptr;
    queue_len - 1 => int read_ptr;
    
    3::second => dur time_window;
    
    fun void addEvent( time note_time )
    {
        //<<< "DEBUG", "addEvent" >>>;  
        note_time => buffer[ write_ptr ];
        write_ptr--;
        read_ptr--;
        if (write_ptr < 0)
            queue_len - 1 => write_ptr;
        if (read_ptr < 0)
            queue_len - 1 => read_ptr;
    }
    
    fun float calcDensity( time current_time )
    {
        //<<< "DEBUG", "calcDensity" >>>;
        current_time - time_window => time early_time;
        write_ptr+1 => int temp_ptr;
        if (temp_ptr >= queue_len)
            0 => temp_ptr;
        buffer[ temp_ptr ] => time note_time;
        0 => int num_notes;
        0.0 => float density;
        //<<< "note time ", note_time, "early_time ", early_time >>>;
        //<<< "num note early", num_notes, note_time, early_time >>>;
        while( (note_time > early_time) && (num_notes < queue_len ) ) {
            num_notes++;
            //num_notes / ((current_time - note_time)/1::second) => density;
            (current_time - note_time) / tick_t => float norm;
            num_notes / norm => density;
            temp_ptr++;
            if (temp_ptr >= queue_len)
                0 => temp_ptr;
            buffer[ temp_ptr ] => note_time;
            //<<< "num note early", num_notes, note_time, early_time >>>;
        } 
        return density;             
    } 
}

densityQueue que[g_num_players];

// stuff for instruments -----------------------------------------------------------
[36, 38, 41, 43, 45, 48, 50, 53, 55, 57, 60, 62, 65, 67, 69, 72, 74, 77, 79, 81] @=> int g_scale[];    // 2 8ve of pentatonic the scale that notes are played on
g_scale.cap() => int g_num_notes;
0.0 => float g_vert_min;                   // minimum vertical input value from iphone
1.0 => float g_vert_max;                   // maximum vertical input value from iphone

// calculate note midi value from vertical position
fun int calcNote(float x)
{
    (g_vert_max - g_vert_min)/g_num_notes => float step_size;
    (Math.floor( (x - g_vert_min) / step_size ))$int => int scale_deg;
    if (scale_deg >= g_num_notes ) {
        g_num_notes - 1 => scale_deg;
    }
        
    g_scale[scale_deg] => int note;   
    return note;
}

// stuff for synthesizing sound
LPF lp_flt[g_num_players];
HPF hp_flt[g_num_players];
ADSR env[g_num_players];
Pan2 panr[g_num_players];
0.8 => panr[0].pan;
-0.8 => panr[1].pan;

SawOsc osc1 => lp_flt[0] => hp_flt[0] => env[0] => panr[0] => dac;
PulseOsc osc2 => lp_flt[1] => hp_flt[1] => env[1] => panr[1] => dac;
JCRev rvrb;
env[0] => Gain wet_gain;
env[1] => wet_gain;
wet_gain => rvrb => dac;
0.15 => wet_gain.gain;
 
for (0 => int i; i < g_num_players; i++) {
    env[i].keyOff();
    env[i].set(5::ms, 30::ms, 0.3, 300::ms);
    0.3  => env[i].gain;
    2.0 => lp_flt[i].Q;
    1.5 => hp_flt[i].Q;
}

    
// stuff for playing notes
[0,0] @=> int g_synth_latch[];

// sets parameters for next note  
fun void playSynth(int player, int note, float parm1)    
{   
    //<<< "note from player ", player >>>;   // DEBUG
    
    if (player == 0) 
        Std.mtof(note) => osc1.freq;
    else
        Std.mtof(note) => osc2.freq;
    
    // calc filter params
    0.3 => float thr1;
    0.6 => float thr2;
    Std.mtof(note)*1.5 => float lo_base;
    Std.mtof(note)*0.2 => float hi_base;
    if (parm1 < thr1 ) {
        hi_base => hp_flt[player].freq;
        lo_base + 10000.0*parm1/thr2 => lp_flt[player].freq; 
    }
    else if (parm1 < thr2) {
        hi_base + 3000.0*(parm1-thr1)/(1.0 - thr1) => hp_flt[player].freq;
        lo_base + 10000.0*parm1/thr2 => lp_flt[player].freq; 
    }
    else {
        hi_base + 3000.0*(parm1-thr1)/(1.0 - thr1) => hp_flt[player].freq;
        lo_base + 10000.0 => lp_flt[player].freq; 
    }
    
    1 => g_synth_latch[player];    
}

// actually start a note
fun void triggerSynth( int player )
{
    env[player].keyOn();
    que[player].addEvent( now );
    50::ms => now;
    env[player].keyOff();
}    
    
// wait 'til a tick.  if a note is scheduled, trigger it.
fun void synthTimer( tickEvent event )
{
    while( 1 ) {
        event => now;
        for (0 => int i; i < g_num_players; i++) 
        {
            if (g_synth_latch[i] ) {
                spork ~ triggerSynth(i);
                0 => g_synth_latch[i];
            }
        }
    }
}


fun void reportDensities()
{
    while( 1 ) {
        que[0].calcDensity( now ) => float dens1;
        que[1].calcDensity( now ) => float dens2;
        <<< " Densities: ", dens1, dens2 >>>;
        
        // send messages to processing
        osc_proc_out.startMsg("/dens", "i f ");
        0 => osc_proc_out.addInt;
        dens1 => osc_proc_out.addFloat;

        osc_proc_out.startMsg("/dens", "i f ");
        1 => osc_proc_out.addInt;
        dens2 => osc_proc_out.addFloat;
        
        0.25::second => now;
    }
}






// spork processes -----------------------------------------------------------------
spork ~ eventListener(0);
spork ~ eventListener(1);
spork ~ tickClock();
spork ~ synthTimer( tick_e );
spork ~ keyboardListener();
spork ~ sendTimeProgress( tick_e );
spork ~ reportDensities();  
spork ~ seqHandler1( tick_e );
spork ~ seqHandler2( tick_e );
spork ~ seqHandler3( tick_e );
spork ~ seqHandler4( tick_e );


// make time ---------------------------------------------------------------------
while( 1 )
{
    1::second => now;
}

// more functions and processes ---------------------------------------------------
// processes for listening for osc events 
fun void eventListener(int player)
{
    player => int pl;
    while( 1 )
    {
        osc_in_event[pl] => now;
        while( osc_in_event[pl].nextMsg() )
        {
            osc_in_event[pl].getFloat() => float x_in;
            osc_in_event[pl].getFloat() => float y_procc_in;
            g_vert_max - y_procc_in => float y_synth_in;
            
            calcNote(y_synth_in) => int note;
            
            if( g_print_osc_debug )
            {
                //<<< " in event from player: ", pl, x_in, y_synth_in, note >>>;
            }
            // play note
            //spork ~playSynth(pl, note, x_in);
            playSynth(pl, note, x_in);
            
            // send message to processing
            sendEventToProcc(pl, x_in, y_procc_in);
        }
    }
}

// send new note events to processing
fun void sendEventToProcc(int player, float x, float y)
{
    osc_proc_out.startMsg("/new_note", "i f f");
    player => osc_proc_out.addInt;
    x => osc_proc_out.addFloat;
    y => osc_proc_out.addFloat;
}

// the hi-hat sequence
fun void seqHandler1( tickEvent event )
{
    // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,   
    [1, 0, 2, 0, 1, 0, 2, 1, 1, 0, 2, 0, 1, 2, 2, 3 ] @=> int seq[];
    while( 1 ) {
        event => now;
        if (g_seq_on ) {
            seq[ event.tick_num % seq.cap() ] => int note;
            if ( note ) {
                note_gains[ note -1 ] => hh_gain.gain;
                0 => hh_buf.pos;
            }
        }
    }
}

// the kick sequence
fun void seqHandler2( tickEvent event )
{
    // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,   
    [2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 1, 0 ] @=> int seq[];
    while( 1 ) {
        event => now;
        if (g_seq_on ) {
            seq[ event.tick_num % seq.cap() ] => int note;
            if ( note ) {
                note_gains[ note -1 ] => kk_gain.gain;
                0 => kk_buf.pos;
            }
        }
    }
}

// the snare sequence
fun void seqHandler3( tickEvent event )
{
  // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a, 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,     
    [0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3, 1, 0, 0,
     0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 3, 1, 3, 0  ] @=> int seq[];
    while( 1 ) {
        event => now;
        if (g_seq_on ) {
            seq[ event.tick_num % seq.cap() ] => int note;
            if ( note ) {
                note_gains[ note-1 ] => sn_gain.gain;
                0 => sn_buf.pos;
            }
        }
    }
}

// the crash sequence
fun void seqHandler4( tickEvent event )
{
    // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,   
    [2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 1, 0 ] @=> int seq[];
    while( 1 ) {
        event => now;
        if (g_seq_on ) {
            if ( event.tick_num == 0) {
                0 => cr_buf.pos;
            }
        }
    }
}

   
// keyboard listener 
fun void keyboardListener()
{
    Hid hiKbd;
    HidMsg msgKbd;
    
    // open keyboard
    0 => int device;
    if( !hiKbd.openKeyboard( device ) ) me.exit();
    <<< "keyboard '", hiKbd.name(), "' ready" >>>;
    
    while ( 1 )  {
        // wait on event
        hiKbd => now;
        while( hiKbd.recv( msgKbd ) ) {
            // check for action type
            if( msgKbd.isButtonDown() ) {
                // space key
                if( msgKbd.which == 44) {
                    startStopSequencer();
                    <<< "SPACE" >>>;
                }
                else {
                    <<< "unknown key ", msgKbd.which >>>;
                }
            }
        }
    }
}