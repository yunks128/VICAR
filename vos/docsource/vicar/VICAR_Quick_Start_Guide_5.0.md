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
