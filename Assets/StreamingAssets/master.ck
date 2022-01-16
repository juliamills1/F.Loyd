// stitch together the other ck files

// synchronize to period
0.8::second => dur T;
T - (now % T) => now;

// 2 bar: random frequencies + channel switch (noise burst)
Machine.add( me.dir() + "burbling.ck" ) => int burb;
8::T => now;

// 2 bars: kick, open hi-hat, and squarewave bloops
Machine.add( me.dir() + "kickTwinkles.ck" ) => int kt;
1::T => now;
Machine.remove(burb);
7::T => now;

// 3 bars: + bassline
Machine.add( me.dir() + "bassline.ck" ) => int bass;
12::T => now;

// 1 bar: fill
Machine.add(me.dir() + "fill1.ck") => int f1;
Machine.remove(kt);
1::T => now;
Machine.remove(bass);
3::T => now;

// 12 bars: full beat
Machine.add(me.dir() + "totalBeat.ck") => int tb;
1::T => now;
Machine.remove(f1);
47.5::T => now;

// door slam & footsteps
SndBuf foot => dac;
me.dir() + "footsteps.wav" => foot.read;
0 => foot.pos;
0.5 => foot.gain;
10::second => now;