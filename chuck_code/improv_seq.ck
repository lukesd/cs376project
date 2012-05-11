// improv_seq.ck

// plays rhythmic sequences as well as sequences of structure boundaries

class tickEvent extends Event
{
    int tick_num;
}

tickEvent tick_e;

120 => int bpm;
4 => int ticks_per_beat;   // 1 tick = 16th note
4 => int beats_per_bar;    // 4/4 time
4 => int bars_per_pattern; // 4-bar loop

// spork
spork ~ seq_handler1( tick_e );

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

fun void seq_handler1( tickEvent event )
{
    [1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4, 0, 16, 0 ] @=> int seq[];
    while( 1 )
    {
        event => now;
        seq[ event.tick_num % seq.cap() ] => int note;
        if ( note ) {
             <<<"seq1 ", note >>>;
         }
    }
}


