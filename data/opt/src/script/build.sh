#!/bin/bash

DIR_INSTALL=/opt/pgmodeler
DIR_POSTGRESQL=/opt/postgresql
DIR_SRC=/opt/src
DIR_SRC_PGMODELER=${DIR_SRC}/pgmodeler
export PATH=/opt/mxe/usr/bin:${PATH}
TOOLCHAIN=x86_64-w64-mingw32.shared

function build() {
     local dir_mxe=/opt/mxe
     local dir_mxe_toolchain=${dir_mxe}/usr/${TOOLCHAIN}
     local dir_qt=${dir_mxe_toolchain}/qt6
     local dir_plugins=${dir_qt}/plugins
     local dir_plugins_install=${DIR_INSTALL}/qtplugins
     local objdump=${dir_mxe}/usr/bin/${TOOLCHAIN}-objdump

     cd ${DIR_SRC_PGMODELER}

     # Replace some bits that are only relevant when building ON Windows.

     sed -i pgmodeler.pri -e 's/^.*wingetdate.*$/ BUILDNUM=$$system("date \x27+%Y%m%d\x27")/' pgmodeler.pri

     # Build pgModeler.

     ${TOOLCHAIN}-qt6-qmake -r PREFIX=${DIR_INSTALL} PGSQL_INC=${DIR_POSTGRESQL}/include \
          PGSQL_LIB=${DIR_POSTGRESQL}/lib/libpq.dll XML_INC=${dir_mxe_toolchain}/include/libxml2 \
          XML_LIB=${dir_mxe_toolchain}/bin/libxml2-2.dll
     make
     make install
     rm ${DIR_INSTALL}/*.a

     # Copy dependencies.

     cd ${DIR_SRC}/pydeployqt

     ./deploy.py --build=${DIR_INSTALL} --objdump=${objdump} ${DIR_INSTALL}/pgmodeler.exe
     ./deploy.py --build=${DIR_INSTALL} --objdump=${objdump} ${DIR_INSTALL}/pgmodeler-ch.exe
     ./deploy.py --build=${DIR_INSTALL} --objdump=${objdump} ${DIR_INSTALL}/pgmodeler-cli.exe

     cp ${dir_qt}/bin/Qt6Network.dll ${DIR_INSTALL}
     cp ${dir_qt}/bin/Qt6PrintSupport.dll ${DIR_INSTALL}
     cp ${dir_qt}/bin/Qt6Svg.dll ${DIR_INSTALL}
     cp ${dir_mxe_toolchain}/bin/libcrypto-3-x64.dll ${DIR_INSTALL}
     cp ${dir_mxe_toolchain}/bin/liblzma-5.dll ${DIR_INSTALL}
     cp ${dir_mxe_toolchain}/bin/libssl-3-x64.dll ${DIR_INSTALL}
     cp ${dir_mxe_toolchain}/bin/libxml2-2.dll ${DIR_INSTALL}
     cp ${DIR_POSTGRESQL}/lib/libpq.dll ${DIR_INSTALL}

     # Add QT configuration.

     echo -e "[Paths]\nPrefix=.\nPlugins=qtplugins\nLibraries=." > ${DIR_INSTALL}/qt.conf

     # Copy QT plugins.

     mkdir -p ${dir_plugins_install}/platforms

     cp -R ${dir_plugins}/imageformats ${dir_plugins_install}
     cp ${dir_plugins}/platforms/qwindows.dll ${dir_plugins_install}/platforms
     #cp -R ${dir_plugins}/printsupport ${dir_plugins_install}
}

function clone_source() {
     cd ${DIR_SRC}

     git clone https://github.com/pgmodeler/pgmodeler.git
}

function check_version() {
     local tags_file=$(mktemp)

     cd ${DIR_SRC_PGMODELER}

     git tag > ${tags_file}

     echo ""

     if [ -z "${1}" ]
     then
          echo -e "Missing pgModeler version.  Valid versions:\n"
          cat ${tags_file}

          exit 0
     fi

     if [[ "${1}" =~ $(echo ^\($(paste -sd'|' ${tags_file})\)$) ]]
     then
          git checkout -b ${1} ${1}
     else
          echo -e "Invalid pgModeler version '${1}'.  Valid versions:\n"
          cat ${tags_file}

          exit 0
     fi
}

clone_source
check_version ${1}
build