# PICKA Gender

## Purpose

The purpose of this experiment is to evaluate gender categorization performance as a function of F0 and VTL.

## Methods

A TV screen is displayed, with transmission noise. A word is played with a certain (F0, VTL) combination. Then a face appears on the screen and the participant must say whether the gender of the face matches the gender of the voice.

## Experimenter's notes

### Before the experiment

Before running the experiment, make sure to generate the stimuli by calling:

```matlab
>> gender_run(struct('name', 'generation', 'language', 'nl_nl', 'age', [], 'sex', ''));
```

To generate the British English stimuli, use:

```matlab
>> gender_run(struct('name', 'generation', 'language', 'en_gb', 'age', [], 'sex', ''));
```

### Run the experiment

```matlab
>> emotion_run(participant, phase);
```

Where `participant` is structure and `phase` is 'training' or 'test'.

Once the experiment has started with one subject ID it will always keep the options generated at the time and the experiment will always continue from where it stopped.

### Find the number of trials

```matlab
>> expe = gender_build_conditions(gender_options(struct('language', 'nl_nl')));
>> expe.test

ans =

    trials: [1x36 struct]
```
The first line of code will give a warning that you can ignore.

### Calibration

To modify the gain, you can edit the file `gender_gain.m`. If the file does not exist, run the calibration script [`calibration.m`](../calibration.m). This gain is applied to the sounds before they are played. To avoid clipping, the gain should always be negative.

To make sure the files are equalized in RMS, generate the stimuli before hand by calling `gender_run` with a subject named `'generation'` (see above).

## Contributors

The game was initially coded by Paolo Toffanin <p.toffanin@umcg.nl> and debugged by Jacqueline Libert <j.libert@rug.nl>.

The illustrations were created by [Jop Luberti](http://jopluberti.com/).

The experiment and export code were coded by Etienne Gaudrain <etienne.gaudrain@cnrs.fr> and Leanne Nagels <leanne.nagels@rug.nl>.

## About PICKA

PICKA stands for "Perception of Indexical Cues for Kids and Adults" and is a test battery aiming at evaluating various aspects of voice perception and its development in children from 4 years onwards and adults. For more details, see [the PICKA README](../../README.md).

## Copyright

See [the PICKA README](../../README.md).