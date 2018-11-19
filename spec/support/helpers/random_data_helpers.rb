module RandomDataHelpers
  module_function

  def random_int(max=100)
    rand(0..max)
  end

  def random_string(size: 8)
    rand(36 ** size).to_s(36)
  end
end
