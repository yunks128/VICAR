# VICAR Quick-Start Guide  
**Version 5.0**  
*Updated: 2023-07-20*  

### Updated by:  
- Shari C. Mayer  
- Robert Deen, VICAR Cognizant Engineer  

Jet Propulsion Laboratory  
California Institute of Technology  
Pasadena, California  

*Copyright 2021 California Institute of Technology. Government sponsorship acknowledged.*

---

## Table of Contents
1. [Introduction](#introduction)  
   1.1. [What VICAR Is](#what-vicar-is)  
   1.2. [What VICAR Isn’t](#what-vicar-isnt)  
   1.3. [What this Guide Is](#what-this-guide-is)  
   1.4. [Brief History of VICAR](#brief-history-of-vicar)  
   1.5. [VICAR File Format](#vicar-file-format)  
   1.6. [Users of VICAR](#users-of-vicar)  
       1.6.1. [Historic](#historic)  
       1.6.2. [Current](#current)  
   1.7. [Components of VICAR in this Release](#components-of-vicar-in-this-release)  
   1.8. [Motivation for Release](#motivation-for-release)  
   1.9. [Obtaining VICAR](#obtaining-vicar)  
   1.10. [Supported Platforms](#supported-platforms)  

2. [Getting Started with VICAR](#getting-started-with-vicar)  
   2.1. [Documentation Status](#documentation-status)  
       2.1.1. [General Guides](#general-guides)  
       2.1.2. [VICAR User’s Guide](#vicar-users-guide)  
       2.1.3. [VICAR File Format](#vicar-file-format-details)  
       2.1.4. [VICAR Run-Time Library Reference Manual](#vicar-run-time-library-reference-manual)  
       2.1.5. [VICAR Porting Guide](#vicar-porting-guide)  
       2.1.6. [Building and Delivering VICAR Applications](#building-and-delivering-vicar-applications)  
       2.1.7. [Application Program Help (PDF files)](#application-program-help-pdf-files)  

---

## 1. Introduction

### 1.1 What VICAR Is
VICAR stands for **Video Image Communication and Retrieval**. It is an image processing system developed by the **(Multimission) Image Processing Lab (IPL or MIPL)**, at NASA’s Jet Propulsion Laboratory (JPL).

VICAR originated in the mid-1960s, making it likely the oldest continuously used image processing system globally. It was developed for JPL’s planetary missions, starting with **Surveyor (1966)**, and remains active today for projects like **Mars 2020**, **MER**, **MSL**, **Phoenix**, and **Insight**.

VICAR is fundamentally a **command-line-oriented system**, consisting of approximately 350 applications ranging from basic to highly complex. The system's power lies in combining these applications via scripts for systematic and advanced image processing.

Metadata handling is another critical feature of VICAR, with **labels** (in `KEYWORD=VALUE` format) integral to its functionality. These labels describe image acquisition conditions (e.g., temperature, pointing) and processing history, elevating VICAR files to scientifically valuable assets.

### 1.2 What VICAR Isn’t
VICAR is **not** Photoshop. While it includes some GUI elements like the "xvd" display program, VICAR primarily operates as a command-line system, not a graphical interface. 

If your goal is aesthetic image enhancements, tools like Photoshop are better suited. VICAR excels in tasks requiring scientific calibration, such as radiometric corrections, photometric analysis, and systematic production workflows.

Additionally, VICAR is not the same as **ISIS (Integrated Software for Imagers and Spectrometers)**. While they share some roots, VICAR and ISIS have distinct strengths. For example, ISIS excels in documentation, whereas VICAR may require more effort to learn.

### 1.3 What this Guide Is
This guide is intended to be an up-to-date, quick-start document to get you oriented with VICAR. It is **not** a full user’s guide. 

System-level documentation for VICAR is often outdated. While older documentation can be accurate in parts, many modern features (e.g., shell-VICAR) are not well covered. This guide bridges the gaps by highlighting valuable older resources and detailing newer capabilities.

Individual program documentation, however, is generally robust and detailed, describing program functionalities and operations extensively.

### 1.4 Brief History of VICAR
The history of VICAR is pieced together from multiple sources. Below is a timeline of significant milestones:  

- **1962/63**: Image processing proposed at JPL by Bob Nathan.  
- **1964/65**: Development of Video Film Converter and initial image processing code for Ranger data by Fred Billingsley, Roger Brandt, and Howard Frieden.  
- **1966**: VICAR written by Stan Bressler et al., first used for Surveyor.  
- **1971**: First open-source release through COSMIC, NASA's software clearinghouse.  
- **1984**: Conversion from IBM 360 to VAX/VMS, redesign of the file format.  
- **Early 1990s**: Ported to Unix, introduction of shell-VICAR.  
- **1994**: "xvd" display program developed.  
- **2004**: Ported to Mac OS X.  
- **2015**: VICAR core released as Open Source.

VICAR has been continuously updated and remains an active system, serving modern planetary missions and legacy data processing.

### 1.5 VICAR File Format
The VICAR file format is designed to simplify image processing. It consists of:
- **ASCII header**: Metadata in `KEYWORD=VALUE` format.  
- **Raster data**: A simple pixel raster, supporting multi-band data for applications like RGB color or multispectral analysis.

Labels are categorized as:
1. **System Labels**: Define file structure.  
2. **Property Labels**: Describe current file contents.  
3. **History Labels**: Record processing history.

Files are **uncompressed**, allowing random-access reads and writes. VICAR supports large files (up to 2 billion dimensions) and a variety of data types, including byte, int, float, double, and complex. VICAR files are compatible with **PDS3** and **PDS4** standards, enabling seamless use with Planetary Data Systems archives.

### 1.6 Users of VICAR

#### 1.6.1 Historic
VICAR has been pivotal in JPL’s planetary missions, from **Surveyor** and **Voyager** to **Mars Pathfinder** and **Galileo**. Beyond planetary missions, VICAR has supported projects like:
- **AVIRIS**: Airborne multispectral imaging.  
- **NEAT**: Asteroid tracking.  
- Earth-mapping initiatives using **Landsat**, **MODIS**, and more.

#### 1.6.2 Current
Today, VICAR remains integral to JPL operations, particularly:
- **Mars Surface Missions**: Supporting **MER**, **MSL**, and **Mars 2020** operations.  
- **AFIDS**: Earth mosaic/cartography system for automated image processing and cartographic projections.  
- **Cassini**: Telemetry processing, data validation, and mapping.  

Other users include DLR Berlin, PDS Rings Node, and various Earth science initiatives involving classification, segmentation, and anomaly detection.

### 1.7 Components of VICAR in this Release
Key components in the current VICAR release include:
- ~350 application programs (See Section 5).  
- Shell-VICAR for command-line operations.  
- VICAR-format Image I/O library (C/C++/Fortran and Java).  
- **"xvd" display program**: For image visualization.  
- **File format conversion utility ("transcoder")**: Converts between formats like VICAR, PDS, ISIS, FITS, JPEG, PNG, etc.  
- **VISOR**: Tools for Mars surface processing.  

### 1.8 Motivation for Release
Reasons for the 2015 open-source release:
- VICAR had a long history of open-source delivery until the 1990s.  
- Source code accessibility simplifies user interactions.  
- ITAR compliance concerns were mitigated by removing restricted components.  
- Encourages modern collaboration on platforms like GitHub.  
- Enables preservation and reusability of legacy mission data.

### 1.9 Obtaining VICAR
VICAR is available on GitHub:  
[https://github.com/NASA-AMMOS/VICAR/releases](https://github.com/NASA-AMMOS/VICAR/releases)

### 1.10 Supported Platforms
VICAR is officially supported on **Linux (64-bit)** and known to work on:
- **Mac OS X**: Using a centos7 Docker image.  
- **Windows 10**: Via a centos7 Docker image.  

---

## 2. Getting Started with VICAR

### 2.1 Documentation Status
#### 2.1.1 General Guides
VICAR documentation is a mixed bag. While program-specific documents are generally thorough, system-level documentation can be outdated.

#### 2.1.2 VICAR User’s Guide
Written in 1994, the **VICAR User’s Guide** remains partially relevant but lacks details on modern features like shell-VICAR.

#### 2.1.3 VICAR File Format
The **VICAR File Format** guide (1994/95) is still accurate, with updates like support for dual-labeled files (e.g., VICAR and PDS3/ODL). Details on platform names and experimental compression are also addressed.

#### 2.1.4 VICAR Run-Time Library Reference Manual
The **Run-Time Library (RTL)** manual remains up-to-date, with newer routines like `zvplabel2` added for label management.

#### 2.1.5 VICAR Porting Guide
While helpful for legacy migrations (e.g., VMS to Unix), most relevant content is now part of the RTL manual.

#### 2.1.6 Building and Delivering VICAR Applications
Describes the application build system (**vimake**) and packer (**vpack**). Templates provide additional documentation for custom macros.

#### 2.1.7 Application Program Help (PDF files)
Each VICAR program includes a **Parameter Definition File (PDF)** describing parameters and operations in detail. Note that these are text files, not Adobe PDF documents.
