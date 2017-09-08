# $Id$
# Maintainer: Balló György <ballogyor+arch at gmail dot com>

pkgname=budgie-desktop
_helper_pkgname=budgie-helper
pkgver=10.3.1
_helper_gitrev=3b52434b6d1cfe00c5bac1046d323813ce531a55
pkgrel=2
pkgdesc="Modern desktop environment from the Solus Project"
arch=('i686' 'x86_64')
url="https://solus-project.com/budgie"
license=('GPL' 'LGPL')
depends=('accountsservice' 'gnome-bluetooth' 'gnome-menus' 'gnome-session' 'gnome-themes-standard' 'libibus' 'libpeas' 'libwnck3' 'mutter')
makedepends=('autoconf-archive' 'git' 'gobject-introspection' 'intltool' 'meson' 'vala')
optdepends=('gnome-backgrounds: Default background'
            'gnome-control-center: System settings'
            'gnome-screensaver: Lock screen'
            'network-manager-applet: Network management')
source=("https://github.com/solus-project/budgie-desktop/releases/download/v$pkgver/$pkgname-$pkgver.tar.xz"{,.asc}
        "$_helper_pkgname-$_helper_gitrev.tar.gz::https://codeload.github.com/City-busz/$_helper_pkgname/tar.gz/$_helper_gitrev"
        07b5ce0a12f8fadba9bb7941b0874db5493ef034.patch
        c8950712cb95a257e9b08fd11507070f0c221d39.patch)
validpgpkeys=('8876CC8EDAEC52CEAB7742E778E2387015C1205F') # Ikey Doherty (Solus Project Founder)
sha256sums=('c19a5ac3f5cd1d142a87efded62f8a1750eb2af25102ff151da9201353a18b84'
            'SKIP'
            '3a4d7dd7c95ccba4e2916adf4a14769ffe54e8f86ed302d0268cd312b2a85c0e'
            '3f1c3b9d1ace34fcfb8d16f402336e5b427246a637cde0796101228970664b4c'
            '5bf292668f8a11ea5ba0f50ec791c9edf11cfbd70374e5ce302769b48d47056f')

prepare() {
	mkdir build
	cd $pkgname-$pkgver

	# Fix crash (FS#54679)
	patch -Np1 -i ../07b5ce0a12f8fadba9bb7941b0874db5493ef034.patch
	patch -Np1 -i ../c8950712cb95a257e9b08fd11507070f0c221d39.patch

	# Provide better compatibility for GNOME
	# https://github.com/solus-project/budgie-desktop/issues/261
	cd "$srcdir/$_helper_pkgname-$_helper_gitrev"
	NOCONFIGURE=1 ./autogen.sh
}

build() {
	cd build
	meson --prefix=/usr --buildtype=release ../$pkgname-$pkgver \
		--sysconfdir=/etc \
		-Dwith-gtk-doc=false
	ninja

	cd "$srcdir/$_helper_pkgname-$_helper_gitrev"
	./configure --prefix=/usr --sysconfdir=/etc --disable-schemas-compile --disable-Werror
	make
}

package() {
	cd build
	DESTDIR="$pkgdir" ninja install

	cd "$srcdir/$_helper_pkgname-$_helper_gitrev"
	make DESTDIR="$pkgdir" install
}