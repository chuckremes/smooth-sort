#
# License: Public Domain
#

# Original Author: Keith Schwarz (htiek@cs.stanford.edu)
#
# Translated to Ruby by Chuck Remes (chuckremes on github)
#
# An implementation of Dijkstra's Smoothsort algorithm, a modification of
# heapsort that runs in O(n lg n) in the worst case, but O(n) if the data
# are already sorted.  For more information about how this algorithm works
# and some of the details necessary for its proper operation, please see
#
#              http://www.keithschwarz.com/smoothsort/
#
# This implementation is designed to work on a 64-bit machine. Also,
# I've used the tricky O(1) optimization to use a constant amount of space
# given the fact that the machine is 32 bits.
#
 
 
# Convenience class for storing the bitvector (+trees+) and the
# +smallest_tree_size+. Also provides a few convenience methods for
# determining if a we have a tree of order N in the bitvector.
#
class HeapShape
  attr_accessor :trees, :smallest_tree_size
  
  def initialize
    @trees = 0
    @smallest_tree_size = nil
  end
  
  def has_trees?
    @trees > 0
  end
  
  def has_tree_of_size?(size)
    size += 1
    (@trees & size) == size
  end
  
  def inspect
    "shape (#{@trees.to_s(2)}, #{@smallest_tree_size})"
  end
end


# Implementation of the SmoothSort algorithm using Leonardo heaps (a forest of
# Leonardo trees).
#
# Space complexity: O(1)
# Time Complexity:
#     Worse Case: O(n lg n)
#     Best Case : O(n)  # data is already sorted or mostly sorted
#
class SmoothSort
  
  def initialize
    # All of the Leonardo Numbers that fit in 64 bits
    @leonardo_numbers = [
            1, 1, 3, 5, 9, 15, 25, 41, 67, 109, 177, 287, 465, 753, 1219, 1973, 3193, 5167, 8361, 13529, 21891,
            35421, 57313, 92735, 150049, 242785, 392835, 635621, 1028457, 1664079, 2692537, 4356617, 7049155, 
            1405773, 18454929, 29860703, 48315633, 78176337, 126491971, 204668309, 331160281, 535828591, 
            866988873, 5942430145,  9615053951,  15557484097,  25172538049,  40730022147,  65902560197, 106632582345, 
            172535142543,  279167724889,  451702867433,  730870592323,  1182573459757,  1913444052081, 
            3096017511839,  5009461563921,  8105479075761,  13114940639683,  21220419715445,  34335360355129, 
            55555780070575,  89891140425705,  145446920496281,  235338060921987,  380784981418269, 
            616123042340257,  996908023758527,  1613031066098785,  2609939089857313,  4222970155956099, 
            6832909245813413,  11055879401769513,  17888788647582927,  28944668049352441,  46833456696935369, 
            75778124746287811,  122611581443223181,  198389706189510993,  321001287632734175,  519390993822245169, 
            840392281454979345,  1359783275277224515,  2200175556732203861,  3559958832009428377, 
            5760134388741632239,  9320093220751060617,  15080227609492692857
          ]
  end
        
  def sort(array)
    return array unless array.size > 1
    
    @array = array
    shape = HeapShape.new
    shape.smallest_tree_size = 0
    
    size = array.size
    
    i = 0
    while i < size
      leonardo_heap_add(0, i, size, shape)
      i += 1
    end

    # move the index back to the last entry in preparation for the reverse iteration
    i -= 1
    
    while i > 0
      leonard_heap_remove(0, i, shape)
      i -= 1
    end
    
    @array
  end
  
  def second_child(root)
    root - 1
  end
  
  def first_child(root, size)
    second_child(root) - @leonardo_numbers.at(size - 2)
  end
  
  # Returns the index to the largest direct child node of the +root+.
  #
  def larger_child(root, size)
    first = first_child(root, size)
    second = second_child(root)
    
    smaller_root_than_child?(first, second) ? second : first
  end
  
  # Bubble down the +root+ to its appropriate place to restore the heap
  # property.
  #
  def rebalance_single_heap(root, size)
    while size > 1
      first = first_child(root, size)
      second = second_child(root)
      
      if smaller_root_than_child?(first, second)
        # second child is bigger
        large_child = second
        child_size = size - 2 # and has order k - 2
      else
        large_child = first
        child_size = size - 1 # and has order k - 1
      end
      
      # if the root is bigger than this child, we are done rebalancing
      return unless smaller_root_than_child?(root, large_child)
      
      # otherwise, swap the values down and update the order
      @array[root], @array[large_child] = @array.at(large_child), @array.at(root)
      
      root = large_child
      size = child_size
    end
  end
  
  def leonardo_heap_rectify(start, finish, trees, smallest_tree_size)
    index = finish - 1
    
    while true
      left_heap_size = smallest_tree_size
      
      break if (index - start) == (@leonardo_numbers.at(left_heap_size) - 1)
      
      node_index = index
      
      if smallest_tree_size > 1
        large_child = larger_child(index, smallest_tree_size)
        
        # pick up a new index if the current one has a larger child
        node_index = large_child if smaller_root_than_child?(node_index, large_child)
      end
      
      left_heap_index = index - @leonardo_numbers.at(left_heap_size)
      
      # ...
      break unless smaller_root_than_child?(node_index, left_heap_index)
      
      # otherwise, swap elements and adjust our location
      @array[index], @array[left_heap_index] = @array.at(left_heap_index), @array.at(index)
      index = left_heap_index
      
      # scan down until we find the heap before this one. We do this by continuously
      # shifting down the tree bitvector and bumping up the size of the smallest
      # tree until we hit a new tree
      begin
        trees >>= 1
        smallest_tree_size += 1
      end until ((trees & 1) == 1)
    end
    
    # finally, rebalance the current heap
    rebalance_single_heap(index, left_heap_size)
  end
  
  def smaller_root_than_child?(index1, index2)
    @array.at(index1) < @array.at(index2)
  end
  
  def bigger_root_than_child?(index1, index2)
    !smaller_root_than_child?(index1, index2)
  end
  
  def leonardo_heap_add(start, finish, heap_finish, shape)
    trees = shape.trees
    
    if !((trees & 1) == 1)
      shape.trees |= 1
      shape.smallest_tree_size = 1
    
    elsif ((trees & 2) == 2) && ((trees & 1) == 1)
      shape.trees >>= 2
      shape.trees |= 1
      shape.smallest_tree_size += 2
      
    elsif shape.smallest_tree_size == 1
      shape.trees <<= 1
      shape.trees |= 1
      shape.smallest_tree_size = 0
      
    else
      shape.trees <<= shape.smallest_tree_size - 1
      shape.trees |= 1
      shape.smallest_tree_size = 1
    end
    
    # We have just finished setting up a new tree. We need to see if this
    # tree is at its final size. If so, we'll do a full rectify on it. 
    # Otherwise, we only need to ensure the heap property.
    last = false
    smallest_tree_size = shape.smallest_tree_size
    
    if smallest_tree_size == 0
      if finish + 1 == heap_finish
        last = true
      end
      
    elsif smallest_tree_size == 1
      if (finish + 1 == heap_finish) || (finish + 2 == heap_finish && !((shape.trees & 1) == 1))
        last = true
      end
      
    else
      if (heap_finish - (finish + 1)) < (@leonardo_numbers.at(smallest_tree_size - 1) + 1)
        last = true
      end
    end
    
    # if not the last heap, rebalance the current heap
    unless last
      rebalance_single_heap(finish, smallest_tree_size)
    else
      leonardo_heap_rectify(start, finish + 1, shape.trees, smallest_tree_size)
    end
  end
  
  def leonard_heap_remove(start, finish, shape)
    if shape.smallest_tree_size <= 1
      begin
        shape.trees >>= 1
        shape.smallest_tree_size += 1
      end while shape.trees > 0 && !((shape.trees & 1) == 1)
      
      return
    end
    
    heap_leonardo_order = shape.smallest_tree_size
    shape.trees &= ~1 # unset the first bit
    shape.trees <<= 2
    shape.trees |= 3 # sets bits 1 and 0
    shape.smallest_tree_size -= 2
    
    left_heap = first_child(finish, heap_leonardo_order)
    right_heap = second_child(finish)
    
    leonardo_heap_rectify(start, left_heap + 1, shape.trees >> 1, shape.smallest_tree_size + 1)
    leonardo_heap_rectify(start, right_heap + 1, shape.trees, shape.smallest_tree_size)
  end
end # SmoothSort


# Run this from the Rubinius parent directory:
#  % bin/benchmark smooth_sort.rb
#

if $0 == __FILE__

  ips_available = false
  # let's do a quick perf test
  require 'benchmark'
  begin
    require 'benchmark/ips'
    ips_available = true
  rescue LoadError
  end
  

  #               0   1   2   3   4   5   6   7   8   9  10  11  12  13
  small_array = [27, 18, 28, 31, 41, 45, 26, 53, 58, 59, 90, 93, 97, 54]

  medium_array = (0..200).map { rand(2**31) + 1 }

  large_array = (0..10_000).map { rand(2**31) + 1 }
  
  giant_array = (0..100_000).map { rand(2**31) + 1 }

  # Sanity check...
  s = SmoothSort.new
  lm = s.sort(small_array.dup)
  lq = small_array.dup.sort
  raise Exception, "Sanity Check! Sorted arrays don't match: #{lm.inspect}" unless lm == lq

  
  if ips_available
    
    Benchmark.ips do |x|

      x.report("built-in sort small array") do |times|
        i = 0
        while i < times
          small_array.dup.sort
          i += 1
        end
      end

      x.report("built-in sort medium array") do |times|
        i = 0
        while i < times
          medium_array.dup.sort
          i += 1
        end
      end

      x.report("built-in sort large array") do |times|
        i = 0
        while i < times
          large_array.dup.sort
          i += 1
        end
      end

      x.report("built-in sort giant array") do |times|
        i = 0
        while i < times
          giant_array.dup.sort
          i += 1
        end
      end

      x.report("smoothsort small array") do |times|
        smooth = SmoothSort.new
        i = 0
        while i < times
          smooth.sort(small_array.dup)
          i += 1
        end
      end

      x.report("smoothsort medium array") do |times|
        smooth = SmoothSort.new
        i = 0
        while i < times
          smooth.sort(medium_array.dup)
          i += 1
        end
      end

      x.report("smoothsort large array") do |times|
        smooth = SmoothSort.new
        i = 0
        while i < times
          smooth.sort(large_array.dup)
          i += 1
        end
      end

      x.report("smoothsort giant array") do |times|
        smooth = SmoothSort.new
        i = 0
        while i < times
          smooth.sort(giant_array.dup)
          i += 1
        end
      end
    end
    
  else
    # the benchmark_suite code isn't available, so use the standard Ruby benchmark

  ITERATIONS = 100
  
  Benchmark.bmbm(30) do |x|

    x.report("built-in sort small array") do |times|
      ITERATIONS.times { small_array.dup.sort }
    end

    x.report("built-in sort medium array") do |times|
      ITERATIONS.times { medium_array.dup.sort }
    end

    x.report("built-in sort large array") do |times|
      ITERATIONS.times { large_array.dup.sort }
    end

    x.report("built-in sort giant array") do |times|
      ITERATIONS.times { giant_array.dup.sort }
    end

    x.report("smoothsort small array") do |times|
      smooth = SmoothSort.new
      ITERATIONS.times { smooth.sort(small_array.dup) }
    end

    x.report("smoothsort medium array") do |times|
      smooth = SmoothSort.new
      ITERATIONS.times { smooth.sort(medium_array.dup) }
    end

    x.report("smoothsort large array") do |times|
      smooth = SmoothSort.new
      ITERATIONS.times { smooth.sort(large_array.dup) }
    end

    x.report("smoothsort giant array") do |times|
      smooth = SmoothSort.new
      ITERATIONS.times { smooth.sort(giant_array.dup) }
    end
  end
  
end # ips_available

end
