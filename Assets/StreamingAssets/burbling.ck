// 7 beats of random frequencies, followed by short burst of noise

// synchronize to period
0.8::second => dur T;
T - (now % T) => now;

SqrOsc s => LPF lpf => JCRev j => Gain g => dac;
TriOsc t => lpf => j => g => dac;
0.35 => j.mix;
0.0 => g.gain;

7::T + now => time end;
0 => int i;

// for 7 beats
while( now < end )
{
    // fade in
    i * 0.0004 => g.gain;
    
    // random frequencies
    Math.random2(40, 300) => s.freq;
    Math.random2(40, 200) => t.freq;
    
    // oscillate lpf between 100 and 500 Hz
    ((Math.sin(1.5 * (now/second))) + 2.5) * 240 => lpf.freq;
    100::ms => now;
    i + 1 => i;
}
0.0 => g.gain;

// create noise oscillator
Noise n => ADSR e => LPF l => dac;
15000 => l.freq;
e.set(10::ms, 8::ms, .5, 30::ms);
0.3 => n.gain;

// play noise for 1 beat
e.keyOn();
1::T => now;
e.keyOff();
e.releaseTime() => now;