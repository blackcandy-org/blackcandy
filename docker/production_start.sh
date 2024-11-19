#!/bin/sh

rails db:prepare
./bin/thrust ./bin/rails server