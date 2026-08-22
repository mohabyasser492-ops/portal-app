#!/usr/bin/env bash
cd apps/mobile && flutter create --platforms=android,ios --org com.company.portalapp . && flutter pub get
cd ../../services/api && ./bootstrap.sh
