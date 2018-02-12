<img src="../master/Resources/images/html/PICKA-3-600dpi.png" width="150">

# PICKA – Perception of Indexical Cues in Kids and Adults

PICKA is a test battery developed by the University Medical Center Groningen to evaluate the development of the perception of indexical cues through childhood.

## Exporting results

To copy all results to the Google Drive, use the `save_results` function.

Each experiment folder contains an `export_results` script. With that script you can export results in three formats: SQLite, CSV or XLS.

__SQLite__ is a database format based on SQL that is ubiquitous on all systems nowadays. It is easy to import results in R, Python, or any modern data manipulation software. All data is exported into SQLite before being converted into another format. To view an SQLite file, you can use, e.g. Valentina Studio.

__CSV__ is comma separated values. It is widely recognized, including by Excel, R and Python. (Note that non-English Excel can sometimes struggle CSV files when the decimal separation symbol is a comma. In that case, LibreOffice provides a more reliable way of opening CSV files for visual inspection.)

__XLS__ files are provided here only for convenience. Remember that the data is not supposed to be manipulated manually, so only use Excel for visualisation.

## Calibration

Calibration is an important part of any psychophysical experiment, especially when a population with hearing deficiencies is tested. The calibration procedure not only ensures that the experiment is repeatable, but also that the presentation level is appropriate for the listeners taking part in the experiment.

For PICKA, the aim of the calibration is that all stimuli are presented at a sound pressure level of _65 dB(A)_. This level ensures audibility in normal hearing listeners, as well as hearing impaired listeners using a prosthetic device.

To facilitate the calibration, PICKA comes with GUI gathering all the experiments. To start it, from the `Experiments` folder, just run:

```matlab
>>> calibration();
```

Then, take the following steps:

	1. Set the volume of your computer to max. On Windows, there might be separate volumes for different applications: set Matlab and the System volume to max.

	2. Play the sound through the equipment that will be used for the actual experiment (computer, soundcard, headphones/loudspeakers).

	3. Measure the sound level from a KEMAR attached to a sound level meter.

	4. Adjust the gain field so reach a level of 65 dB(A). Negative values will attenuate the sound. Positive values are forbidden as they would result in the clipping of some stimuli.

	5. Once satisfied with all the gains, click "Save gains to files".

When calling the `calibration` function, Matlab will check that all the sounds necessary are present, and that the different stimuli used for an experiment have been equalised in RMS (i.e. all the sound files have the same RMS).
