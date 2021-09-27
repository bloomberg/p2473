# Please see README.md for an in-depth explanation.

SRCROOT:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

MOCKXX:=$(SRCROOT)bin/mockxx
BMI_UUID:=$(shell $(MOCKXX) --bmi-uuid)
CXX=$(MOCKXX)

MODULE_PATH:=. $(SRCROOT) $(SRCROOT)/external-modules
VPATH=$(SRCROOT):$(SRCROOT)/external-modules

SOURCES= \
	main.cpp \
	foo/bar.ixx \
	foo/baz.ixx \
	foo/baz.part/part1.ixx \
	foo/baz.part/part2.ixx

OBJECTS=$(patsubst %.cpp,%.o,$(patsubst %.ixx,%.o,$(SOURCES)))
CPPFLAGS=$(patsubst %,-I%,$(MODULE_PATH))

all: example-executable

%.bmi.$(BMI_UUID): %.ixx
	mkdir -p $(dir $@)
	$(CXX) $(MODULE_CPPFLAGS) $(CPPFLAGS) -b $@ $<

%.o: %.ixx %.bmi.$(BMI_UUID)
	mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) -o $@ $<

module_config.json: $(SOURCES) Makefile
	$(SRCROOT)bin/c++-modules-config -r $(CPPFLAGS) \
          --bmi-uuid=$(BMI_UUID) \
	  $(patsubst %,--parse-imports %,$(SOURCES)) -o $@

deps.mk: module_config.json
	$(SRCROOT)bin/c++-modules-makemake --bmi-uuid=$(BMI_UUID) -o $@ $<

example-executable: $(OBJECTS)
	$(CXX) $(patsubst %,-I%,$(MODULE_PATH)) -o $@ $^

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
