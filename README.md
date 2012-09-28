smooth-sort
===========

Ruby implementation of Dijkstra's SmoothSort algorithm.

What is it?
-----------

Translated to Ruby by Chuck Remes (chuckremes on github)

An implementation of Dijkstra's Smoothsort algorithm, a modification of
heapsort that runs in O(n lg n) in the worst case, but O(n) if the data
are already sorted.  For more information about how this algorithm works
and some of the details necessary for its proper operation, please see

             http://www.keithschwarz.com/smoothsort/

This implementation is designed to work on a 64-bit machine. Also,
I've used the tricky O(1) optimization to use a constant amount of space
given the fact that the machine is 32 bits.


Benchmarks
----------

Since this is a pure Ruby implementation, it pretty much gets its head
handed to it by the built-in C implementation in MRI and the built-in Java 
implementation in JRuby. So, to show its superiority I recommend looking
at it on Rubinius where even the built-in sort algorithm (mergesort) is
also written in Ruby. This puts the SmoothSort implementation on an even
playing field.

SmoothSort has a time complexity of O(n lg n) on random data and O( n ) 
for sorted data. It's space complexity is O( 1 ).

As with most "big O" measurements, there is a constant "C" out there in
front of the time complexity that most people ignore, but for SmoothSort 
that constant time hampers its performance for small arrays. Since most 
people use sort on small data sets in Ruby, SmoothSort loses to the
MergeSort implementation in Rubinius.

On my machine, SmoothSort starts to beat MergeSort when the array size
grows beyond about 50 elements.

Charles-Remess-MacBook-Pro:smooth-sort cremes$ rbx sort.rb 
Rehearsal -----------------------------------------------------------------
built-in sort small array       0.002481   0.000016   0.002497 (  0.002328)
built-in sort medium array      0.078341   0.000806   0.079147 (  0.079156)
built-in sort large array       5.213073   0.017670   5.230743 (  5.230974)
built-in sort giant array      68.357057   0.158334  68.515391 ( 68.577896)
smoothsort small array          0.007343   0.000019   0.007362 (  0.007370)
smoothsort medium array         0.234389   0.000631   0.235020 (  0.235440)
smoothsort large array          4.863016   0.009784   4.872800 (  4.877910)
smoothsort giant array         60.187347   0.081864  60.269211 ( 60.302409)
------------------------------------------------------ total: 139.212171sec

                                    user     system      total        real
built-in sort small array       0.001540   0.000008   0.001548 (  0.001540)
built-in sort medium array      0.060729   0.000106   0.060835 (  0.060961)
built-in sort large array       5.431454   0.008344   5.439798 (  5.442743)
built-in sort giant array      67.692381   0.132409  67.824790 ( 67.862400)
smoothsort small array          0.002135   0.000010   0.002145 (  0.002147)
smoothsort medium array         0.055996   0.000080   0.056076 (  0.056160)
smoothsort large array          4.783645   0.008621   4.792266 (  4.795984)
smoothsort giant array         59.128042   0.087313  59.215355 ( 59.241190)


Running the same benchmark on MRI and JRuby is just an embarrassment for
SmoothSort. The native sorting implementations clearly show how far Ruby 
runtimes have to go before they can execute Ruby code as fast as a lower
level language like C or Java. But I am hopeful!

What's Next?
------------

This was a fun little hobby project that I did about 10 months ago. I forgot
to publish it until now.

At the time I did some very basic optimization work. Some of the code diverges
from the usual Ruby idioms as a result. I'm sure more work could be done to 
speed it up even more.

Pull requests will be very welcome! :)

License
-------
Public Domain. Use it however you like. 