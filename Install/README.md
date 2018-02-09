# PICKA Installation procedure

This document describes how to install PICKA on your machine.

## Prerequisites

* You are supposed to have been granted access to the Google Drive repository where PICKA is available. Note that the Github only contains the source code, but not the audio and visual resources.

* You need to have a Google Drive folder, locally, on your machine, synchronized with the online resource. In other words, you need to install Google Drive for desktop — now called "Backup and Sync" (https://www.google.com/drive/download/). When you setup Google Drive, you can specify that you want to synchronize only one directory (it is advisable to have only the PICKA directory synchronized on your test machine). Also, by default, Google Drive with synchronize your Pictures and Videos directory. Better untick that before you start synchronizing. Now wait for Google Drive to download everything.

* You need to have Matlab, R2015b or newer, with the signal processing toolbox.

* You need to have Python 2.7 installed (_not Python 3_). At this time, on Mac and Linux, this is the case by default. On Windows, you will need to download and install the latest release of Python 2.7 (https://www.python.org/ftp/python/2.7.14/python-2.7.14.amd64.msi). To make sure it works, in Matlab, type `pyversion` and see if it points to the right version. Then, to check if loading the Python engine works properly, run `py.print('It works!')`. If there is no error message, you're good to go!

* You need around 300 MB of free space.

## Installation

In the Google Drive directory, navigate to the `Install` folder (where this README should be), and copy the setup file appropriate for you:

* setup_nl.m for tests in Netherlands Dutch.

* setup_gb.m for tests in British English.

You only need to copy that one file.

Once the file copied, paste it to directory where you want to install PICKA. *Not* in the Google Drive.

Open Matlab, navigate to that directory and execute the setup script and follow the instructions. You will be asked to select the Google Drive directory, and then the installation directory (which should be the current directory). Once you've made sure that the source and destination directories are correct, type "yes" to start the installation.

If all went well, that's it! You've installed PICKA! See the general manual for details on how to run the experiments.







