#!/bin/sh
(
  sleep 0.5
  eww update launcher_rev=false
  eww update dummy_rev=true
) &
