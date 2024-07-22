require 'stack_frames'

@buffer = StackFrames::Buffer.new(50)

Thread.new do
  def bar
    sleep 0.002
  end

  def x
    y
  end

  def y
    sleep 0.002
  end

  def foo
    r = rand

    if r >= 0.5
      bar
    else
      x
    end
  end

  @total = 0
  100.times do |i|
    @buffer.set_trace_id_and_generation(i)
    x
    10.times do
      foo
    end
  end
end

@stop = false
@traces = {}

Thread.new do
  puts "frame, trace_id, generation, method_name"

  while !@stop
    frames_count = @buffer.caputre_frames(Thread.list[1])
    frame = []
    trace_id = @buffer[0].f_trace_id
    @traces[trace_id] ||= []

    frames_count.times do |i|
      buffer = @buffer[i]
      frame << [i, buffer.f_method_name, buffer.f_generation]
    end

    @traces[trace_id] << frame

    sleep 0.001
  end
end

sleep 2
@stop = true

data = @traces[20].uniq
analyzer = StackFrames::Analyzer.new(data)
analyzer.draw('demo')

# data = [[[0, "sleep", 3], [1, "Object#y", 2], [2, "Object#x", 1], [3, "block (2 levels) in <top (required)>", 63], [4, "Integer#times", 7], [5, "block in <top (required)>", 2]],
# [[0, "sleep", 3], [1, "Object#y", 2], [2, "Object#x", 1], [3, "block (2 levels) in <top (required)>", 63], [4, "Integer#times", 7], [5, "block in <top (required)>", 2]],
# [[0, "sleep", 10], [1, "Object#bar", 9], [2, "Object#foo", 7], [3, "block (3 levels) in <top (required)>", 6], [4, "Integer#times", 4], [5, "block (2 levels) in <top (required)>", 63], [6, "Integer#times", 7], [7, "block in <top (required)>", 2]],
# [[0, "sleep", 15], [1, "Object#bar", 14], [2, "Object#foo", 12], [3, "block (3 levels) in <top (required)>", 11], [4, "Integer#times", 4], [5, "block (2 levels) in <top (required)>", 63], [6, "Integer#times", 7], [7, "block in <top (required)>", 2]],
# [[0, "sleep", 20], [1, "Object#bar", 19], [2, "Object#foo", 17], [3, "block (3 levels) in <top (required)>", 16], [4, "Integer#times", 4], [5, "block (2 levels) in <top (required)>", 63], [6, "Integer#times", 7], [7, "block in <top (required)>", 2]],
# [[0, "sleep", 20], [1, "Object#bar", 19], [2, "Object#foo", 17], [3, "block (3 levels) in <top (required)>", 16], [4, "Integer#times", 4], [5, "block (2 levels) in <top (required)>", 63], [6, "Integer#times", 7], [7, "block in <top (required)>", 2]],
# [[0, "sleep", 26], [1, "Object#y", 25], [2, "Object#x", 24], [3, "Object#foo", 22], [4, "block (3 levels) in <top (required)>", 21], [5, "Integer#times", 4], [6, "block (2 levels) in <top (required)>", 63], [7, "Integer#times", 7], [8, "block in <top (required)>", 2]],
# [[0, "sleep", 26], [1, "Object#y", 25], [2, "Object#x", 24], [3, "Object#foo", 22], [4, "block (3 levels) in <top (required)>", 21], [5, "Integer#times", 4], [6, "block (2 levels) in <top (required)>", 63], [7, "Integer#times", 7], [8, "block in <top (required)>", 2]],
# [[0, "sleep", 31], [1, "Object#bar", 30], [2, "Object#foo", 28], [3, "block (3 levels) in <top (required)>", 27], [4, "Integer#times", 4], [5, "block (2 levels) in <top (required)>", 63], [6, "Integer#times", 7], [7, "block in <top (required)>", 2]],
# [[0, "sleep", 37], [1, "Object#y", 36], [2, "Object#x", 35], [3, "Object#foo", 33], [4, "block (3 levels) in <top (required)>", 32], [5, "Integer#times", 4], [6, "block (2 levels) in <top (required)>", 63], [7, "Integer#times", 7], [8, "block in <top (required)>", 2]],
# [[0, "sleep", 42], [1, "Object#bar", 41], [2, "Object#foo", 39], [3, "block (3 levels) in <top (required)>", 38], [4, "Integer#times", 4], [5, "block (2 levels) in <top (required)>", 63], [6, "Integer#times", 7], [7, "block in <top (required)>", 2]],
# [[0, "sleep", 42], [1, "Object#bar", 41], [2, "Object#foo", 39], [3, "block (3 levels) in <top (required)>", 38], [4, "Integer#times", 4], [5, "block (2 levels) in <top (required)>", 63], [6, "Integer#times", 7], [7, "block in <top (required)>", 2]],
# [[0, "sleep", 48], [1, "Object#y", 47], [2, "Object#x", 46], [3, "Object#foo", 44], [4, "block (3 levels) in <top (required)>", 43], [5, "Integer#times", 4], [6, "block (2 levels) in <top (required)>", 63], [7, "Integer#times", 7], [8, "block in <top (required)>", 2]],
# [[0, "sleep", 48], [1, "Object#y", 47], [2, "Object#x", 46], [3, "Object#foo", 44], [4, "block (3 levels) in <top (required)>", 43], [5, "Integer#times", 4], [6, "block (2 levels) in <top (required)>", 63], [7, "Integer#times", 7], [8, "block in <top (required)>", 2]],
# [[0, "sleep", 53], [1, "Object#bar", 52], [2, "Object#foo", 50], [3, "block (3 levels) in <top (required)>", 49], [4, "Integer#times", 4], [5, "block (2 levels) in <top (required)>", 63], [6, "Integer#times", 7], [7, "block in <top (required)>", 2]],
# [[0, "sleep", 59], [1, "Object#y", 58], [2, "Object#x", 57], [3, "Object#foo", 55], [4, "block (3 levels) in <top (required)>", 54], [5, "Integer#times", 4], [6, "block (2 levels) in <top (required)>", 63], [7, "Integer#times", 7], [8, "block in <top (required)>", 2]],
# [[0, "sleep", 59], [1, "Object#y", 58], [2, "Object#x", 57], [3, "Object#foo", 55], [4, "block (3 levels) in <top (required)>", 54], [5, "Integer#times", 4], [6, "block (2 levels) in <top (required)>", 63], [7, "Integer#times", 7], [8, "block in <top (required)>", 2]]]
# analyzer = StackFrames::Analyzer.new(data)
# analyzer.draw('demmox')
