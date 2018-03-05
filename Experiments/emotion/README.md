# PICKA Emotion

## Purpose

The purpose of this experiment is to evaluate the ability of participant to discriminate between a three auditory emotions: sad, happy, angry.

## Methods

A nonsensical sentence is played with a certain emotion. In the game, a parrot is producing the sentence. Then three clowns displaying the three emotions on their face are shown and the participant needs to select the clown whose visual emotion fits the auditory emotion.

For each participant, the clowns are ordered differently and that order remains constant for the whole experiment.

There are 36 trials: 3 emotions × 4 speakers × 3 utterances. The 36 trials are randomized for each participant. (Always check [`emotion_build_conditions.m`](emotion_build_conditions.m) for the most up to date list of trials. Or see below how to find the number of trials.)

## Experimenter's notes

### Run the experiment

```matlab
>> emotion_run(participant, phase);
```

Where `participant` is structure and `phase` is 'training' or 'test'.

Once the experiment has started with one subject ID it will always keep the options generated at the time and the experiment will always continue from where it stopped.

### Find the number of trials

```matlab
>> expe = emotion_build_conditions();
>> expe.test

ans =

    trials: [1x36 struct]
```
The first line of code will give a warning that you can ignore.

### Calibration

To modify the gain, you can edit the file `emotion_gain.m`. If the file does not exist, run the calibration script [`calibration.m`](../calibration.m). This gain is applied to the sounds before they are played. To avoid clipping, the gain should always be negative.

## Developer's notes

The emotion names in `emotion_build_conditions.m` have to match the image filenames in `../../Resources/images/emotion`.

## Contributors

The game was initially coded by Paolo Toffanin <p.toffanin@umcg.nl> and debugged by Jacqueline Libert <j.libert@rug.nl>.

The illustrations were created by [Jop Luberti](http://jopluberti.com/).

The experiment and export code were coded by Etienne Gaudrain <etienne.gaudrain@cnrs.fr> and Leanne Nagels <leanne.nagels@rug.nl>.

## About PICKA

PICKA stands for "Perception of Indexical Cues for Kids and Adults" and is a test battery aiming at evaluating various aspects of voice perception and its development in children from 4 years onwards and adults. For more details, see [the PICKA README](../../README.md).

## Copyright

See [the PICKA README](../../README.md).