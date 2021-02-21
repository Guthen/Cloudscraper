local id = 0
Timers = {}

--  @function timer
--      | description: Run a callback after delay
--      | params:
--          number time: Time (in seconds)
--          function callback: Callback to run
function timer( time, callback, custom_id )
    Timers[custom_id or id] = { max_time = time, time = 0, callback = callback }
    id = id + 1
end
