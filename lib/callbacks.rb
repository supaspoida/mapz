module Callbacks
  def [](obj, *callbacks, &blk)
    callback = callbacks.shift
    result = yield obj
    if callback
      callback[result, *callbacks]
    else
      result
    end
  end
end
