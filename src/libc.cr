@[Link("c")]
lib LibC
  fun fdopen(fd : LibC::Int, mode : UInt8*) : Void*
  fun dup(fd : LibC::Int) : LibC::Int
end
