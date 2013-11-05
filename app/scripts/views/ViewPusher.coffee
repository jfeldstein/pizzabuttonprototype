'use strict';

# This is where I'll put page animations. 
# Right now, it just plops the new content in.

pizzabuttonapp.Views.ViewPusher = 
  render: (el) ->
    console.log "Got the new el", el
    $('#container').html el.outerHTML