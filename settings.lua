data:extend({
  {
    type = "int-setting",
    name = "absolute-decay-spoil-ticks",
    setting_type = "startup",
    default_value = 108000, -- 30 minutes (30 * 60 * 60)
    minimum_value = 60, -- 1 second
    maximum_value = 2160000 -- 10 hours
  }
})
