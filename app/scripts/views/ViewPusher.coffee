'use strict';

# This is where I'll put page animations. 
# Right now, it just plops the new content in.

pizzabuttonapp.Views.ViewPusher = 
  render: (el) ->
    $('#container').html('').append(el)
