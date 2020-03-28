# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2020-03-28
### Changed
- LICENSE now includes MIT preambula.
- Makefile: Support for `test`, `build`, `run`, `login` and `push` targets.
- Dockerfile: Switch to use `ruby:2.3.8-slim` image instead.
- Compose: Reference `krates/etcd` image instead.