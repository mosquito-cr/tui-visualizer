# TUI Visualizer for Mosquito

This is an minimal implementation of a queue visualizer for [mosquito](https://github.com/mosquito-cr/mosquito). It is a Text based User Interface (TUI).

## Purpose

This repository is primarily an experiment on basic queue visualization. It primarily serves as a testing ground for methods which need to be added to mosquito core to facilitate this kind of work. In the mean time, it can also be used to get some idea that things are happening in a deployed worker, and the rate at which they are happening.

## Using the visualizer

Using the visualizer to query a running mosquito backend is straightforward. This will increase the read-load on the backend slightly.

- Clone the visualizer and install shards:

```console
$ git clone git@github.com:mosquito-cr/tui_visualizer.git
$ cd tui_visualizer
$ shards install
```

- Provide REDIS_URL connection string as `REDIS_ENV` environment variable

```console
$ export REDIS_URL 'redis://localhost:6379/2'
```

- Boot the interface
```console
$ crystal run ./interface.cr
```

## Developing the visualizer

A utility script is provided to enqueue and execute some jobs, which is convenient for working on the visualizer. Use `crystal run ambient_runner.cr` to run it.

