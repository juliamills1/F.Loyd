// kick, open hi-hat, & random squarewave bloops

// synchronize to period
0.8::second => dur T;
T - (now % T) => now;

// squarewave oscillator
SqrOsc s => JCRev r => dac;
0.0 => s.gain;
0.2 => r.mix;

// pitch classes to choose from
[ 0, 1, 4, 7, 8, 11, 12] @=> int scale[];

// drumkit routing
SndBuf kBuf => Gain kg => NRev n => dac;
SndBuf hBuf => Gain hg => NRev hn => dac;

// load drum samples into buffers
me.dir() + "808_Kick_Long.wav" => kBuf.read;
me.dir() + "808_Hat_Open.wav" => hBuf.read;

// set gain & reverb values
0.1 => n.mix;
0.3 => hn.mix;
0.5 => kg.gain;
0.0 => hg.gain;

31::second + now => time end;

// loop for 31 seconds
while( now < end )
{
    // beat 1: kick
    0 => kBuf.pos;
    Math.random2f(0.8, 0.9) => kBuf.gain;
    1::T => now;
    
    // beat 2 & 3: open hi-hat
    0 => hBuf.pos;
    0.5 => hg.gain;
    Math.random2f(0.8, 0.9) => hBuf.gain;
    2::T => now;
    
    // beat 4: squarewave bloops, 8 x n32
    0 => int i;
    for (i; i < 8; i++)
    {
        i * 0.01 => s.gain;
        scale[ Math.random2(0,5) ] => float freq;
        Std.mtof( 55 + (Math.random2(0,2)*12 + freq) ) => s.freq;
        0.125::T => now;
    }
    0.0 => s.gain;
}
0.0 => kg.gain;
0.0 => hg.gain;