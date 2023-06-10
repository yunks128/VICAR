# VICAR
[VICAR, which stands for Video Image Communication And Retrieval,](https://www.hou.usra.edu/meetings/planetdata2015/pdf/7059.pdf) is a general purpose image processing software system that has been developed since 1966 to digitally process multi-dimensional imaging data.

The VICAR core contains a large number of multimission application programs and utilities.  The general VICAR web page is [https://www-mipl.jpl.nasa.gov/vicar.html](https://www-mipl.jpl.nasa.gov/vicar.html).

Also included in the VICAR Open Source delivery are the following major subsystems:

## VISOR
VISOR, VICAR In-Situ Operations for Robotics, formerly known as the “Mars Suite”, is a set of VICAR programs used for operational and PDS
archive image processing for all recent Mars surface missions at NASA Jet Propulsion Laboratory (JPL). VISOR is included as part of VICAR starting with Release 5.  The VISOR release announcement is here: [6th Planetary Data Workshop(2023), abstract #7076](https://www.hou.usra.edu/meetings/planetdata2023/pdf/7076.pdf).

## AFIDS-POMM
[AFIDS-POMM, or Automatic Fusion of Image Data System - Planetary Orbital Mosaicking and Mapping,](https://www.hou.usra.edu/meetings/lpsc2023/pdf/1261.pdf) is a set of workstation tools supporting the automation of planetary orbital mosaicking and mapping requirements. In a future VICAR open source release, the AFIDS-POMM source code is intended to be merged and maintained as part of the VICAR open source repo.  Currently, only a few of the applications are available.

In the meantime, you can download the AFIDS-POMM docker releases from: https://github.com/NASA-AMMOS/AFIDS-POMM

## Labelocity
Labelocity is a toolset for generating PDS4 labels.  It is included as part of the VICAR Open Source Release but is also available separately at [https://github.com/NASA-AMMOS/labelocity](https://github.com/NASA-AMMOS/labelocity), where you can find documentation for it.  Labelocity is also discussed in [6th Planetary Data Workshop(2023), abstract #7071](https://www.hou.usra.edu/meetings/planetdata2023/pdf/7071.pdf).

# What's New in Release 5
Please visit the VICAR Open Source release homepage:  (((XXXXXX IS THIS PARTICULARLY USEFUL ANY MORE?)))

[http://www-mipl.jpl.nasa.gov/vicar_open.html](http://www-mipl.jpl.nasa.gov/vicar_open.html).

This release includes:

- Pre-built binaries for 32- and 64-bit Linux(Red Hat 7.3) and Mac OS X 64-bit. 
- A Docker Centos7 image that runs the 64-bit Linux binaries (Java 1.8).
- A Docker Centos7 image preloaded with VOS 64-bit Linux(Red Hat 7.3) using Java 1.8.
- All of VISOR (in $MARSLIB), XXXXX application programs
- XXXXX new application programs: 
  XXXXXavgpix 
  XXXXXcomprs 
  XXXXXcrosshair 
  XXXXXmedval
  XXXXXnimsr2iof 
  XXXXXsdsems
- XXXXX19 anomalies, 72 bug fixes/improvements. For release notes, [click here](vos/docsource/vicar/VOS5-Release-Notes.pdf).

For a full list of programs being released [click here](vos/docsource/vicar/VICAR_OS_contents_v4.0.pdf).

# Obtaining VICAR

VICAR can be obtained in two ways: pre-built binaries via tarball download (which includes source), or source code via github.com.

In addition to the VICAR source code an externals package containing 3rd party software is required.  The externals come in the form of a tarball that contains all the platforms, as well as separate tarballs for each platform.  Externals are 3rd party packages that are required to run VICAR. See section 2 of the [Building VICAR document](vos/docsource/vicar/VICAR_build_4.0.pdf) for more information. You need only the one that
applies to your machine type.

For VISOR, you will also need the calibration directory for the mission(s) you will be working with.  Sample data for use with the VISOR User Guide is also available.

### Source Code

* GitHub: [https://github.com/NASA-AMMOS/VICAR](https://github.com/NASA-AMMOS/VICAR]
* Main VICAR source code:  [Click to download](https://github.com/NASA-AMMOS/VICAR/tarball/master)

### Pre-built Binaries

* Pre-built VICAR binaries are available for Linux (64-bit) and MacOS (x86, 64 bit) [https://github.com/NASA-AMMOS/VICAR/releases](here).

### Externals

* Linux 32-bit externals:  [Click to download](http://www-mipl.jpl.nasa.gov/vicar_os/v5.0/vicar_open_ext_x86-linux_5.0.tar.gz)
* Linux 64-bit externals:  [Click to download](http://www-mipl.jpl.nasa.gov/vicar_os/v5.0/vicar_open_ext_x86-64-linx_5.0.tar.gz)
* Mac OS X externals:  [Click to download](http://www-mipl.jpl.nasa.gov/vicar_os/v5.0/vicar_open_ext_mac64-osx_5.0.tar.gz)
* Solaris externals:  [Click to download](http://www-mipl.jpl.nasa.gov/vicar_os/v5.0/vicar_open_ext_sun-solr_5.0.tar.gz)
* All externals (don't get unless you know you need this): [Click to download](http://www-mipl.jpl.nasa.gov/vicar_os/v5.0/vicar_open_ext_5.0.tar.gz)

### VISOR Calibration files

* [Mars 2020, Perseverence and Ingenuity](XXXX)
* [Mars Science Laboratory (MSL), Curiosity](XXXX)
* [InSight lander](XXXX)
* [Mars Exploration Rover (MER), Spirit and Opportunity](XXXX)
* [Phoenix lander](XXXX)
* [MSAM (Mastcam Stereo Analysis and Mosaics), a PDART task for MSL-Mastcam data](XXXX)
* [All calibration files in one tarball (4.6 GB)](XXXX)

### VISOR Sample Data

* [VISOR Sample Data for User Guide](XXXX)

# Getting Started

For any use of VICAR (including VISOR and AFIDS), we recommend the Quick-Start Guide:

* [VICAR Quick-Start Guide](vos/docsource/vicar/VICAR_guide_4.0.pdf).

The Installation Guide is useful for prebuilt binaries and critical if you want to attempt to build VICAR:

* [VICAR installation guide](vos/docsource/vicar/VICAR_build_4.0.pdf).

If you want to use the VISOR Mars programs, first review the VICAR Quick-Start Guide and then the VISOR User Guide:

* [VISOR User Guide](XXXX)

# VICAR Discussion Forum

We have set up a [VICAR Open Source Google group](https://groups.google.com/forum/#!forum/vicar-open-source/), where you can find notifications of new releases, bug reports, and general discussion. You can join the group [here](https://groups.google.com/forum/#!forum/vicar-open-source/join).

Questions:  vicar_help@jpl.nasa.gov
