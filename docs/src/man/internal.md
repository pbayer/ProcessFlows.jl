# Internal Functions

Those functions are used internally and normally not called by the user.

## Simulation

```@docs
Event
register
removetask
interrupttask
clock
terminateclients
schedule_event
```

## Queueing

```@docs
PFQueue
isfull
isempty
capacity
length
front
back
enqueue!
dequeue!
```

## Working

```@docs
work
workunit
machine
worker
transport
```

## Scheduling
```@docs
scheduler
source
sink
call_scheduler
sched
```
