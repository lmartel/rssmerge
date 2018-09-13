require 'algorithms'

class ArrayWithCursor
  def initialize(contents)
    @cursor = 0
    @contents = contents
  end

  def get
    @contents[@cursor]
  end

  def next!
    @cursor += 1
  end

  def done?
    @cursor >= @contents.length
  end
end

# k-way sorted array merge:
# Maintain a cursor in each array, add the first element of each to a heap.
# Pop from the heap, add the next element from its source array, repeat.
# This runs in n log k time since the heap never exceeds k elements.
# Alternatively, we could just concatenate everything and sort the result
# for n log n runtime.
def merge_sorted_arrays(arrays, &comparator)
  merged_items = []
  heap = Containers::Heap.new([], &comparator)
  cursor_arrays = arrays.map { |a| ArrayWithCursor.new(a) }
  cursor_arrays.each { |ca| heap.push(ca.get, ca) }
  until heap.empty?
    cursor_array = heap.pop
    merged_items.push(cursor_array.get)
    cursor_array.next!
    heap.push(cursor_array.get, cursor_array) unless cursor_array.done?
  end
  merged_items
end
