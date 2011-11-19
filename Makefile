
BASE_DIR=${PWD}
DOWNLOAD_DIR=${BASE_DIR}/download
SRC_DIR=${BASE_DIR}/src
MY_BIN_DIR=${BASE_DIR}/bin

# Do not include MacPorts bin dir /opt/local/bin
MY_PATH=${MY_BIN_DIR}:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin

# arch must be i386 to build 32bit app.
RAPIDSVN_ARCH=-arch i386

DB_BASENAME=db-4.8.30.NC
APR_BASENAME=apr-1.4.5
APR_UTIL_BASENAME=apr-util-1.3.12
NEON_BASENAME=neon-0.29.6
SVN_BASENAME=subversion-1.7.1
WXMAC_BASENAME=wxMac-2.8.12
RAPIDSVN_BASENAME=rapidsvn-trunk

DB_DIR=${SRC_DIR}/${DB_BASENAME}
APR_DIR=${SRC_DIR}/${APR_BASENAME}
APR_UTIL_DIR=${SRC_DIR}/${APR_UTIL_BASENAME}
NEON_DIR=${SRC_DIR}/${NEON_BASENAME}
SVN_DIR=${SRC_DIR}/${SVN_BASENAME}
WXMAC_DIR=${SRC_DIR}/${WXMAC_BASENAME}
RAPIDSVN_DIR=${SRC_DIR}/${RAPIDSVN_BASENAME}

DB_TARBALL=${DB_BASENAME}.tar.gz
APR_TARBALL=${APR_BASENAME}.tar.bz2
APR_UTIL_TARBALL=${APR_UTIL_BASENAME}.tar.bz2
NEON_TARBALL=${NEON_BASENAME}.tar.gz
SVN_TARBALL=${SVN_BASENAME}.tar.bz2
WXMAC_TARBALL=${WXMAC_BASENAME}.tar.gz
SVN_PATH_PATCH=patch-path.c.diff

DB_TARBALL_URL=http://download.oracle.com/berkeley-db/${DB_TARBALL}
APR_TARBALL_URL=http://www.apache.org/dist/apr/${APR_TARBALL}
APR_UTIL_TARBALL_URL=http://www.apache.org/dist/apr/${APR_UTIL_TARBALL}
NEON_TARBALL_URL=http://www.webdav.org/neon/${NEON_TARBALL}
SVN_TARBALL_URL=http://www.apache.org/dist/subversion/${SVN_TARBALL}
WXMAC_TARBALL_URL=http://downloads.sourceforge.net/project/wxwindows/2.8.12/${WXMAC_TARBALL}
SVN_PATH_PATCH_URL=http://trac.macports.org/browser/trunk/dports/devel/subversion/files/${SVN_PATH_PATCH}?format=txt
RAPIDSVN_SOURCE_URL=http://rapidsvn.tigris.org/svn/rapidsvn/trunk

CURL=/usr/bin/curl -L
MAKE=/usr/bin/make

DB_CONFIG_STATUS=${DB_DIR}/build_unix/config.status
DB_BUILD_CHECK_FILE=${DB_DIR}/build_unix/libdb-4.8.a
DB_INSTALL_CHECK_FILE=${BASE_DIR}/lib/libdb-4.8.a

APR_CONFIG_STATUS=${APR_DIR}/config.status
APR_BUILD_CHECK_FILE=${APR_DIR}/libdb-1.la
APR_INSTALL_CHECK_FILE=${BASE_DIR}/lib/libapr-1.a

APR_UTIL_CONFIG_STATUS=${APR_UTIL_DIR}/config.status
APR_UTIL_BUILD_CHECK_FILE=${APR_UTIL_DIR}/libdbutil-1.la
APR_UTIL_INSTALL_CHECK_FILE=${BASE_DIR}/lib/libaprutil-1.a

NEON_CONFIG_STATUS=${NEON_DIR}/config.status
NEON_BUILD_CHECK_FILE=${NEON_DIR}/src/libneon.la
NEON_INSTALL_CHECK_FILE=${BASE_DIR}/lib/libneon.a

SVN_CONFIG_STATUS=${SVN_DIR}/config.status
SVN_BUILD_CHECK_FILE=${SVN_DIR}/subversion/libsvn_client/libsvn_client-1.la
SVN_INSTALL_CHECK_FILE=${BASE_DIR}/lib/libsvn_client-1.a

WXMAC_CONFIG_STATUS=${WXMAC_DIR}/config.status
WXMAC_BUILD_CHECK_FILE=${WXMAC_DIR}/lib/libwx_macu_core-2.8.a
WXMAC_INSTALL_CHECK_FILE=${BASE_DIR}/lib/libwx_macu_core-2.8.a

RAPIDSVN_CONFIG_STATUS=${RAPIDSVN_DIR}/config.status
RAPIDSVN_BUILD_TARGET_FILE=${RAPIDSVN_DIR}/packages/osx/RapidSVN-0.13.0.dmg
RAPIDSVN_INSTALL_TARGET_FILE=${BASE_DIR}/RapidSVN-0.13.0-svn1.7.dmg


all: install_rapidsvn

download: download_db download_apr download_apr_util download_neon \
	download_svn download_svn_path_patch download_wxmac download_rapidsvn

distclean: distclean_db distclean_apr distclean_apr_util distclean_neon \
	distclean_svn distclean_wxmac distclean_rapidsvn

clean_install:
	rm -rf ${BASE_DIR}/bin ${BASE_DIR}/build-1 ${BASE_DIR}/docs \
		${BASE_DIR}/include ${BASE_DIR}/lib ${BASE_DIR}/share \
		${RAPIDSVN_BUILD_TARGET_FILE}


download_db: ${DOWNLOAD_DIR}/${DB_TARBALL}

${DOWNLOAD_DIR}/${DB_TARBALL}: ${DOWNLOAD_DIR}
	if [ ! -f ${DOWNLOAD_DIR}/${DB_TARBALL} ]; then \
		${CURL} ${DB_TARBALL_URL} -o ${DOWNLOAD_DIR}/${DB_TARBALL}; \
	fi

extract_db: ${DB_DIR}

${DB_DIR}: ${SRC_DIR} ${DOWNLOAD_DIR}/${DB_TARBALL}
	if [ ! -d ${DB_DIR} ]; then \
		tar zxf ${DOWNLOAD_DIR}/${DB_TARBALL} -C ${SRC_DIR}; \
	fi

configure_db: ${DB_CONFIG_STATUS}

${DB_CONFIG_STATUS}: ${DB_DIR}
	if [ ! -f ${DB_CONFIG_STATUS} ]; then \
		export PATH=${MY_PATH}; \
		export RAPIDSVN_ARCH=${RAPIDSVN_ARCH}; \
		cd ${DB_DIR}/build_unix; \
		CFLAGS="-O3 ${RAPIDSVN_ARCH} -mmacosx-version-min=10.4 -fvisibility=hidden" \
			LDFLAGS="${RAPIDSVN_ARCH} -mmacosx-version-min=10.4" \
			../dist/configure --prefix=${BASE_DIR} --disable-shared; \
	fi

build_db: ${DB_BUILD_CHECK_FILE}

${DB_BUILD_CHECK_FILE}: ${DB_CONFIG_STATUS}
	cd ${DB_DIR}/build_unix; \
	${MAKE}

install_db: ${DB_INSTALL_CHECK_FILE}

${DB_INSTALL_CHECK_FILE}: ${DB_BUILD_CHECK_FILE}
	if [ ! -f ${DB_INSTALL_CHECK_FILE} ]; then \
		cd ${DB_DIR}/build_unix; \
		${MAKE} install; \
	fi

distclean_db:
	cd ${DB_DIR}/build_unix; \
	${MAKE} distclean


download_apr: ${DOWNLOAD_DIR}/${APR_TARBALL}

${DOWNLOAD_DIR}/${APR_TARBALL}: ${DOWNLOAD_DIR}
	if [ ! -f ${DOWNLOAD_DIR}/${APR_TARBALL} ]; then \
		${CURL} ${APR_TARBALL_URL} -o ${DOWNLOAD_DIR}/${APR_TARBALL}; \
	fi

extract_apr: ${APR_DIR}

${APR_DIR}: ${SRC_DIR} ${DOWNLOAD_DIR}/${APR_TARBALL}
	if [ ! -d ${APR_DIR} ]; then \
		tar jxf ${DOWNLOAD_DIR}/${APR_TARBALL} -C ${SRC_DIR}; \
	fi

configure_apr: ${APR_CONFIG_STATUS}

${APR_CONFIG_STATUS}: ${APR_DIR}
	if [ ! -f ${APR_CONFIG_STATUS} ]; then \
		export PATH=${MY_PATH}; \
		export RAPIDSVN_ARCH=${RAPIDSVN_ARCH}; \
		cd ${APR_DIR}; \
		CFLAGS="-O3 ${RAPIDSVN_ARCH} -mmacosx-version-min=10.4 -fvisibility=hidden" \
			LDFLAGS="${RAPIDSVN_ARCH} -mmacosx-version-min=10.4" \
			./configure --prefix=${BASE_DIR} --disable-shared; \
	fi

build_apr: ${APR_BUILD_CHECK_FILE}

${APR_BUILD_CHECK_FILE}: ${APR_CONFIG_STATUS}
	cd ${APR_DIR}; \
	${MAKE}

install_apr: ${APR_INSTALL_CHECK_FILE}

${APR_INSTALL_CHECK_FILE}: ${APR_BUILD_CHECK_FILE}
	if [ ! -f ${APR_INSTALL_CHECK_FILE} ]; then \
		cd ${APR_DIR}; \
		${MAKE} install; \
	fi

distclean_apr:
	cd ${APR_DIR}; \


download_apr_util: ${DOWNLOAD_DIR}/${APR_UTIL_TARBALL}

${DOWNLOAD_DIR}/${APR_UTIL_TARBALL}: ${DOWNLOAD_DIR}
	if [ ! -f ${DOWNLOAD_DIR}/${APR_UTIL_TARBALL} ]; then \
		${CURL} ${APR_UTIL_TARBALL_URL} -o ${DOWNLOAD_DIR}/${APR_UTIL_TARBALL}; \
	fi

extract_apr_util: ${APR_UTIL_DIR}

${APR_UTIL_DIR}: ${SRC_DIR} ${DOWNLOAD_DIR}/${APR_UTIL_TARBALL}
	if [ ! -d ${APR_UTIL_DIR} ]; then \
		tar jxf ${DOWNLOAD_DIR}/${APR_UTIL_TARBALL} -C ${SRC_DIR}; \
	fi

configure_apr_util: ${APR_UTIL_CONFIG_STATUS}

${APR_UTIL_CONFIG_STATUS}: ${APR_UTIL_DIR} install_db install_apr
	if [ ! -f ${APR_UTIL_CONFIG_STATUS} ]; then \
		export PATH=${MY_PATH}; \
		export RAPIDSVN_ARCH=${RAPIDSVN_ARCH}; \
		cd ${APR_UTIL_DIR}; \
		CFLAGS="-O3 ${RAPIDSVN_ARCH} -mmacosx-version-min=10.4 -fvisibility=hidden" \
			LDFLAGS="${RAPIDSVN_ARCH} -mmacosx-version-min=10.4" \
			./configure --prefix=${BASE_DIR} --with-apr=${BASE_DIR} \
			--with-dbm=db48 --with-berkeley-db=${BASE_DIR}; \
	fi

build_apr_util: ${APR_UTIL_BUILD_CHECK_FILE}

${APR_UTIL_BUILD_CHECK_FILE}: ${APR_UTIL_CONFIG_STATUS}
	cd ${APR_UTIL_DIR}; \
	${MAKE}

install_apr_util: ${APR_UTIL_INSTALL_CHECK_FILE}

${APR_UTIL_INSTALL_CHECK_FILE}: ${APR_UTIL_BUILD_CHECK_FILE}
	if [ ! -f ${APR_UTIL_INSTALL_CHECK_FILE} ]; then \
		cd ${APR_UTIL_DIR}; \
		${MAKE} install; \
	fi

distclean_apr_util:
	cd ${APR_UTIL_DIR}; \
	${MAKE} distclean


download_neon: ${DOWNLOAD_DIR}/${NEON_TARBALL}

${DOWNLOAD_DIR}/${NEON_TARBALL}: ${DOWNLOAD_DIR}
	if [ ! -f ${DOWNLOAD_DIR}/${NEON_TARBALL} ]; then \
		${CURL} ${NEON_TARBALL_URL} -o ${DOWNLOAD_DIR}/${NEON_TARBALL}; \
	fi

extract_neon: ${NEON_DIR}

${NEON_DIR}: ${SRC_DIR} ${DOWNLOAD_DIR}/${NEON_TARBALL}
	if [ ! -d ${NEON_DIR} ]; then \
		tar zxf ${DOWNLOAD_DIR}/${NEON_TARBALL} -C ${SRC_DIR}; \
	fi

configure_neon: ${NEON_CONFIG_STATUS}

${NEON_CONFIG_STATUS}: ${NEON_DIR}
	if [ ! -f ${NEON_CONFIG_STATUS} ]; then \
		cd ${NEON_DIR}; \
		export PATH=${MY_PATH}; \
		CFLAGS="-O3 ${RAPIDSVN_ARCH} -mmacosx-version-min=10.4 -fvisibility=hidden" \
			LDFLAGS="${RAPIDSVN_ARCH} -mmacosx-version-min=10.4" \
			./configure --prefix=${BASE_DIR} --disable-shared --with-ssl=openssl; \
	fi

build_neon: ${NEON_BUILD_CHECK_FILE}

${NEON_BUILD_CHECK_FILE}: ${NEON_CONFIG_STATUS}
	cd ${NEON_DIR}; \
	${MAKE}

install_neon: ${NEON_INSTALL_CHECK_FILE}

${NEON_INSTALL_CHECK_FILE}: ${NEON_BUILD_CHECK_FILE}
	if [ ! -f ${NEON_INSTALL_CHECK_FILE} ]; then \
		cd ${NEON_DIR}; \
		${MAKE} install; \
	fi

distclean_neon:
	cd ${NEON_DIR}; \
	${MAKE} distclean


download_svn: ${DOWNLOAD_DIR}/${SVN_TARBALL}

${DOWNLOAD_DIR}/${SVN_TARBALL}: ${DOWNLOAD_DIR}
	if [ ! -f ${DOWNLOAD_DIR}/${SVN_TARBALL} ]; then \
		${CURL} ${SVN_TARBALL_URL} -o ${DOWNLOAD_DIR}/${SVN_TARBALL}; \
	fi

download_svn_path_patch: ${DOWNLOAD_DIR}/${SVN_PATH_PATCH}

${DOWNLOAD_DIR}/${SVN_PATH_PATCH}:
	if [ ! -f ${DOWNLOAD_DIR}/${SVN_PATH_PATCH} ]; then \
		${CURL} ${SVN_PATH_PATCH_URL} -o ${DOWNLOAD_DIR}/${SVN_PATH_PATCH}; \
	fi

extract_svn: ${SVN_DIR}

${SVN_DIR}: ${SRC_DIR} ${DOWNLOAD_DIR}/${SVN_TARBALL} ${DOWNLOAD_DIR}/${SVN_PATH_PATCH}
	if [ ! -d ${SVN_DIR} ]; then \
		tar jxf ${DOWNLOAD_DIR}/${SVN_TARBALL} -C ${SRC_DIR}; \
		cd ${SVN_DIR}; \
		patch -p0 < ${DOWNLOAD_DIR}/${SVN_PATH_PATCH}; \
	fi

configure_svn: ${SVN_CONFIG_STATUS}

${SVN_CONFIG_STATUS}: ${SVN_DIR} install_db install_apr install_apr_util
	if [ ! -f ${SVN_CONFIG_STATUS} ]; then \
		cd ${SVN_DIR}; \
		export PATH=${MY_PATH}; \
		export RAPIDSVN_ARCH=${RAPIDSVN_ARCH}; \
		CFLAGS="-g -O2 ${RAPIDSVN_ARCH} -mmacosx-version-min=10.4 -fvisibility=hidden -I${BASE_DIR}/include" \
			LDFLAGS="${RAPIDSVN_ARCH} -mmacosx-version-min=10.4 -L${BASE_DIR}/lib" ./configure --prefix=${BASE_DIR} \
			--with-berkeley-db --disable-shared --without-apxs --with-apr=${BASE_DIR} --with-apr-util=${BASE_DIR}; \
	fi

build_svn: ${SVN_BUILD_CHECK_FILE}

${SVN_BUILD_CHECK_FILE}: ${SVN_CONFIG_STATUS}
	cd ${SVN_DIR}; \
	${MAKE}

install_svn: ${SVN_INSTALL_CHECK_FILE}

${SVN_INSTALL_CHECK_FILE}: ${SVN_BUILD_CHECK_FILE}
	if [ ! -f ${SVN_INSTALL_CHECK_FILE} ]; then \
		cd ${SVN_DIR}; \
		${MAKE} install; \
	fi

distclean_svn:
	cd ${SVN_DIR}; \
	${MAKE} distclean


download_wxmac: ${DOWNLOAD_DIR}/${WXMAC_TARBALL}

${DOWNLOAD_DIR}/${WXMAC_TARBALL}: ${DOWNLOAD_DIR}
	if [ ! -f ${DOWNLOAD_DIR}/${WXMAC_TARBALL} ]; then \
		${CURL} ${WXMAC_TARBALL_URL} -o ${DOWNLOAD_DIR}/${WXMAC_TARBALL}; \
	fi

extract_wxmac: ${WXMAC_DIR}

${WXMAC_DIR}: ${SRC_DIR} ${DOWNLOAD_DIR}/${WXMAC_TARBALL}
	if [ ! -d ${WXMAC_DIR} ]; then \
		tar zxf ${DOWNLOAD_DIR}/${WXMAC_TARBALL} -C ${SRC_DIR}; \
	fi

configure_wxmac: ${WXMAC_CONFIG_STATUS}

${WXMAC_CONFIG_STATUS}: ${WXMAC_DIR}
	if [ ! -f ${WXMAC_CONFIG_STATUS} ]; then \
		cd ${WXMAC_DIR}; \
		export PATH=${MY_PATH}; \
		sed -e "s#-arch ppc -arch i386#${RAPIDSVN_ARCH}#" < configure > configure-rapidsvn; \
		chmod +x configure-rapidsvn; \
		CFLAGS="-I${BASE_DIR}/include/apr-1 -fvisibility=hidden" \
			CXXFLAGS="-I${BASE_DIR}/include/apr-1 -fvisibility=hidden -fvisibility-inlines-hidden" \
			LDFLAGS="-L${BASE_DIR}/lib" \
			./configure-rapidsvn --prefix=${BASE_DIR} \
			--disable-shared --enable-unicode --enable-universal_binary \
			--with-macosx-version-min=10.4 --with-macosx-sdk=/Developer/SDKs/MacOSX10.6.sdk; \
	fi

build_wxmac: ${WXMAC_BUILD_CHECK_FILE}

${WXMAC_BUILD_CHECK_FILE}: ${WXMAC_CONFIG_STATUS}
	cd ${WXMAC_DIR}; \
	${MAKE}

install_wxmac: ${WXMAC_INSTALL_CHECK_FILE}

${WXMAC_INSTALL_CHECK_FILE}: build_wxmac
	if [ ! -f ${WXMAC_INSTALL_CHECK_FILE} ]; then \
		cd ${WXMAC_DIR}; \
		${MAKE} install; \
	fi

distclean_wxmac:
	cd ${WXMAC_DIR}; \
	${MAKE} distclean


download_rapidsvn: ${RAPIDSVN_DIR}

${RAPIDSVN_DIR}:
	if [ ! -d ${RAPIDSVN_DIR} ]; then \
		svn co ${RAPIDSVN_SOURCE_URL} ${RAPIDSVN_DIR}; \
	fi

configure_rapidsvn: ${RAPIDSVN_CONFIG_STATUS}

${RAPIDSVN_CONFIG_STATUS}: ${RAPIDSVN_DIR} install_apr install_apr_util install_wxmac install_svn
	if [ ! -f ${RAPIDSVN_CONFIG_STATUS} ]; then \
		cd ${RAPIDSVN_DIR}; \
		export PATH=${MY_PATH}; \
		./autogen.sh; \
		CFLAGS="-g -O2 ${RAPIDSVN_ARCH} -fvisibility=hidden -I${BASE_DIR}/include" \
			CXXFLAGS="-g -O2 ${RAPIDSVN_ARCH} -fvisibility=hidden -fvisibility-inlines-hidden" \
			LDFLAGS="${RAPIDSVN_ARCH} -L${BASE_DIR}/lib" ./configure --prefix=${BASE_DIR} \
			--disable-shared \
			--with-svn-include=${BASE_DIR}/include \
			--with-svn-lib=${BASE_DIR}/lib \
			--with-apr-config=${BASE_DIR}/bin/apr-1-config \
			--with-apu-config=${BASE_DIR}/bin/apu-1-config \
			--with-wx-config=${BASE_DIR}/bin/wx-config \
			--disable-dependency-tracking; \
	fi

build_rapidsvn: ${RAPIDSVN_BUILD_TARGET_FILE}

${RAPIDSVN_BUILD_TARGET_FILE}: ${RAPIDSVN_CONFIG_STATUS} install_db \
		install_apr install_apr_util install_neon install_svn install_wxmac
	if [ ! -f ${RAPIDSVN_BUILD_TARGET_FILE} ]; then \
		cd ${RAPIDSVN_DIR}; \
		${MAKE}; \
		cd packages/osx; \
		./make_osx_bundle.sh; \
	fi

install_rapidsvn: ${RAPIDSVN_INSTALL_TARGET_FILE}

${RAPIDSVN_INSTALL_TARGET_FILE}: ${RAPIDSVN_BUILD_TARGET_FILE}
	cp ${RAPIDSVN_BUILD_TARGET_FILE} ${RAPIDSVN_INSTALL_TARGET_FILE}

distclean_rapidsvn:
	cd ${RAPIDSVN_DIR}; \
	${MAKE} distclean


download_dir: ${DOWNLOAD_DIR}

${DOWNLOAD_DIR}:
	mkdir ${DOWNLOAD_DIR}

src_dir: ${SRC_DIR}

${SRC_DIR}:
	mkdir ${SRC_DIR}
