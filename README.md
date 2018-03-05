<img src="https://github.com/egaudrain/PICKA/raw/master/Resources/images/html/PICKA-3-600dpi.png" width="150">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <img src="https://github.com/egaudrain/PICKA/raw/master/Resources/images/html/rug.png" height="50">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <img src="https://github.com/egaudrain/PICKA/raw/master/Resources/images/html/umcg.png" height="55">


# PICKA – Perception of Indexical Cues in Kids and Adults

PICKA is a test battery developed by the University Medical Center Groningen to evaluate the development of the perception of indexical cues through childhood.

## Installation

Details of the installation are available in [the install folder](Install/README.md).

Remember: **Do not run PICKA from the Google Drive directory!** You must copy it on your machine first. The installation script will also localise the files to adapt them to your own language.

## Running PICKA

PICKA comes with an "experiment runner" that lets you see the progress of a participant in the various experiments. To start the runner, start Matlab, navigate to the `Experiments` folder of your newly installed PICKA, and run:

```matlab
>> picka
```

You will be asked to provide the ID of a participant. If you want to create a new participant, just leave it empty and a dialog will show up. The ID of the participant has the following format: `[country]_[NH|CI|HI][A|K][000]`, that is an ISO country code (`nl` or `gb`), underscore, a description of the group (in capitals, normal hearing: `NH`, hearing-impaired: `HI` or cochlear implant: `CI`), immediately followed by the age group (`A` for adults and `K` for kids), and finally the subject number as a 3-digit zero-padded number. Here are a few examples:

- `nl_NHA001` is valid

- `gb_CIK123` is valid

- `uk_CIK123` is **not** valid because the country code is `gb` not `uk`

- `nl_NHC001` is **not** valid because the age group is `A` or `K`, not `C`

- `nl_NHK10` is **not** valid because the number must have 3 digits

When created through the GUI, the participant ID will be checked for consistency with the nomenclature before it can be used.

If you want to call PICKA for an existing participant, either pass the name as an argument, for instance:

```matlab
>> picka('nl_NHA001');
```

Or call `picka` without any argument but fill the name when prompted to do so.

If a participant already exist, you should be able to see their progress. If a participant *should* exist but you don't see any progress, something as gone wrong, most likely that the participant ID was mistyped either this time, or at the previous session. Double check your result files, and see the following sections about what to do.

## Experiments

The current version of PICKA contains 4 experiments:

- **CRM**: a speech-on-speech test with various voices and target-to-masker ratios (see [details](Experiments/CRM/README.md)).

- **emotion**: an emotion recognition test (see [details](Experiments/emotion/README.md)).

- **fishy**: an adaptive tracking of the just-noticeable-difference for F0 and VTL (see [details](Experiments/fishy/README.md)).

- **gender**: a gender categorization test (see [details](Experiments/gender/README.md)).

All experiments can be accessed through the experiment runner `picka` or directly in the individual directory through the run function of each experiment (e.g. `fishy_run(...)`).

## Results files

Each experiment is storing its own results in the form of a single MAT file per subject. These files are located in the `results` folder of each experiment, and should not be renamed or deleted. You should take a backup of these files regularly, preferably at the end of each testing session. One way is to copy the results back to the Google Drive folder, and let Google Drive upload them in the shared space. See "Backup the results" below.

**Renaming the file has no effect on the subject name!** See the section "Ensuring data consistency" for more details.

### Backup the results

To copy all results to the Google Drive, use the `save_results` function. Running this script will first export all results in SQLite and CSV formats, and copy all the MAT, SQLite and CSV files to the Google Drive. As soon as the computer is connected to the internet, the files will be uploaded.

It is a good idea to also make weekly copies of the whole PICKA folder on an external drive.

### Export formats

Each experiment folder contains an `export_results` script. With that script you can export results in three formats: SQLite, CSV or XLS.

__SQLite__ is a database format based on SQL that is ubiquitous on all systems nowadays. It is easy to import results in R, Python, or any modern data manipulation software. All data is exported into SQLite before being converted into another format. To view an SQLite file, you can use, e.g. Valentina Studio.

__CSV__ is comma separated values. It is widely recognized, including by Excel, R and Python. (Note that non-English Excel can sometimes struggle CSV files when the decimal separation symbol is a comma. In that case, LibreOffice provides a more reliable way of opening CSV files for visual inspection.)

__XLS__ files are provided here only for convenience. Remember that the data is not supposed to be manipulated manually, so only use Excel for visualisation.

### Ensuring data consistency

The experiments are coded in a way that prevents data to be overwritten or lost. If an experiment crashes in the middle, restarting it with the same participant ID will continue where it stopped. This ensures the robustness of the data collection, but has two downsides:

- The participant ID is extremely important. If there is a mix up, e.g. if participant John Doe is tested on day 1 with ID `nl_NHA003` but on day 2 with ID `nl_NHA008`, the experiment will either restart from the beginning; or if `nl_NHA008` already existed and had started the experiment, the data will get mixed in the result file with no way of knowing which one belong to which one apart from the date and time of testing. **So it is imperative to keep a lab book and an up to date list of the link between ID and name.** Also, it means that merely renaming the file will not solve the problem. The participant ID is stored in the file as well as in the filename. **Don't rename the files!**

- The result file contains all the options, which makes it self reliable, and prevents option details to be lost. However, if the option file (`*_build_conditions.m`) is modified during the experiment, the options for all the participants who had started before that will remain unchanged. What we gain in robustness, we lose in flexibility.

## Calibration

Calibration is an important part of any psychophysical experiment, especially when a population with hearing deficiencies is tested. The calibration procedure not only ensures that the experiment is repeatable, but also that the presentation level is appropriate for the listeners taking part in the experiment.

For PICKA, the aim of the calibration is that all stimuli are presented at a sound pressure level of __65 dB(A)__. This level ensures audibility in normal hearing listeners, as well as hearing impaired listeners using a prosthetic device.

**Before running the calibration, make sure you called the `preprocess_picka` function.**

To facilitate the calibration, PICKA comes with GUI gathering all the experiments. To start it, from the `Experiments` folder, just run:

```matlab
>> calibration();
```

Then, take the following steps:

1. Set the volume of your computer to max. On Windows, there might be separate volumes for different applications: set Matlab and the System volume to max.

2. Play the sound through the equipment that will be used for the actual experiment (computer, soundcard, headphones/loudspeakers).

3. Measure the sound level from a KEMAR attached to a sound level meter.

4. Adjust the gain field so reach a level of 65 dB(A). Negative values will attenuate the sound. Positive values are forbidden as they would result in the clipping of some stimuli.

5. Once satisfied with all the gains, click "Save gains to files".

When calling the `calibration` function, Matlab will check that all the sounds necessary are present, and that the different stimuli used for an experiment have been equalised in RMS (i.e. all the sound files have the same RMS).

## Folder tree

Here's a description of the content of the PICKA folder:

- `Experiments` contains the experiment runner, the participant's GUI and the code for the individual experiments, each containing a `results` sub-directory where the raw data is stored. The `save_results` function will copy these files back to Google Drive folder.

	+ `CRM`

	+ `emotion`

	+ `fishy`

	+ `gender`

- `Forms and Protocols` contains the documents necessary for the experimenter.

- `Install` a collection of Python and Matlab scripts to manage the installation and taking snapshots of potentially modified code.

- `Resources` contains the sound, images and libraries used in PICKA. The generated cached files are also stored here.

	+ `images` all the graphical assets used in the different experiments

	+ `lib`

		* `baseTandemSTRAIGHTV009x` the newer version of STRAIGHT (not used in this version).

		* `MatlabCommonTools` a collection of useful tools for psychoacoustical experiments.

		* `mksqlite` a Matlab interface to SQLite.

		* `python` a collection of Python modules used for installation or data export.

		* `SpriteKit` a Matlab library to create video games.

		* `STRAIGHTV40_006b` the legacy version of STRAIGHT (currently used).

		* `vocoder_2015` a versatile Matlab vocoder (currently not used).

	+ `sounds` all the audio stimuli used in the different experiments.

	+ `tmp` contains the cache files generated by the various experiments.


