module ObjectExt

  def as(*shapes)
    shapes.flat_map do |shape|
      scoped.map &shape.method(:new)
    end
  end

end

Object.extend ObjectExt
