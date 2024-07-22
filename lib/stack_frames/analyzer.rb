require 'ruby-graphviz'


module StackFrames
  class Drawer
    def initialize
      @graph = GraphViz.new( :G, :type => :digraph )
      @node_mapping = {}
      @linked = {}
    end

    def create_node(id, name)
      node = @graph.add_nodes(id, label: name)
      @node_mapping[id] = node
    end

    def add_link(from_node, to_node)
      @linked[from_node] ||= []
      @linked[from_node] << to_node
      @linked[from_node].uniq!
      @graph.add_edges(from_node, to_node)
    end

    def linked?(from_node, to_node)
      @linked[from_node] && @linked[from_node].include?(to_node)
    end

    def find_or_create_node(id, name)
      @node_mapping[id] ||= create_node(id, name)
    end

    def draw(name)
      @graph.output( :png => name )
    end
  end

  class Analyzer
    def initialize(data)
      @data = data
    end

    def draw(name)
      data = clean_data(@data.uniq)
      draw_graph(data, name)
    end

    private
    def draw_graph(data, name)
      @drawer = Drawer.new

      data.each do |frames|
        i = frames.count - 1
        current_frame = frames[i]
        current_node = @drawer.find_or_create_node(node_id(current_frame), node_name(current_frame))

        while (pre_frame = frames[i-1]) && i > 0
          pre_node = @drawer.find_or_create_node(node_id(pre_frame), node_name(pre_frame))
          @drawer.add_link(current_node, pre_node) unless @drawer.linked?(current_node, pre_node)

          current_node = pre_node
          i -= 1
        end
      end

      @drawer.draw("#{name}-#{rand(100)}.png")
    end

    def node_name(frame)
      frame[1]
    end

    def node_id(frame)
      "#{frame[1]}##{frame[-1]}"
    end

    def clean_data(data)
      remove_blocks(remove_frames_before_trace(data))
    end

    def remove_frames_before_trace(input)
      new_input = []
      input.each do |row|
        i = 0

        new_row = []
        max_generation = row[0][-1]
        while i < row.count
          if row[i][-1] <= max_generation
            new_row << row[i]
          else
            break
          end

          i += 1
        end

        new_input << new_row
      end

      new_input
    end

    # data = remove_blocks(data)
    def remove_blocks(data)
      new_data = []
      data.each do |row|
        new_row = []
        row.each do |item|
          unless item[1].include?("block") && item[1].include?(" in ")
            new_row << item
          end
        end
        new_data << new_row
      end

      new_data
    end
  end
end
