# PICKA Fishy (JND)

## Purpose

The purpose of this experiment is to measure the just-noticeable-difference for F0 and VTL differences.

## Methods

The JNDs are measured using an adaptive 2-down/1-up 3I-3AFC where the intervals are each a triplet of syllables. The adaptive procedure starts with a difference of 12 semitones. The procedure stops after 8 reversals and the threshold is calculated as the average on the last 6 reversals. The JNDs are measured in two directions relative to a female voice: towards the F0 of a male voice, and towards the VTL of a male voice. Each measurement is only performed *once*.

## Experimenter's notes

### Before the experiment

It is advisable to run the experiment once with a dummy subject so that the analysis phase of the voice manipulation is performed on each syllable sound file. This is to avoid that the stimulus generation takes too much time during the testing, causing the participant to wait between trials.

### Run the experiment

```matlab
>> fishy_run(participant);
```

Where `participant` is a structure.

Once the experiment has started with one subject ID it will always keep the options generated at the time and the experiment will always continue from where it stopped.

### Calibration

To modify the gain, you can edit the file `fishy_gain.m`. If the file does not exist, run the calibration script [`calibration.m`](../calibration.m). This gain is applied to the sounds before they are played. To avoid clipping, the gain should always be negative.

## Contributors

The game was initially coded by Paolo Toffanin <p.toffanin@umcg.nl> and debugged by Jacqueline Libert <j.libert@rug.nl>.

The illustrations were created by [Jop Luberti](http://jopluberti.com/).

The experiment and export code were coded by Etienne Gaudrain <etienne.gaudrain@cnrs.fr> and Leanne Nagels <leanne.nagels@rug.nl>.

## About PICKA

PICKA stands for "Perception of Indexical Cues for Kids and Adults" and is a test battery aiming at evaluating various aspects of voice perception and its development in children from 4 years onwards and adults. For more details, see [the PICKA README](../../README.md).

## Copyright

See [the PICKA README](../../README.md).