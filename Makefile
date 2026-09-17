.PHONY: preflight serve build check

preflight:
	sh scripts/preflight.sh

serve:
	zola serve

build:
	zola build

check:
	$(MAKE) -C labs/malloc check
