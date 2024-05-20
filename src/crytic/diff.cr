module Crytic
  class Diff(A, B)
    struct Chunk(T)
      def initialize(
        @diff : T,
        @type : Type,
        @range_a : Range(Int32, Int32),
        @range_b : Range(Int32, Int32)
      )
      end

      property diff, type, range_a, range_b

      def append?
        type == Type::APPEND
      end

      def delete?
        type == Type::DELETE
      end

      def no_change?
        type == Type::NO_CHANGE
      end

      def data
        case type
        in Type::APPEND
          diff.b[range_b]
        in Type::DELETE, Type::NO_CHANGE
          diff.a[range_a]
        end
      end

      def ==(other : Chunk)
        type == other.type &&
          range_a == other.range_a &&
          range_b == other.range_b
      end

      def prefix
        append? ? '+'.colorize(:green).to_s : '-'.colorize(:red).to_s
      end

      def colored_data
        data.map(&.colorize(append? ? :green : :red).to_s)
      end

      def last_chunk?(a_size, b_size)
        delete? ? range_a.end == a_size : range_b.end == b_size
      end
    end

    enum Type
      NO_CHANGE
      APPEND
      DELETE

      def reverse
        case self
        when APPEND
          DELETE
        when DELETE
          APPEND
        else
          self
        end
      end
    end

    @m : Int32
    @n : Int32
    @reverse : Bool
    @edit_distance : Int32?

    def initialize(@a : A, @b : B)
      @m = a.size
      @n = b.size
      if @reverse = @n < @m
        @a, @b = @b, @a
        @m, @n = @n, @m
      end

      @table = {} of {Int32, Int32} => Int32
    end

    def a
      @reverse ? @b : @a
    end

    def b
      @reverse ? @a : @b
    end

    def edit_distance
      if ed = @edit_distance
        return ed
      end

      offset = @m + 1
      delta = @n - @m
      fp = Array.new @m + @n + 3, -1

      p = 0
      loop do
        (-p..delta - 1).each { |k| fp[k + offset] = snake k, [fp[k - 1 + offset] + 1, fp[k + 1 + offset]].max }
        (delta + 1..delta + p).reverse_each { |k| fp[k + offset] = snake k, [fp[k - 1 + offset] + 1, fp[k + 1 + offset]].max }
        fp[delta + offset] = snake delta, [fp[delta - 1 + offset] + 1, fp[delta + 1 + offset]].max

        if fp[delta + offset] == @n
          return @edit_distance = delta + p * 2
        end
        p += 1
      end
    end

    private def snake(k, y)
      x = y - k

      i = 0
      while x < @m && y < @n && @a[x] == @b[y]
        x += 1
        y += 1
        i += 1
      end
      @table[{x, y}] = i
      y
    end

    def run
      edit_distance

      x, y = @m, @n
      chunk_list = [] of Chunk(self)
      loop do
        i = @table[{x, y}]
        if i != 0
          chunk_list.push chunk Type::NO_CHANGE, x - i...x, y - i...y
        end
        x, y = x - i, y - i

        i = 0
        flag = false
        while @table[{x, y - 1}]?
          y -= 1
          i += 1
        end
        if i != 0
          chunk_list.push chunk Type::APPEND, x...x, y...y + i
          flag = true
        end

        i = 0
        while @table[{x - 1, y}]?
          x -= 1
          i += 1
        end
        if i != 0
          chunk_list.push chunk Type::DELETE, x...x + i, y...y
          if flag && @reverse
            chunk_list[-1], chunk_list[-2] = chunk_list[-2], chunk_list[-1]
          end
        end

        if x == 0 && y == 0
          return chunk_list.reverse!
        end
      end
    end

    private def chunk(type, range_a, range_b)
      if @reverse
        Chunk.new self, type.reverse, range_b, range_a
      else
        Chunk.new self, type, range_a, range_b
      end
    end
  end

  class Diff(A, B)
    def self.unified_diff(a, b, n = 3, newline = "\n")
      diff = Diff.new(a, b)
      chunks = diff.run

      result = [] of String
      group = [] of String
      start_a = start_b = 0

      chunks.each_with_index do |cur, i|
        next if cur.no_change?
        prv = i > 0 ? chunks[i - 1] : Chunk.new(diff, Type::NO_CHANGE, 0...0, 0...0)
        nxt = chunks.fetch(i + 1) { Chunk.new(diff, Type::NO_CHANGE, a.size...a.size, b.size...b.size) }

        if group.empty? && prv.no_change?
          start_a = {prv.range_a.end - n, 0}.max
          start_b = {prv.range_b.end - n, 0}.max
          add_with_prefix ' ', prv.data.last(n), group
        end

        add_with_prefix cur.prefix, cur.colored_data, group

        if !group.last.ends_with?(newline) && cur.last_chunk?(a.size, b.size)
          group[-1] += newline
          group.push "\\ No newline at end of file#{newline}"
        end

        if nxt.no_change?
          if nxt.data.size > n*2 || i >= chunks.size - 2
            add_with_prefix ' ', nxt.data.first(n), group

            size_a = {nxt.range_a.begin + n, a.size}.min - start_a
            size_b = {nxt.range_b.begin + n, b.size}.min - start_b
            start_a += 1 unless size_a == 0
            start_b += 1 unless size_b == 0

            result.push(build_group_header(start_a, size_a, start_b, size_b))
            result += group
            group.clear
          else
            add_with_prefix ' ', nxt.data, group
          end
        end
      end

      result
    end

    private def self.build_group_header(start_a, size_a, start_b, size_b)
      String.build do |io|
        io << "@@ -" << start_a
        io << "," << size_a unless size_a == 1
        io << " +" << start_b
        io << "," << size_b unless size_b == 1
        io << " @@\n"
      end
    end

    private def self.add_with_prefix(prefix, lines, to array)
      lines.each do |line|
        array.push prefix + line + "\n"
      end
    end

    def self.unified_diff(a : String, b : String, n = 3, newline = "\n")
      unified_diff(a.lines, b.lines, n, newline).join
    end
  end
end
