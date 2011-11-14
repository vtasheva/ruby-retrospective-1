class Array
  def to_hash
    hash = {}
    each { |k, v| hash[k] = v}
    hash
  end

  def index_by
    hash = {}
    each { |e| hash[yield e] = e }
    hash
  end

  def subarray_count(subarray)
    count = 0
    0.upto(length - subarray.length) do |i|
      count = count + 1 if slice(i, subarray.length) == subarray
    end
    count
  end

  def occurences_count
    Hash.new { |hash, key| 0 }.tap do |result|
      each { |item| result[item] += 1 }
    end
  end
end