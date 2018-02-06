# PICKA Installation procedure

This document describes how to install PICKA on your machine.

## Prerequisites

* You are supposed to have been granted access to the Google Drive repository where PICKA is available. The Github only contains the source code, but not the audio and visual resources.

* You need to have a Google Drive folder, locally, on your machine, synchronized with the online resource. In other words, you need to install Google Drive for desktop (https://www.google.com/drive/download/).

* You need to have Matlab, R2015b or newer, with the signal processing toolbox.

* You need to have Python 2.7 installed (not Python 3). At this time, on Mac and Linux, this is the case by default. On Windows, you will need to download and install the latest release of Python 2.7 (https://www.python.org/downloads/release/latest).

* You need around 300 MB of free space.

## Installation

In the Google Drive directory, navigate to the `Install` folder (where this README should be), and copy the setup file appropriate for you:

* setup_nl.m for tests in Netherlands Dutch.

* setup_gb.m for tests in British English.

You only need to copy that one file.

Once the file copied, paste it to directory where you want to install PICKA. *Not* in the Google Drive.

Open Matlab, navigate to that directory and execute the setup script and follow the instructions. You will be asked to select the Google Drive directory, and then the installation directory (which should be the current directory). Once you've made sure that the source and destination directories are correct, type "yes" to start the installation.

If all went well, that's it! You've installed PICKA! See the general manual for details on how to run the experiments.







