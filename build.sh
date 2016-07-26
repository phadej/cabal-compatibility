#!/bin/sh

set -e

ghcs="7.0.4 7.2.2 7.4.2 7.6.3 7.8.4 7.10.3 8.0.1 head"
cabals="1.16 1.18 1.22 1.24 head"

cd ghc-paths

ORIGPATH=$PATH

cabalbuild() {
	echo "=========== cabal build"
	rm -rf dist
	cabal configure
	cabal build
}

setupbuild() {
	echo "=========== setup build"
	rm -rf dist
	mkdir -p dist/setup
	ghc -o dist/setup/setup Setup.hs
	dist/setup/setup configure
	dist/setup/setup build
}

newbuild() {
	if [ "$CABALVER" = "1.24" -o "$CABALVER" = "head" ]; then
		echo "=========== new build"
		rm -rf new-dist
		cabal new-build
	fi
}

for GHCVER in $ghcs; do
	for CABALVER in $cabals; do
		echo ghc-$GHCVER cabal-$CABALVER
		export PATH=/opt/ghc/$GHCVER/bin:/opt/cabal/$CABALVER/bin:$ORIGPATH

		ghc --version
		cabal --version

		# remove sandbox
		# cabal sandbox delete || true
		
		cabalbuild || true
		setupbuild || true
		newbuild || true
	done
done
