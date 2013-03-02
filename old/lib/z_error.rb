class ZError < Exception
end

def error(*msg)
  raise ZError, msg
end