CASK = cask

SRCS = $(shell find .  -maxdepth 1 -name '*.el')
OBJECTS = $(SRCS:.el=.elc)
EMACS = $(shell sh -c 'evm bin')

.PHONY: test compile recompile clean

.cask:
	$(CASK) install

$(OBJECTS): .cask
	$(CASK) build --verbose

compile: $(OBJECTS)

clean-elc:
	rm -f $(OBJECTS)

recompile: clean-elc compile

clean: clean-elc
	rm -rf .cask/

test: recompile
	cask exec ert-runner -L $(PWD)
