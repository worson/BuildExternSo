# Lists cpu architecture of android.
# android_abi=("armeabi-v7a")
android_abi=("x86" "x86_64" "arm64-v8a" "armeabi-v7a")


libname=$1
script_path=$0
work_dir=${script_path%/*}
artifact_dir=${work_dir}/artifact

echo "Project Dir is $work_dir"
echo "Expect lib is $libname "

# Downloads third party source code.
if [ -z "${ANDROID_SDK_PATH}" ] ;then
   echo "\$ANDROID_SDK_PATH is empty, please export SDK path to \$ANDROID_SDK_PATH"
   exit 1
fi

NDK_PATH="${ANDROID_SDK_PATH}"/ndk-bundle/;
if [ ! -d "${NDK_PATH}" ] ;then
  echo "NDK bundle not found at location ${NDK_PATH}"
  exit 1
fi

if [ -d ${artifact_dir} ]; then
    rm -rf ${artifact_dir}
fi
mkdir ${artifact_dir}

for ((i=0; i < ${#android_abi[@]}; i++));
do
  mkdir -p ${artifact_dir}/${android_abi[$i]}
done

android_toolchain_path="${NDK_PATH}"/build/cmake/android.toolchain.cmake
echo "android cmake toolchain path is ${android_toolchain_path}"

# Executes cmake command in third_party/CMakeLists.txt.in for all cpu architecture.
for ((i=0; i < ${#android_abi[@]}; i++))
do
  cd ${work_dir}
  rm -rf ./build
  if [ ! -d ./build ]; then
    mkdir ./build
  fi
  cd ./build
  cmake -DCMAKE_TOOLCHAIN_FILE=${android_toolchain_path} -DANDROID_ABI=${android_abi[$i]} ..
  make
  libPath="${work_dir}/build/lib/${libname}"
  if [ -f "${libPath}" ]; then
    cp ${libPath} ${artifact_dir}/${android_abi[$i]}
  else
    echo "can not find lib file ${libPath} "
  fi
done
