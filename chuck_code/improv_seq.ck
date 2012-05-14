// improv_seq.ck

// plays rhythmic sequences as well as sequences of structure boundaries
// global parameters
100 => int bpm;
4 => int ticks_per_beat;   // 1 tick = 16th note
4 => int beats_per_bar;    // 4/4 time
4 => int bars_per_pattern; // 4-bar loop

// event for ticks
class tickEvent extends Event
{
    int tick_num;
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

// spork
spork ~ seq_handler1( tick_e );
spork ~ seq_handler2( tick_e );
spork ~ seq_handler3( tick_e );
spork ~ seq_handler4( tick_e );

// make time
60::second * (1.0/bpm) * (1.0/ticks_per_beat) => dur tick_t;  // seconds per tick = sec/min * min/beat * beat/tick
ticks_per_beat * beats_per_bar * bars_per_pattern => int pattern_len; // ticks per pattern
0 => int tick_ct;
while( 1 ) {
    tick_t => now;
    tick_ct => tick_e.tick_num;
    tick_e.broadcast();
    tick_ct++;
    if (pattern_len == tick_ct )
        0 => tick_ct;
}



// the hi-hat sequence
fun void seq_handler1( tickEvent event )
{
  // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,   
    [1, 0, 2, 0, 1, 0, 2, 1, 1, 0, 2, 0, 1, 2, 2, 3 ] @=> int seq[];
    while( 1 ) {
        event => now;
        seq[ event.tick_num % seq.cap() ] => int note;
        if ( note ) {
             note_gains[ note -1 ] => hh_gain.gain;
             0 => hh_buf.pos;
         }
    }
}

// the kick sequence
fun void seq_handler2( tickEvent event )
{
  // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,   
    [2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 1, 0 ] @=> int seq[];
    while( 1 ) {
        event => now;
        seq[ event.tick_num % seq.cap() ] => int note;
        if ( note ) {
            note_gains[ note -1 ] => kk_gain.gain;
            0 => kk_buf.pos;
        }
    }
}

// the snare sequence
fun void seq_handler3( tickEvent event )
{
  // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a, 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,     
    [0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3, 1, 0, 0,
     0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 3, 1, 3, 0  ] @=> int seq[];
    while( 1 ) {
        event => now;
        seq[ event.tick_num % seq.cap() ] => int note;
        if ( note ) {
            note_gains[ note -1 ] => sn_gain.gain;
            0 => sn_buf.pos;
        }
    }
}

// the crash sequence
fun void seq_handler4( tickEvent event )
{
    // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,   
    [2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 1, 0 ] @=> int seq[];
    while( 1 ) {
        event => now;
        if ( event.tick_num == 0) {
            0 => cr_buf.pos;
        }
    }
}




