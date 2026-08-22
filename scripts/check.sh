#!/usr/bin/env bash
(cd apps/mobile && flutter analyze && flutter test)
(cd services/api && dotnet build && dotnet test)
