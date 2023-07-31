#!/bin/bash

REPO_DIR=android-cuttlefish-automation
FLAG_DIR=${REPO_DIR}/flag_files
IMG_DIR=${REPO_DIR}/cuttlefish-images
mkdir -p ${FLAG_DIR}


if [ ! -f "${FLAG_DIR}/step1_complete" ]; then
    # Step 1: Check KVM availability
    echo "Step 2: Checking KVM availability..."
    if grep -q -w "vmx\|svm" /proc/cpuinfo; then
        echo "KVM is available."
    else
        echo "KVM is not available, exiting."
        exit 1
    fi
    touch ${FLAG_DIR}/step1_complete
fi

if [ ! -f "${FLAG_DIR}/step2_complete" ]; then
    # Step 2: Download, build, and install cuttlefish host debian packages
    echo "Installing dependencies and building cuttlefish..."
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
    echo "Rebooting in 5 seconds. Run this script again after reboot."
    touch ${FLAG_DIR}/step2_complete
    sleep 5
    sudo reboot
fi

if [ ! -f "${FLAG_DIR}/step3_complete" ]; then
    # Step 3: Download OTA image of Cuttlefish Virtual Device (CVD) and host package of Android Cuttleish
    echo "Step 3: Preparing OTA image of Cuttlefish virtual device (CVD) and host package of Android Cuttleish"
    mkdir cf
    mv ${IMG_DIR}/cvd-host_package.tar.gz cf/
    mv ${IMG_DIR}/aosp_cf_x86_64_phone-img-xxxxxx.zip cf/
    tar xvf cf/cvd-host_package.tar.gz -C cf/
    unzip cf/aosp_cf_x86_64_phone-img-xxxxxx.zip -d cf/
    touch ${FLAG_DIR}/step3_complete
fi

# Step 4: Launch cuttlefish
echo "Step 4: Launching cuttlefish..."
HOME=$PWD ./bin/launch_cvd
./bin/adb root
./bin/adb shell
