#!/bin/bash
####################################################################################################
# This script starts the process of applying the Benson et al. (2014) template to a freesurfer
# subject; it is intended for use with the apply_template.sh script in Docker.

if [ "${1}" = "license" ] || [ "${1}" = "LICENSE" ] || [ "${1}" = "License" ]
then cat /LICENSE.txt
     exit 0
elif [ "${1}" = "readme" ] || [ "${1}" = "README" ] || [ "${1}" = "Readme" ]
then cat /README.md
     exit 0
fi

if [ ! -d "/${1}" ] || [ ! -d "/${1}/surf" ] || [ ! -d "/${1}/mri" ]
then echo "Required inputs not found:"
     exit 1
fi

# Make sure our pythonpath is setup
export PYTHONPATH="$PYTHONPATH:/opt/neuropythy"

# Link input directory to subjects_dir
ln -s /${1} ${SUBJECTS_DIR}/${1} || {
    echo "Could not link /${1} to ${SUBJECTS_DIR}/${1}"
    exit 1
}

# okay, we can now apply the templates normally
/opt/share/retinotopy-template/apply_template.sh ${1} || {
  echo "apply_template.sh failed!"
  exit 1
}

exit 0
