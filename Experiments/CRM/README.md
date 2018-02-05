# PICKA CRM

## Purpose

The purpose of this experiment is to evaluate speech on speech perception as a function of F0 and VTL differences.

## Methods

... [to be filled]...

## Experimenter's notes

### Before the experiment

Before running the experiment, make sure to generate the stimuli by calling:

```matlab
>> expe_preprocess_corpus('all', 'nl_nl');
```

To generate the British English stimuli, use:

```matlab
>> expe_preprocess_corpus('all', 'en_gb');
```

### Run the experiment

```matlab
>> expe_run(participant, phase);
```

Where `participant` is a structure and `phase` is 'training' or 'test'.

Once the experiment has started with one subject ID it will always keep the options generated at the time and the experiment will always continue from where it stopped.

### Find the number of trials

```matlab
>> [training, test, options] = expe_build_conditions(expe_options(struct('language', 'nl_nl')));
>> test

ans =

    trials: [1x84 struct]
```
The first line of code will give a warning that you can ignore.

### Calibration

To modify the gain, you can edit the file `expe_gain.m`. If the file does not exist, run the calibration script [`calibration.m`](../calibration.m). This gain is applied to the sounds before they are played. To avoid clipping, the gain should always be negative.

## Contributors

The game was initially coded by Paolo Toffanin <p.toffanin@umcg.nl> and debugged by Jacqueline Libert <j.libert@rug.nl>.

The illustrations were created by [Jop Luberti](http://jopluberti.com/).

The experiment and export code were coded by Etienne Gaudrain <etienne.gaudrain@cnrs.fr> and Leanne Nagels <leanne.nagels@rug.nl>.

## About PICKA

PICKA stands for "Perception of Indexical Cues for Kids and Adults" and is a test battery aiming at evaluating various aspects of voice perception and its development in children from 4 years onwards and adults. For more details, see [the PICKA README](../../README.md).

## Copyright

See [the PICKA README](../../README.md).