require 'ruby-graphviz'
require 'byebug'

module StackFrames
  class Drawer
    def initialize
      @graph = GraphViz.new( :G, :type => :digraph )
      @node_mapping = {}
    end
  
    def create_node(id, name)
      node = @graph.add_nodes(id, label: name)
      @node_mapping[id] = node
    end
  
    def add_link(from_node, to_node)
      @graph.add_edges(from_node, to_node)
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
      data = clean_data(@data)
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
          @drawer.add_link(current_node, pre_node)
    
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

# data = [[[0,"sleep",3],[1,"Object#y",2],[2,"Object#x",1],[3,"block (2 levels) in <main>",63],[4,"Integer#times",7],[5,"block in <main>",2]],
#         [[0,"sleep",11],[1,"Object#y",10],[2,"Object#x",9],[3,"Object#foo",7],[4,"block (3 levels) in <main>",6],[5,"Integer#times",4],[6,"block (2 levels) in <main>",63],[7,"Integer#times",7],[8,"block in <main>",2]],
#         [[0,"sleep",17],[1,"Object#y",16],[2,"Object#x",15],[3,"Object#foo",13],[4,"block (3 levels) in <main>",12],[5,"Integer#times",4],[6,"block (2 levels) in <main>",63],[7,"Integer#times",7],[8,"block in <main>",2]],
#         [[0,"sleep",22],[1,"Object#bar",21],[2,"Object#foo",19],[3,"block (3 levels) in <main>",18],[4,"Integer#times",4],[5,"block (2 levels) in <main>",63],[6,"Integer#times",7],[7,"block in <main>",2]],
#         [[0,"sleep",28],[1,"Object#y",27],[2,"Object#x",26],[3,"Object#foo",24],[4,"block (3 levels) in <main>",23],[5,"Integer#times",4],[6,"block (2 levels) in <main>",63],[7,"Integer#times",7],[8,"block in <main>",2]],
#         [[0,"sleep",34],[1,"Object#y",33],[2,"Object#x",32],[3,"Object#foo",30],[4,"block (3 levels) in <main>",29],[5,"Integer#times",4],[6,"block (2 levels) in <main>",63],[7,"Integer#times",7],[8,"block in <main>",2]],
#         [[0,"sleep",39],[1,"Object#bar",38],[2,"Object#foo",36],[3,"block (3 levels) in <main>",35],[4,"Integer#times",4],[5,"block (2 levels) in <main>",63],[6,"Integer#times",7],[7,"block in <main>",2]],
#         [[0,"sleep",45],[1,"Object#y",44],[2,"Object#x",43],[3,"Object#foo",41],[4,"block (3 levels) in <main>",40],[5,"Integer#times",4],[6,"block (2 levels) in <main>",63],[7,"Integer#times",7],[8,"block in <main>",2]],
#         [[0,"sleep",51],[1,"Object#y",50],[2,"Object#x",49],[3,"Object#foo",47],[4,"block (3 levels) in <main>",46],[5,"Integer#times",4],[6,"block (2 levels) in <main>",63],[7,"Integer#times",7],[8,"block in <main>",2]],
#         [[0,"sleep",57],[1,"Object#y",56],[2,"Object#x",55],[3,"Object#foo",53],[4,"block (3 levels) in <main>",52],[5,"Integer#times",4],[6,"block (2 levels) in <main>",63],[7,"Integer#times",7],[8,"block in <main>",2]],
#         [[0,"sleep",62],[1,"Object#bar",61],[2,"Object#foo",59],[3,"block (3 levels) in <main>",58],[4,"Integer#times",4],[5,"block (2 levels) in <main>",63],[6,"Integer#times",7],[7,"block in <main>",2]]]
# analyzer = StackFrames::Analyzer.new(data)
# analyzer.draw('demmo')