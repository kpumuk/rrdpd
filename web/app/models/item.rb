require 'set'

class SetWithefault < SortedSet
  def default
    self.each do |v|
      return v if v.is_default
    end
    nil
  end

  def named?(name)
    self.each do |v|
      return v if v.name == name
    end
    nil
  end
end

class Item
  include Comparable

  attr_reader :name
  attr_reader :sources
  attr_reader :counters
  attr_reader :category

  def initialize(name, category)
    @name = name
    @category = category
    @sources = SetWithefault.new
    @counters = SetWithefault.new
  end

  def add_counter(type)
    @counters << type
  end

  def add_source(source)
    @sources << source
  end

  def to_json
    { 
      :name => @name,
      :description => '',
      :sources => @sources.to_a,
      :counters => @counters.to_a,
      :uri => Urls.graph(@category.name, @name, @sources.default.name, @counters.default.name, '1day')
    }.to_json
  end

  def browser(source, counter, parameters={})
    source = source ? @sources.named?(source) : @sources.default
    counter = counter ? @counters.named?(counter) : @counters.default
    Browser.new(self, source, counter, parameters)
  end

  def <=>(anOther)
    name <=> anOther.name
  end
end

class Browser
  def initialize(item, source, counter, parameters)
    @item = item
    @source = source
    @counter = counter
    @parameters = parameters
    @graphable = Graphable.new(@item.category.name, @source.name, @item.name, @counter.name, @parameters)
  end

  def graphs
    [ @graphable.to_graph ]
  end

  def to_json
    {
      :name => @item.name,
      :graphs => graphs,
      :menu => {
        :timespan => {
          '1day'  => @graphable.to_graph({ :starting => '1day'  }),
          '3days' => @graphable.to_graph({ :starting => '3days' }),
          '1week' => @graphable.to_graph({ :starting => '1week' }),
          '2week' => @graphable.to_graph({ :starting => '2week' }),
          '4week' => @graphable.to_graph({ :starting => '4week' })
        },
        :counters => {
          :yesno => @graphable.to_graph({ :counter => :yesno }),
          :quartiles => @graphable.to_graph({ :counter => :quartiles })
        }
      }
    }.to_json
  end
end

class Graphable
  def initialize(category, source, name, counter, parameters)
    @category = category
    @source = source
    @name = name
    @counter = counter
    @parameters = {
      :source => @source,
      :name => @name,
      :counter => @counter,
      :starting => '1day',
      :ending => 'now',
      :w => 600,
      :h => 200
    }.merge(parameters)
  end

  def to_graph(extra={})
    p = @parameters.merge(extra)
    Graph.new(title, image_uri(p), uri(p))
  end

  private
  def uri(p)
    Urls.graph(@category, @name, @source, p[:counter], p[:starting])
  end

  def image_uri(p)
    Merb::Router.url(:render, p)
  end

  def title
    @category + " - " + @source + " - " + @name + " - " + @counter.to_s + " - " + @parameters[:starting]
  end
end
