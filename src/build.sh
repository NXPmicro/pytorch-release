#！/bin/bash

# Copyright 2020 NXP
# SPDX-License-Identifier: BSD-3-Clause

CWD=$(dirname $(readlink -f "$0"))

# check out pytorch code
if [ ! -d pytorch ]; then
  git clone --recursive https://github.com/pytorch/pytorch
fi
cd pytorch
git checkout v1.7.1 -b v1.7.1
git reset --hard v1.7.1
git submodule sync
git submodule update --init --recursive

cd third_party/sleef
git reset --hard 3.5.1
cd -

# build pytorch wheel file
export MAX_JOBS=$(nproc)
export USE_CUDA=0
export USE_NNPACK=0
export USE_QNNPACK=0
export CMAKE_PREFIX_PATH=/usr/bin
export PYTORCH_BUILD_VERSION=1.7.1
export PYTORCH_BUILD_NUMBER=1

python3 setup.py bdist_wheel

# check the wheel file in dist folder
# mv dist/*.whl topdir/whl


# build the wheel file for torchvision
cd $CWD
if [ ! -d vision ]; then
  git clone https://github.com/pytorch/vision.git
fi
cd vision
git checkout v0.8.2 -b v0.8.2
git reset --hard v0.8.2

# pytorch is build dependcy for torchvision, check and install it.
torch_pkg="$(python3 -m pip list --format=freeze | grep "torch==1.7.1")"
if [ -z "$torch_pkg" ]; then
  torch_wheel=$(ls $CWD/pytorch/dist/torch-*.whl)
  yes | python3 -m pip install $torch_wheel
fi

export BUILD_VERSION=0.8.2
python3 setup.py bdist_wheel

# check the wheel file in dist folder
# mv dist/*.whl topdir/whl
