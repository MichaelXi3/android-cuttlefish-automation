#!/bin/bash

BASE_DIR=~/android-cuttlefish-auto
FLAG_DIR=${BASE_DIR}/flag_files

mkdir -p ${BASE_DIR}
mkdir -p ${FLAG_DIR}

cd ${BASE_DIR}

# Step 1: Check KVM availability
if [ ! -f "${FLAG_DIR}/step1_complete" ]; then
    echo "Step 1: Checking KVM availability..."
    if grep -q -w "vmx\|svm" /proc/cpuinfo; then
        echo "KVM is available."
    else
        echo "KVM is not available, exiting."
        exit 1
    fi
    touch ${FLAG_DIR}/step1_complete
fi

# Step 2: Download, build, and install cuttlefish host debian packages
if [ ! -f "${FLAG_DIR}/step2_complete" ]; then
    echo "Step 2: Installing dependencies and building cuttlefish..."
    sudo apt update
    sudo apt install -y git devscripts config-package-dev debhelper-compat golang curl
    git clone https://github.com/google/android-cuttlefish
    cd android-cuttlefish
    for dir in base frontend; do
      cd $dir
      debuild -i -us -uc -b -d
      cd ..
    done
    sudo dpkg -i ./cuttlefish-base_*_*64.deb || sudo apt-get install -f
    sudo dpkg -i ./cuttlefish-user_*_*64.deb || sudo apt-get install -f
    sudo usermod -aG kvm,cvdnetwork,render $USER
    echo "Rebooting in 5 seconds. Run this bash script again after reboot!"
    touch ${FLAG_DIR}/step2_complete
    sleep 5
    sudo reboot
fi

# Step 3: Download OTA image of Cuttlefish Virtual Device (CVD) and host package of Android Cuttleish
if [ ! -f "${FLAG_DIR}/step3_complete" ]; then
    echo "Step 3: Downloading OTA image of Cuttlefish virtual device (CVD) and host package of Android Cuttleish from Google Drive..."
    mkdir cf
    # Install gdown if not already installed
    pip install gdown --quiet
    # Replace with the actual file IDs
    FILE_ID_1=1va_j0k4NaklRoQtdfhnqYGuOa-SY9f7-
    FILE_ID_2=1HCH7EAFcwtQ3qtYuwnvC0DemtSbBLoJb
    MAKE_FILE_ID=1TuuRz8B8eml_p7EdYCkdWs5K6cPoou2U
    gdown --id ${FILE_ID_1} -O cf/cvd-host_package.tar.gz
    gdown --id ${FILE_ID_2} -O cf/aosp_cf_x86_64_phone-img-10586990.zip
    gdown --id ${MAKE_FILE_ID} -O cf/Makefile
    tar xvf cf/cvd-host_package.tar.gz -C cf/
    unzip cf/aosp_cf_x86_64_phone-img-10586990 -d cf/
    touch ${FLAG_DIR}/step3_complete
fi

# Step 3.5: clean the flag files
rm -rf ${FLAG_DIR}

# Step 4: Launch cuttlefish
echo "Step 4: Launching cuttlefish..."
cd cf
HOME=$PWD ./bin/launch_cvd --daemon
sleep 15
./bin/adb root
./bin/adb shell