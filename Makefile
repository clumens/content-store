sandbox:
	[ -d .cabal-sandbox ] || cabal sandbox init && cabal update

hlint: sandbox
	if [ -z "$$(which hlint)" ]; then \
		echo hlint not found in PATH - install it; \
		exit 1; \
	else \
		hlint .; \
	fi

tests: sandbox
	cabal install --dependencies-only --enable-tests --force-reinstalls
	cabal configure --enable-tests --enable-coverage --ghc-option=-DTEST
	cabal build
	cabal test --show-details=always

dist: sandbox
	cabal configure
	cabal sdist
	ln dist/content-store-*.tar.gz dist/content-store-latest.tar.gz

ci: tests hlint

ci_after_success: dist
	./scripts/hpc-coveralls
