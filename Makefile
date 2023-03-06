# Define variables
NOTEBOOKS := $(shell find . -name "*.ipynb")
PYTHON_SCRIPTS := $(patsubst %.ipynb,%.py,$(NOTEBOOKS))

# Define targets
.PHONY: all convert clean

all: convert

convert: $(PYTHON_SCRIPTS)

%.py: %.ipynb
	black $<
	jupytext --set-formats ipynb,py:percent --to py $< --output $(patsubst %.ipynb,%.py,$<)

clean:
	find . -name "*.py" -delete


