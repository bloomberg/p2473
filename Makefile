# Please see README.md for an in-depth explanation.

SRCROOT:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

MOCKXX:=$(SRCROOT)bin/mockxx
BMI_UUID:=$(shell $(MOCKXX) --bmi-uuid)
CXX=$(MOCKXX)

MODULE_PATH:=. $(SRCROOT) $(SRCROOT)/external-modules
VPATH=$(SRCROOT):$(SRCROOT)/external-modules

SOURCES= main.cpp \
	 foo/bar.ixx \
	 foo/baz.ixx \
	 foo/baz.part/part1.ixx \
	 foo/baz.part/part2.ixx

OBJECTS=$(patsubst %.cpp,%.o,$(patsubst %.ixx,%.o,$(SOURCES)))
CPPFLAGS=-DSEEN_ONLY_INSIDE_PROJECT=1
MODULE_SEARCH=$(patsubst %,--module-search-path=%,$(MODULE_PATH))

all: example-executable

example-executable: $(OBJECTS)
	$(CXX) $(MODULE_SEARCH) -o $@ $^

%.o: %.ixx
	mkdir -p $(dir $@) && $(CXX) $(CPPFLAGS) $(MODULE_SEARCH) -o $@ $<

%.o: %.cpp
	mkdir -p $(dir $@) && $(CXX) $(CPPFLAGS) $(MODULE_SEARCH) -o $@ $<

module_config.json: $(SOURCES) Makefile
	$(SRCROOT)bin/c++-modules-config -r $(MODULE_SEARCH) \
          --bmi-uuid=$(BMI_UUID) \
	  $(patsubst %,--parse-imports %,$(SOURCES)) -o $@

MODULE_RECIPE= mkdir -p $$(dir $$@) && \
 $$(CXX) $$(MODULE_CPPFLAGS) $$(MODULE_SEARCH) -b $$@ $$<
deps.mk: module_config.json
	$(SRCROOT)bin/c++-modules-makemake \
	  --module-cppflags-variable='MODULE_CPPFLAGS' \
	  --recipe '$(MODULE_RECIPE)' \
	  --bmi-uuid=$(BMI_UUID) -o $@ $<
include deps.mk

## ----------------------------------------------------------------------------
## Copyright 2021 Bloomberg Finance L.P.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ----------------------------- END-OF-FILE ----------------------------------
