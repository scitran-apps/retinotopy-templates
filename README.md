# scitran/retinotopy-templates
Runs FreeSurfer's Recon-All and applies the retinotopy templates from Benson et al. (2014) PLOS Comput Biol to
the *generated* FreeSurfer subject output.


## Atlas of the Occipital Cortex

This Gear applies the V1, V2, and V3 anatomical template of retinotopy from
Benson et al. (2014) as well as the ROI template of Wang et al. (2015).
Currently this does not use the original version of the Benson et al. template
but rather an updated version that has also been published on the website
indicated in the original paper.


### Author

Noah C. Benson &lt;<nben@nyu.edu>&gt;


### Usage

This docker can be run with the following command:

```bash
docker run -ti --rm -v /path/to/your/freesurfer/subject:/input \
       scitran/retinotopy-templates
```

In the above example, the "/path/to/your/freesurfer/subject" is the path to an
individual FreeSurfer *subject*'s directory, not to the path of the FreeSurfer
SUBJECTS_DIR environment variable, which generally contains the individual
subject's directory. The "/input" is the directory inside of the Docker to which
the subject's directory is mapped (this must always be /input).

Note that the Docker expects that you have run the `xhemireg` and `surfreg`
scripts on your subject after having run `recon-all` in order to register the
subject's left and inverted-right hemispheres to the fsaverage_sym subject. (The
fsaverage_sym subject is a version of the fsaverage subject with a single the
left-right symmetric pseudo-hemisphere.) If your FreeSurfer version is 5.1 or
lower, you can obtain the scripts
[here](https://surfer.nmr.mgh.harvard.edu/fswiki/Xhemi). The scripts are
generally run as follows (using example subject 'bert'):

```bash
# Invert the right hemisphere
xhemireg --s bert
# Register the left hemisphere to fsaverage_sym
surfreg --s bert --t fsaverage_sym --lh
# Register the inverted right hemisphere to fsaverage_sym
surfreg --s bert --t fsaverage_sym --lh --xhemi
```

Additionally, the Gear may be run as follows to view the license file
(see the "License" section below) or this README file.

```bash
# View the License:
docker run -ti --rm scitran/retinotopy-templates license
# View the README:
docker run -ti --rm scitran/retinotopy-templates readme
```

#### Outputs
The script writes the following surface data files to
/path/to/your/freesurfer/subject/surf:
* lh.template_angle.mgz, rh.template_angle.mgz
* lh.template_eccen.mgz, rh.template_eccen.mgz
* lh.template_areas.mgz, rh.template_areas.mgz
* lh.wang2015_atlas.mgz, rh.wang2015_atlas.mgz

It additionally writes out the following volume files to
/path/to/your/freesurfer/subject/mri:

* native.template_angle.mgz
* native.template_eccen.mgz
* native.template_areas.mgz
* native.wang2015_atlas.mgz

The volume files are labeled native because they are oriented in FreeSurfer's
native LIA orientation (like the orig.mgz volume). Both the angle and
eccentricity are measured in degrees (for both hemispheres polar angle is
between 0 and 180 (0 is the upper vertical meridian) and eccentricity is between
0 and 90). The areas template specifies visual areas V1, V2, and V3 as the numbers
1, 2, and 3, respectively, and is 0 everywhere else. The angle and eccentricity
templates are also 0 outside of V1, V2, and V3.

If you wish to make volume files oriented identically to the original T1 used
with FreeSurfer's recon-all command (scanner orientation), the following
commands may be run after this Docker has completed; the command assumes that
your subject is named "bert" and your FreeSurfer SUBJECTS_DIR environment
variable is correctly set:

```bash
mri_convert -rl "$SUBJECTS_DIR/bert/mri/rawavg.mgz"            \
            "$SUBJECTS_DIR/bert/mri/native.template_angle.mgz" \
            "$SUBJECTS_DIR/bert/mri/scanner.template_angle.mgz"
```

#### Dependencies
The computations performed by this Docker use the Neuropythy neuroscience
library for Python by Noah C. Benson.


### References

* Benson NC, Butt OH, Datta R, Radoeva PD, Brainard DH, Aguirre GK  (**2012**)
  The retinotopic organization of striate cortex is well predicted by surface
  topology. _Curr Biol_**22**(21):2081-5.
  [doi:10.1016/j.cub.2012.09.014](http://www.ncbi.nlm.nih.gov/pubmed/23041195)
* Benson NC, Butt OH, Brainard DH, Aguirre GK (**2014**) Correction of
  distortion in flattened representations of the cortical surface allows
  prediction of V1-V3 functional organization from anatomy. _PLoS Comput Biol_
  **10**(3):e1003538.
  [doi:10.1371/journal.pcbi.1003538](http://www.ncbi.nlm.nih.gov/pubmed/24676149)
* Wang L, Mruczek RE, Arcaro MJ, Kastner S (**2015**) Probabilistic Maps of
  Visual Topography in Human Cortex. _Cereb Cortex_ **25**(10):3911-31.
  [doi:10.1093/cercor/bhu277](http://www.ncbi.nlm.nih.gov/pubmed/25452571)


### License

Copyright (C) 2016 by Noah C. Benson.

This README file is part of the occipital_atlas Docker.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  if not, see (http://www.gnu.org/licenses/).
