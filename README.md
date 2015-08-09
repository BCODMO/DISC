# Drifting In Situ Chamber User Software in R

## Installation

1. Install R from <http://cran.rstudio.com/>

2. Optionally install RStudio from <http://www.rstudio.com/products/rstudio/download/>

2. Install `discr`. `discr` is an R package but it is not (yet) available in the official R packages repositories. To install it, start RStudio and, in the console, type

        install.packages("devtools")
        devtools::install_github("jiho/discr")

3. Load `discr` and check your installation with

        library("discr")
        disc_check()
    
    `disc_check()` will give you platform-specific pointers to install the software `discr` depends on. `discr` needs
    
    - A java JRE to run the image manipulation parts; from <https://www.java.com/en/download/>
    - The `exif` executable from `libexif` to extract timestamp from images; installation is usually done through a package manager
    - ImageMagick (the `convert` executable) to resize images to more manageable sizes; from <http://www.imagemagick.org/> or through a package manager


## Basic usage

### Start a new project

In R, use

    library("discr")
    disc_start_project()

to create a new project template in the current directory (you can then move it to wherever you want). See `?disc_start_project` for other arguments.


### Data collection

Raw data collected with the DISC is stored in one directory (`raw` in the project template). A subdirectory is created for each deployment leg (usually one per day). Within each leg, a subdirectory is created for each sensor on the DISC (camera, compass, light sensor, etc.). The information for every leg and every deployment within each leg is written down in a log file, in the form of a spreadsheet (saved as a Comma Separated Values, `*.csv`, file), which is stored in the `raw` directory.

The final hierarchy usually looks like

    DISC_A/
        raw/
            leg_1/
                pics/
                    G001234.JPG
                    G001235.JPG
                    G001236.JPG
                    ...
                compass/
                    DATALOG.txt
                hobo/
                    123459.hobo
                    123459.csv
                ...
            leg_2/
                pics/
                compass/
                hobo/
                ...
            leg_log.csv
            deployment_log.csv

The format for the `leg_log.csv` file is:

      leg, gopro_start, gopro_stop, gopro_dir, gopro_offset, cc_start, ...
    leg_1,    12:22:25,   17:35:01,      pics,           -6, 12:20:10, ...
    leg_2,         ...,

It has the leg directory name and information for each sensor. The column names are in the form `sensorName_informationLabel`. The underscore (`_`) in the middle is important. The usual information labels for each sensor are :

- `start` and `stop` : the start and stop time of the sensor (not used by `discr` but important to record)
- `dir` : the name of the directory in which the sensor data is stored. When absent, this is supposed to be the name of the sensor itself. Pictures should always be stored in a directory called `pics`; compass data should always be stored in a directory called `compass`; the rest of the names are free.
- `offset` : the time offset (in seconds) between the sensor time and a reference time (usually the time of a computer). When absent, it is supposed to be 0. The offset is *added* to the timestamp of the data to correct it back to the reference time. So it should be negative when the sensor is early and positive when it is late. For example, if the sensor records 08:55:12 but the actual time is 08:55:10, the sensor is early and the offset is -2.

Other columns can be added but should *not* have an underscore in their names. Use dots (`personal.comments`) or capitals (`personalComments`) to separate words.


The format for the `deployment_log.csv` is:

    deploy_id,   leg, date_start,  date_stop, time_start, time_stop
            1, leg_1, 2014-05-22, 2014-05-22,   23:31:23,  23:52:10
            2, leg_1, 2014-05-22, 2014-05-23,   23:54:34,  00:05:12
            3, leg_1, 2014-05-23, 2014-05-23,   00:08:15,  00:29:12
          ...

It has

- `deploy_id` : a *unique* deployment identifier. It can be anything but is usually an integer number(as here), which makes it easy to specify ranges of deployments.
- `leg` : the corresponding leg directory name
- `date_start`, `date_stop` : date in format YYYY-MM-DD.
- `time_start`, `time_stop` : time in format HH:MM:SS; the combination of date and time allows deployments to cross midnight

The deployment log usually has other columns such as fish species, meteorological conditions, etc. The names of those columns are free, but try to avoid special characters (accents, parentheses, exponents, etc.)


### Extract deployments

The directory described above holds the whole raw data record. To be analysed, it needs to be split into deployments. The deployments are smaller than the raw data and are usually stored in another directory of your project called `deployments`. Once all the deployments are extracted, the raw data (which can be quite big) can be moved and stored elsewhere.

In an R console, in your project directory:

    library("discr")
    disc_extract_deployments(raw="raw")
        
If you want to extract only a few deployments, use

    disc_extract_deployments(raw="raw", ids=10:20)

for deployments 10 to 20 or

    disc_extract_deployments(raw="raw", ids=c("1a", "2a", "2b", "6"))

for deployments 1a, 2a, 3b and 6, for example. (NB: This highlights why having integer deployment identifiers is easier.)

See `?disc_extract_deployments` for more information.


### Process deployments

In your project directory, load `discr`

    library("discr")

Then process deployments with a command such as

    disc(1:10, actions=c("calib", "track"))

to calibrate the arena dimensions and track the larva, in deployments 1 to 10.

See `?disc` for a description of all actions and more examples. Default actions are "calibrate", "track", "correct", and "stats".

Check your progress with

    disc_status()
    # or
    dstatus()
    # for short

and now `disc()` again. Good luck!


### Analyse data

Again, open R in your project directory and load `discr`

    library("discr")

Check available data with

    disc_status()

Collect statistics for all larvae in a `data.frame` with

    disc_assemble("stats")

Alternatively, you can select a few deployments only with

    disc_assemble("stats", ids=1:10)

You can also collect all tracks, or gps data, or hobo data, etc. with

    disc_assemble("rotated_larvae_tracks")
    disc_assemble("gps_log")
    disc_assemble("hobo_log")

What `disc_assemble()` does is look for files with the given pattern in their name, read them all and concatenate the result.

Now you are ready to do you analyses in R. `discr` provides a few helpful functions to work with angles

    ?summary.circular
    ?polar
    ?circular_dotplot
    ?angles

check out the `circular` package for other.

## Advanced usage

If storing your deployments in a subdirectory of your working directory is not appropriate (not enough space on hard drive, etc.), you can store them elsewhere and still get to them from your working directory, either by providing the path through the `deploy.dir` argument of each function, or, more efficiently, by setting it at the start of the session with `disc_dd`. See `?disc_dd` for more information.

New sensors can easily be added and handled by `discr`; see `?disc_read` for more information.

## Credit

`discr` is written by [Jean-Olivier Irisson](http://www.obs-vlfr.fr/~irisson/ "jean-olivier irisson : work"), at Université Pierre et Marie Curie ([UPMC](http://www.upmc.fr/)). All code is released under the [GNU General Public License v3.0](https://www.gnu.org/copyleft/gpl.html "The GNU General Public License v3.0 - GNU Project - Free Software Foundation").

The DISC instrument is developed by [Claire Paris](https://www.rsmas.miami.edu/users/cparis/ "Physical-Biological Interactions - Paris' Lab") at the Rosenstiel School of Marine and Atmospheric Sciences ([RSMAS](http://www.rsmas.miami.edu/ "| The Rosenstiel School of Marine and Atmospheric Science at the University of Miami")) of the University of Miami.

Most of the image analysis functionality relies on [ImageJ](http://imagej.net/ "ImageJ") by Wayne Rasband.

Circular statistics are performed with the package [circular](http://cran.r-project.org/package=circular "CRAN - Package circular") for R.

