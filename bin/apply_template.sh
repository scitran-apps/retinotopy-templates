#!/bin/bash
####################################################################################################
# This script applies the Benson et al. (2014) template and the Wang et al. (2015) atlas to a
# freesurfer subject and writes out a variety of possible files.

# This is the location of the template:
TEMPLATE_DIR="$SUBJECTS_DIR/fsaverage_sym/surf"
TEMPLATE_ANGLE_MGZ="$TEMPLATE_DIR/sym.template_angle.mgz"
TEMPLATE_ECCEN_MGZ="$TEMPLATE_DIR/sym.template_eccen.mgz"
TEMPLATE_AREAS_MGZ="$TEMPLATE_DIR/sym.template_areas.mgz"
WANG_ATLAS_DIR="$SUBJECTS_DIR/fsaverage/surf"
WANG_ATLAS_LH_MGZ="$WANG_ATLAS_DIR/lh.wang2015_atlas.mgz"
WANG_ATLAS_RH_MGZ="$WANG_ATLAS_DIR/rh.wang2015_atlas.mgz"

function help {
    cat <<EOF
Usage: apply_template.sh subject
The subject argument should just be a freesurfer subject; the following files
are placed in the subject's freesurfer directories on successful execution of
this command:
  * in subject/surf:
    - lh.template_angle.mgz
    - lh.template_eccen.mgz
    - lh.template_areas.mgz
    - lh.wang2015_atlas.mgz
    - rh.template_angle.mgz
    - rh.template_eccen.mgz
    - rh.template_areas.mgz
    - rh.wang2015_atlas.mgz
  * in subject/mri:
    - native.template_angle.mgz
    - native.template_eccen.mgz
    - native.template_areas.mgz
    - native.wang2015_atlas.mgz
The files placed in the surf directory are surface overlay mgz files while the
files placed in the mri directory are volume files. The native and scanner
prefixes refer to native orientation (as in orig.mgz) and scanner orientation
(as in rawavg.mgz), respectively.

Note: This Docker no longer creates the scanner.*.mgz files as they require a
FreeSurfer installation; to create these yourself, you can use the command:
mri_convert -rl rawavg.mgz native.<volume>.mgz scanner.<volume>.mgz
EOF
    exit 0
}

function die {
    echo "$1"
    exit 1
}

# Get our subject argument...
if   [ -z "$1" ]
then help
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]
then help
elif [ -d "$SUBJECTS_DIR/$1" ] && [ -d "$SUBJECTS_DIR/$1/surf" ]
then SUBPATH="$SUBJECTS_DIR/$1"
     SUB="$1"
else die "Could not locate FreeSurfer subject: $1"
fi

####################################################################################################
# Prolog: check for surfreg
# If the subject doesn't have an fsaverage_sym-registered hemisphere, we can do that first.

#[ -a "$SUBPATH/surf/lh.fsaverage_sym.sphere.reg" ] || {
#    echo "Registering subject's LH to fsaverage_sym hemisphere..."
#    surfreg --s "$SUB" --t fsaverage_sym --lh || die "LH to fsaverage_sym surfreg failed!"
#}
# Make sure there's an xhemi...
#[ -d "$SUBPATH/xhemi" ] || {
#    xhemireg --s "$SUB" || die "Could not create xhemi for subject!"
#}
#[ -a "$SUBPATH/xhemi/surf/lh.fsaverage_sym.sphere.reg" ] || {
#    echo "Registering subject's RH to fsaverage_sym hemisphere..."
#    surfreg --s "$SUB" --t fsaverage_sym --lh --xhemi || die "RH to fsaverage_sym surfreg failed!"
#}


####################################################################################################
# First step: surf2surf
# We need to create subject-surface templates for the subject using mri_surf2surf

# Retinotopy First
for HEM in LH RH
do hem="`echo $HEM | tr LRH lrh`"
   echo "Applying angle template to subject $HEM surface..."
   surf2surf "$HEM"                                                            \
             fsaverage_sym "$TEMPLATE_ANGLE_MGZ"                               \
             "$SUB"        "$SUBPATH/surf/${hem}.template_angle.mgz"           \
       || die "Could not apply angle template to $HEM surface!"
   echo "Applying eccen template to subject $HEM surface..."
   surf2surf "$HEM"                                                            \
             fsaverage_sym "$TEMPLATE_ECCEN_MGZ"                               \
             "$SUB"        "$SUBPATH/surf/${hem}.template_eccen.mgz"           \
       || die "Could not apply eccen template to $HEM surface!"
   echo "Applying areas template to subject $HEM surface..."
   surf2surf -n "$HEM"                                                         \
             fsaverage_sym "$TEMPLATE_AREAS_MGZ"                               \
             "$SUB"        "$SUBPATH/surf/${hem}.template_areas.mgz"           \
       || die "Could not apply areas template to $HEM surface!"
done
# Then Wang atlas
echo "Applying Wang et al. (2015) atlas to subject LH surface..."
surf2surf -n LH                                                                \
          fsaverage "$WANG_ATLAS_LH_MGZ"                                       \
          "$SUB"    "$SUBPATH/surf/lh.wang2015_atlas.mgz"                      \
    || die "Could not apply Wang et al. (2015) atlas to LH surface!"
echo "Applying Wang et al. (2015) atlas to subject RH surface..."
surf2surf -n RH                                                                \
          fsaverage "$WANG_ATLAS_RH_MGZ"                                       \
          "$SUB"    "$SUBPATH/surf/rh.wang2015_atlas.mgz"                      \
    || die "Could not apply Wang et al. (2015) atlas to RH surface!"

####################################################################################################
# Step 2: surf2vol
# Convert from the surface to the volume formats for both native and scanner space

# Templates first:
for tmplval in angle eccen areas
do LHINFL="$SUBPATH/surf/lh.template_$tmplval.mgz"
   RHINFL="$SUBPATH/surf/rh.template_$tmplval.mgz"
   NATFL="$SUBPATH/mri/native.template_$tmplval.mgz"
   SCAFL="$SUBPATH/mri/scanner.template_$tmplval.mgz"
   MTD="weighted"
   DTYPE="float"
   if [ "$tmplval" = "areas" ]; then MTD="max"; DTYPE="int"; fi
   echo "Constructing native FreeSurfer $tmplval template volume in $NATFL..."
   python -m neuropythy.__main__ surface_to_ribbon \
          -v -t"$DTYPE" -m"$MTD" -l"$LHINFL" -r"$RHINFL" \
          "$SUB" "$NATFL" \
       || die "Could not construct $tmplval volume templates!"
   #surf2ribbon "$SUB" "$LHINFL" "$RHINFL" "$NATFL" \
   #    || die "Could not construct $tmplval volume templates!"
done

# Then Wang atlas:
LHINFL="$SUBPATH/surf/lh.wang2015_atlas.mgz"
RHINFL="$SUBPATH/surf/rh.wang2015_atlas.mgz"
NATFL="$SUBPATH/mri/native.wang2015_atlas.mgz"
SCAFL="$SUBPATH/mri/scanner.wang2015_atlas.mgz"
MTD="max"
DTYPE="int"
echo "Constructing native FreeSurfer Wang et al. (2015) volume in $NATFL..."
python -m neuropythy.__main__ surface_to_ribbon \
       -v -t"$DTYPE" -m"$MTD" -l"$LHINFL" -r"$RHINFL" \
       "$SUB" "$NATFL" \
    || die "Could not construct $tmplval volume templates!"
#surf2ribbon "$SUB" "$LHINFL" "$RHINFL" "$NATFL" \
#    || die "Could not construct Wang volume!"

# That's it!
echo "Finished!"
echo ""
echo "To construct volumes oriented in the original T1's orientation (like the rawavg.mgz file),"
echo "use the following FreeSurfer command:"
echo " > mri_convert -rl rawavg.mgz native.<volume>.mgz scanner.<volume>.mgz"

